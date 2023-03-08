#' Loop over a Foreach Expression using Futures
#'
#' @param foreach A `foreach` object created by [foreach::foreach()]
#' and [foreach::times()].
#'
#' @param expr An R expression.
#'
#' @return The value of the foreach call.
#'
#' @details
#' This is a replacement for [`%dopar%`] of the \pkg{foreach} package
#' that leverages the \pkg{future} framework.
#'
#' When using `%dofuture%`:
#'
#' * there is no need to use `registerDoFuture()`
#' * there is no need to use `%dorng%` of the **doRNG** package
#'   (but you need to specify `.options.future = list(seed = TRUE)`
#'    whenever using random numbers in the `expr` expression)
#' * global variables and packages are identified automatically by
#'   the \pkg{future} framework
#'
#' @example incl/dofuture_OP.R
#'
#' @export
`%dofuture%` <- function(foreach, expr) {
  stopifnot(inherits(foreach, "foreach"))
  expr <- substitute(expr)
  doFuture2(foreach, expr, envir = parent.frame(), data = NULL)
}


#' @importFrom foreach getErrorIndex getErrorValue getResult makeAccum
#' @importFrom iterators iter
#' @importFrom future future resolve value Future FutureError getGlobalsAndPackages
#' @importFrom parallel splitIndices
#' @importFrom utils head
#' @importFrom globals globalsByName
#  ## Just a dummy import to please 'R CMD check'
#' @import future.apply
doFuture2 <- function(obj, expr, envir, data) {   #nolint
  stop_if_not(inherits(obj, "foreach"))
  stop_if_not(inherits(envir, "environment"))
  
  debug <- getOption("doFuture.debug", FALSE)
  if (debug) mdebug("doFuture2() ...")

  make_function <- function(argnames, body, envir = parent.frame()) {
    FUN <- function() NULL
    empty_formal <- alist(a =)
    args <- rep(empty_formal, times = length(argnames))
    names(args) <- argnames
    attr(expr, "srcref") <- NULL
    body(FUN) <- expr
    formals(FUN) <- args
    environment(FUN) <- envir
    FUN
  }

  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 1. Input from foreach
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Setup
  it <- iter(obj)
  args_list <- as.list(it)
  accumulator <- makeAccum(it)
  options <- obj[["options"]]
  unknown <- setdiff(names(options), "future")
  if (length(unknown) > 0L) {
    stop(sprintf("Unknown foreach() arguments: %s",
         paste(sQuote(sprintf(".options.%s", unknown)), collapse = ", ")))
  }
  options <- options[["future"]]

  if (!is.null(obj$export)) {
    stop("foreach() does not support argument '.export' when using %dofuture%. Use .options.future = list(globals = structure(..., add = ...)) instead")
  } else if (!is.null(obj$noexport)) {
    stop("foreach() does not support argument '.noexport' when using %dofuture%. Use .options.future = list(globals = structure(..., ignore = ...)) instead")
  } else if (!is.null(obj$packages)) {
    stop("foreach() does not support argument '.packages' when using %dofuture%. Use .options.future = list(packages = ...) instead")
  }

  errors <- options[["errors"]]
  if (is.null(errors)) {
    errors <- "future"
  } else if (is.character(errors)) {
    if (length(errors) != 1L) {
      stop(sprintf("Element 'errors' of '.options.future' should be of length one': [n = %d] %s", length(errors), paste(sQuote(errors), collapse = ", ")))
    }
    if (! errors %in% c("future", "foreach")) {
      stop(sprintf("Unknown value of '.options.future' element 'errors': %s", sQuote(errors)))
    }
  } else {
    stop("Unknown type of '.options.future' element 'errors': ", mode(errors))
  }


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 4. Load balancing ("chunking")
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## (a) .options.future = list(chunk.size = <numeric>)
  ##      cf. future_lapply(..., future.chunk.size)
  chunk.size <- options[["chunk.size"]]

  ## (b) .options.future = list(scheduling = <numeric>)
  ##      cf. future_lapply(..., future.scheduling)
  scheduling <- options[["scheduling"]]
  
  if (is.null(chunk.size) && is.null(scheduling)) {
    scheduling <- 1.0
  }
  

  nX <- length(args_list)
  chunks <- makeChunks(nbrOfElements = nX,
                       nbrOfWorkers = nbrOfWorkers(),
                       future.scheduling = scheduling,
                       future.chunk.size = chunk.size)
  if (debug) mdebugf("Number of chunks: %d", length(chunks))


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 5. Create futures
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Relay standard output or conditions?
  stdout <- options[["stdout"]]
  if (is.null(stdout)) {
    stdout <- eval(formals(future)$stdout)
  }
  
  conditions <- options[["conditions"]]
  if (is.null(conditions)) {
    conditions <- eval(formals(future)$conditions)
  }

  ## Drop captured standard output and conditions as soon as they have
  ## been relayed?
  if (isTRUE(stdout)) stdout <- structure(stdout, drop = TRUE)
  if (length(conditions) > 0) conditions <- structure(conditions, drop = TRUE)

  nchunks <- length(chunks)
  fs <- vector("list", length = nchunks)
  if (debug) mdebugf("Number of futures (= number of chunks): %d", nchunks)

  ## Adjust option 'future.globals.maxSize' to account for the fact that more
  ## than one element is processed per future.  The adjustment is done by
  ## scaling up the limit by the number of elements in the chunk.  This is
  ## a "good enough" approach.
  ## (https://github.com/HenrikBengtsson/future.apply/issues/8,
  ##  https://github.com/HenrikBengtsson/doFuture/issues/26)
  globals.maxSize <- getOption("future.globals.maxSize")
  if (nchunks > 1 && !is.null(globals.maxSize) && globals.maxSize < +Inf) {
    globals.maxSize.default <- globals.maxSize
    if (is.null(globals.maxSize.default)) globals.maxSize.default <- 500 * 1024^2

    globals.maxSize.adjusted <- nchunks * globals.maxSize.default
    options(future.globals.maxSize = globals.maxSize.adjusted)
    on.exit(options(future.globals.maxSize = globals.maxSize), add = TRUE)

    ## Adjust expression 'expr' such that the non-adjusted maxSize is used
    ## within each future
    expr <- bquote_apply(tmpl_expr_options)

    if (debug) {
      mdebug("Rescaling option 'future.globals.maxSize' to account for the number of elements processed per chunk:")
      mdebugf(" - Number of chunks: %d", nchunks)
      mdebugf(" - globals.maxSize (original): %.0f bytes", globals.maxSize.default)
      mdebugf(" - globals.maxSize (adjusted): %.0f bytes", globals.maxSize.adjusted)
      mdebug("- R expression (adjusted):")
      mprint(expr)
    }
  } else {
    globals.maxSize.adjusted <- NULL
  }


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Reproducible RNG (for sequential and parallel processing)
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  seed <- options[["seed"]]
  if (is.null(seed)) {
    seed <- eval(formals(future)$seed)
  }
  if (debug) mdebugf("seed = %s", deparse(seed))

  make_rng_seeds <- import_future.apply("make_rng_seeds")
  seeds <- make_rng_seeds(nX, seed = seed)
  if (debug) {
    mstr(seeds)
  }

  ## Future expression (with or without setting the RNG state) and
  ## pass possibly tweaked 'seed' to future()
  if (is.null(seeds)) {
    stop_if_not(is.null(seed) || isFALSE(seed))
  } else {
    next_random_seed <- import_future.apply("next_random_seed")
    set_random_seed <- import_future.apply("set_random_seed")
    ## If RNG seeds are used (given or generated), make sure to reset
    ## the RNG state afterward
    oseed <- next_random_seed()    
    on.exit(set_random_seed(oseed))
    ## As seed=FALSE but without the RNG check
    seed <- NULL
  }
  if (debug) mdebugf("seed = %s", deparse(seed))
  

  ## Are there RNG-check settings specific for doFuture?
  onMisuse <- getOption("doFuture.rng.onMisuse", NULL)
  if (!is.null(onMisuse)) {
    if (onMisuse == "ignore") {
      seed <- NULL
    } else {
      oldOnMisuse <- getOption("future.rng.onMisuse")
      options(future.rng.onMisuse = onMisuse)
      on.exit(options(future.rng.onMisuse = oldOnMisuse), add = TRUE)
    }
  }
  if (debug) mdebugf("seed = %s", deparse(seed))


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 2. Construct the 'FUN' function
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## WORKAROUND: foreach::times() passes an empty string in 'argnames'
  argnames <- it$argnames
  argnames <- argnames[nzchar(argnames)]
  if (debug) {
    mdebugf("- foreach iterator arguments: [%d] %s",
           length(argnames), paste(sQuote(argnames), collapse = ", "))
  }
  
  ## The iterator arguments in 'argnames' should be exported as globals, which
  ## they also are as part of the 'globals = globals_ii' list that is passed
  ## to each future() call.  However, getGlobalsAndPackages(..., globals = TRUE)
  ## below requires that they are found.  If not, an error is produced.
  ## As a workaround, we will inject them as dummy variables in the expression
  ## inspected, making them look like local variables.
  if (debug) {
    mdebugf("- dummy globals (as locals): [%d] %s",
           length(argnames), paste(sQuote(argnames), collapse = ", "))
  }
  dummy_globals <- NULL
  for (kk in seq_along(argnames)) {
    name <- as.symbol(argnames[kk])  #nolint
    dummy_globals <- bquote_apply(tmpl_dummy_globals)
  }

  ## With or without RNG?
  expr <- bquote_apply(
    if (is.null(seeds)) {
      tmpl_expr
    } else {
      tmpl_expr_with_rng
    }
  )
  
  rm(list = "dummy_globals") ## Not needed anymore

  if (debug) {
    mdebug("- R expression:")
    mprint(expr)
  }

  ## The iterator arguments in 'argnames' should be passed as regular
  ## arguments to the 'FUN' function part of the future_lapply() call.
  FUN <- make_function(argnames, body = expr, envir = envir)
  if (debug) {
    mprint(FUN)
  }
    

  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 3. Identify globals and packages
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if (debug) mdebug("- identifying globals and packages ...")

  globals <- options[["globals"]]
  if (is.null(globals)) globals <- TRUE
  
  packages <- options[["packages"]]
  
  ## Environment from where to search for globals
  globals_envir <- new.env(parent = envir)
  assign("...future.x_ii", 42, envir = globals_envir, inherits = FALSE)

  add <- attr(globals, "add", exact = TRUE)
  add <- c(add, "...future.x_ii")

  ignore <- attr(globals, "ignore", exact = TRUE)
  ignore <- c(ignore, argnames)

  if (is.character(globals)) {
     globals <- setdiff(unique(c(globals, add)), ignore)
  } else {
    attr(globals, "add") <- add
    attr(globals, "ignore") <- ignore
  }

  mstr(globals)
  gp <- getGlobalsAndPackages(expr, envir = globals_envir, globals = globals, packages = packages)
  globals <- gp$globals
  packages <- unique(c(gp$packages, packages))
  expr <- gp$expr
  rm(list = c("gp", "globals_envir")) ## Not needed anymore
  mstr(globals)
  
  ## Also make sure we've got our in-house '...future.x_ii' covered.
  stop_if_not("...future.x_ii" %in% names(globals),
            !any(duplicated(names(globals))),
            !any(duplicated(packages)))

  ## Have the future backend/framework handle also the required 'doFuture'
  ## package.  That way we will get a more informative error message in
  ## case it is missing.
  packages <- unique(c("doFuture", packages))
  
  if (debug) {
    mdebug("  - R expression:")
    mprint(expr)
    mdebugf("  - globals: [%d] %s", length(globals),
           paste(sQuote(names(globals)), collapse = ", "))
    mstr(globals)
    mdebugf("  - packages: [%d] %s", length(packages),
           paste(sQuote(packages), collapse = ", "))
  
    mdebug("- identifying globals and packages ... DONE")
  }


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Creating futures
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  labels <- sprintf("doFuture2-%s", seq_len(nchunks))

  if (debug) mdebugf("Launching %d futures (chunks) ...", nchunks)
  for (ii in seq_along(chunks)) {
    chunk <- chunks[[ii]]
    if (debug) mdebugf("Chunk #%d of %d ...", ii, length(chunks))

    ## Subsetting outside future is more efficient
    globals_ii <- globals
    packages_ii <- packages
    args_list_ii <- args_list[chunk]
    globals_ii[["...future.x_ii"]] <- args_list_ii

    if (debug) mdebugf(" - Finding globals in 'args_list' chunk #%d ...", ii)
    ## Search for globals in 'args_list_ii':
    gp <- getGlobalsAndPackages(args_list_ii, envir = envir, globals = TRUE)
    globals_X <- gp$globals
    packages_X <- gp$packages
    gp <- NULL

    if (debug) {
      mdebugf("   + globals found in 'args_list' for chunk #%d: [%d] %s", chunk, length(globals_X), hpaste(sQuote(names(globals_X))))
      mdebugf("   + needed namespaces for 'args_list' for chunk #%d: [%d] %s", chunk, length(packages_X), hpaste(sQuote(packages_X)))
    }
  
    ## Export also globals found in 'args_list_ii'
    if (length(globals_X) > 0L) {
      reserved <- intersect(c("...future.FUN", "...future.x_ii"), names(globals_X))
      if (length(reserved) > 0) {
        stop("Detected globals in 'args_list' using reserved variables names: ",
             paste(sQuote(reserved), collapse = ", "))
      }
      globals_ii <- unique(c(globals_ii, globals_X))

      ## Packages needed due to globals in 'args_list_ii'?
      if (length(packages_X) > 0L)
        packages_ii <- unique(c(packages_ii, packages_X))
    }
    
    rm(list = c("globals_X", "packages_X"))
    
    if (debug) mdebugf(" - Finding globals in 'args_list' for chunk #%d ... DONE", ii)

    rm(list = "args_list_ii")
    
    if (!is.null(globals.maxSize.adjusted)) {
      globals_ii <- c(globals_ii, ...future.globals.maxSize = globals.maxSize)
    }

    ## Using RNG seeds or not?
    if (is.null(seeds)) {
      if (debug) mdebug(" - seeds: <none>")
    } else {
      if (debug) mdebugf(" - seeds: [n=%d] <seeds>", length(chunk))
      globals_ii[["...future.seeds_ii"]] <- seeds[chunk]
      stop_if_not(length(seeds[chunk]) > 0, is.list(seeds[chunk]))
    }

    fs[[ii]] <- future(
      expr, substitute = FALSE,
      envir = envir,
      globals = globals_ii,
      packages = packages_ii,
      seed = seed,
      stdout = stdout,
      conditions = conditions,
      label = labels[ii]
    )

    ## Not needed anymore
    rm(list = c("chunk", "globals_ii", "packages_ii"))

    if (debug) mdebugf("Chunk #%d of %d ... DONE", ii, nchunks)
  } ## for (ii ...)
  rm(list = c("globals", "packages", "labels", "seeds"))
  if (debug) mdebugf("Launching %d futures (chunks) ... DONE", nchunks)
  stop_if_not(length(fs) == nchunks)


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 6. Resolve futures, gather their values, and reduce
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Resolve futures
  if (debug) {
    mdebug("- resolving futures")
    mdebug("  - gathering results & relaying conditions (except errors)")
  }
  
  ## Check for RngFutureCondition:s when resolving futures?
  if (isFALSE(seed)) {
    withCallingHandlers({
      values <- local({
          oopts <- options(future.rng.onMisuse.keepFuture = FALSE)
          on.exit(options(oopts))
          value(fs)
      })
     }, RngFutureCondition = function(cond) {
      ## One of "our" futures?
      idx <- NULL
      
      ## Compare future UUIDs or whole futures?
      uuid <- attr(cond, "uuid")
      if (!is.null(uuid)) {
        ## (a) Future UUIDs are available
        for (kk in seq_along(fs)) {
          if (identical(fs[[kk]]$uuid, uuid)) idx <- kk
        }
      } else {        
        ## (b) Future UUIDs are not available, use Future object?
        f <- attr(cond, "future")
        if (is.null(f)) return()
        ## Nothing to do?
        if (!isFALSE(f$seed)) return()  ## shouldn't really happen
        for (kk in seq_along(fs)) {
          if (identical(fs[[kk]], f)) idx <- kk
        }
      }
      
      ## Nothing more to do, i.e. not one of our futures?
      if (is.null(idx)) return()

      ## Adjust message to give instructions relevant to this package
      f <- fs[[idx]]
      label <- f$label
      if (is.null(label)) label <- "<none>"
      chunk <- chunks[[idx]]
      ordering <- attr(chunks, "ordering")
      if (!is.null(ordering)) {
        chunk <- ordering[chunk]
      }
      if (length(chunk) == 1L) {
        iterations <- sprintf("Iteration %d", chunk)
      } else {
        iterations <- seq_to_human(chunk)
        iterations <- sprintf("At least one of iterations %s", iterations)
      }
      message <- sprintf("UNRELIABLE VALUE: %s of the foreach() %%dofuture%% { ... }, part of chunk #%d (%s), unexpectedly generated random numbers without declaring so. There is a risk that those random numbers are not statistically sound and the overall results might be invalid. To fix this, specify foreach() argument '.options.future = list(seed = TRUE)'. This ensures that proper, parallel-safe random numbers are produced via the L'Ecuyer-CMRG method. To disable this check, set option 'doFuture.rng.onMisuse' to \"ignore\".", iterations, idx, sQuote(label))
      cond$message <- message
      if (inherits(cond, "warning")) {
        warning(cond)
        invokeRestart("muffleWarning")
      } else if (inherits(cond, "error")) {
        stop(cond)
      }
    }) ## withCallingHandlers()
  } else {
    values <- value(fs)
  }
  rm(list = c("fs", "chunks"))

  if (debug) {
    mdebugf(" - Number of value chunks collected: %d", length(values))
    mdebugf("Resolving %d futures (chunks) ... DONE", nchunks)
  }

  stop_if_not(length(values) == nchunks)
  if (debug) mdebugf("Reducing values from %d chunks ...", nchunks)

  if (debug) {
    mdebug("Raw results:")
    mstr(values)
  }

  results <- values
  results2 <- do.call(c, args = results)
  if (debug) {
    mdebug("Combined results:")
    mstr(results2)
  }

  ## Assertions
  if (length(results2) != length(args_list)) {
      chunk_sizes <- sapply(results, FUN = length)
      chunk_sizes <- table(chunk_sizes)
      chunk_summary <- sprintf("%d chunks with %s elements", 
          chunk_sizes, names(chunk_sizes))
      chunk_summary <- paste(chunk_summary, collapse = ", ")
      msg <- sprintf("Unexpected error in doFuture(): After gathering and merging the results 
om %d chunks in to a list, the total number of elements (= %d) does not match the number of in
t elements in 'X' (= %d). There were in total %d chunks and %d elements (%s)", 
          nchunks, length(results2), length(args_list), nchunks, 
          sum(chunk_sizes), chunk_summary)
      if (debug) {
          mdebug(msg)
          mprint(chunk_sizes)
          mdebug("Results before merge chunks:")
          mstr(results)
          mdebug("Results after merge chunks:")
          mstr(results2)
      }
      msg <- sprintf("%s. Example of the first few values: %s", 
          msg, paste(capture.output(str(head(results2, 3L))), 
              collapse = "\\n"))
      ex <- FutureError(msg)
      stop(ex)
  }
  values <- values2 <- results <- NULL

  ## Combine results (and identify errors)
  ## NOTE: This is adopted from foreach:::doSEQ()
  if (debug) {
    mdebug("- accumulating results")
  }
  tryCatch({
    accumulator(results2, tags = seq_along(results2))
  }, error = function(e) {
    cat("error calling combine function:\n")
    print(e)
    NULL
  })
  rm(list = "values")


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 7. Error handling
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  error_value <- getErrorValue(it)
  if (!is.null(error_value)) {
    ## Report on errors like elsewhere in the Futureverse (default)?
    if (errors == "future") {
      stop(error_value)
    } else {  
      ## ... or as traditionally with %dopar%, which throws an error
      ## or return the combined results
      ## NOTE: This is adopted from foreach:::doSEQ()
      error_handling <- obj$errorHandling
      if (debug) {
        mdebugf("- processing errors (handler = %s)", sQuote(error_handling))
      }
      error_value <- getErrorValue(it)
      if (identical(error_handling, "stop")) {
        error_index <- getErrorIndex(it)
        msg <- sprintf('task %d failed - "%s"', error_index,
                       conditionMessage(error_value))
        stop(simpleError(msg, call = expr))
      }
    }
  }

  rm(list = c("expr"))


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 8. Final results
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if (debug) mdebug("- extracting results")
  res <- getResult(it)
  
  if (debug) mdebug("doFuture2() ... DONE")

  res
} ## doFuture2()


seq_to_intervals <- function(idx, ...) {
  # Clean up sequence
  idx <- as.integer(idx)
  idx <- unique(idx)
  idx <- sort(idx)

  n <- length(idx)
  if (n == 0L) {
    res <- matrix(NA_integer_, nrow=0L, ncol=2L)
    colnames(res) <- c("from", "to")
    return(res)
  }


  # Identify end points of intervals
  d <- diff(idx)
  d <- (d > 1)
  d <- which(d)
  nbrOfIntervals <- length(d) + 1

  # Allocate return matrix
  res <- matrix(NA_integer_, nrow=nbrOfIntervals, ncol=2L)
  colnames(res) <- c("from", "to")

  fromValue <- idx[1]
  toValue <- fromValue-1
  lastValue <- fromValue

  count <- 1
  for (kk in seq_along(idx)) {
    value <- idx[kk]
    if (value - lastValue > 1) {
      toValue <- lastValue
      res[count,] <- c(fromValue, toValue)
      fromValue <- value
      count <- count + 1
    }
    lastValue <- value
  }

  if (toValue < fromValue) {
    toValue <- lastValue
    res[count,] <- c(fromValue, toValue)
  }

  res
}

seq_to_human <- function(idx, tau=1L, delimiter="-", collapse=", ", ...) {
  tau <- as.integer(tau)
  data <- seq_to_intervals(idx)

  ## Nothing to do?
  n <- nrow(data)
  if (n == 0) return("")

  s <- character(length=n)

  delta <- data[,2L] - data[,1L]

  ## Individual values
  idxs <- which(delta == 0)
  if (length(idxs) > 0L) {
    s[idxs] <- as.character(data[idxs,1L])
  }

  if (tau > 1) {
    if (tau == 2) {
      idxs <- which(delta == 1)
      if (length(idxs) > 0L) {
        s[idxs] <- paste(data[idxs,1L], data[idxs,2L], sep=collapse)
      }
    } else {
      idxs <- which(delta < tau)
      if (length(idxs) > 0L) {
        for (idx in idxs) {
          s[idx] <- paste(data[idx,1L]:data[idx,2L], collapse=collapse)
        }
      }
    }
  }

  ## Ranges
  idxs <- which(delta >= tau)
  if (length(idxs) > 0L) {
    s[idxs] <- paste(data[idxs,1L], data[idxs,2L], sep=delimiter)
  }

  paste(s, collapse=collapse)
}


tmpl_dummy_globals <- bquote_compile({
  .(dummy_globals)
  .(name) <- NULL
})

tmpl_expr <- bquote_compile({
  lapply(seq_along(...future.x_ii), FUN = function(jj) {
    ...future.x_jj <- ...future.x_ii[[jj]]  #nolint
    .(dummy_globals)
    ...future.env <- environment()          #nolint
    local({
      for (name in names(...future.x_jj)) {
        assign(name, ...future.x_jj[[name]],
               envir = ...future.env, inherits = FALSE)
      }
    })
    tryCatch(.(expr), error = identity)
  })
})


tmpl_expr_with_rng <- bquote_compile({
  lapply(seq_along(...future.x_ii), FUN = function(jj) {
    ...future.x_jj <- ...future.x_ii[[jj]]  #nolint
    .(dummy_globals)
    ...future.env <- environment()          #nolint
    local({
      for (name in names(...future.x_jj)) {
        assign(name, ...future.x_jj[[name]],
               envir = ...future.env, inherits = FALSE)
      }
    })
    assign(".Random.seed", ...future.seeds_ii[[jj]], envir = globalenv(), inherits = FALSE)
    tryCatch(.(expr), error = identity)
  })
})


tmpl_expr_options <- bquote_compile({
  ...future.globals.maxSize.org <- getOption("future.globals.maxSize")
  if (!identical(...future.globals.maxSize.org, ...future.globals.maxSize)) {
    oopts <- options(future.globals.maxSize = ...future.globals.maxSize)
    on.exit(options(oopts), add = TRUE)
  }
  .(expr)
})
