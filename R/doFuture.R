#' @importFrom foreach getErrorIndex getErrorValue getResult makeAccum
#' @importFrom iterators iter
#' @importFrom future future resolve value getGlobalsAndPackages
#' @importFrom parallel splitIndices
doFuture <- function(obj, expr, envir, data) {   #nolint
  stopifnot(inherits(obj, "foreach"))
  stopifnot(inherits(envir, "environment"))
  
  debug <- getOption("doFuture.debug", FALSE)
  if (debug) mdebug("doFuture() ...")

  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 1. Input from foreach
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Setup
  it <- iter(obj)
  args_list <- as.list(it)
  accumulator <- makeAccum(it)
  globalsAs <- data$globalsAs
  
  ## WORKAROUND: foreach::times() passes an empty string in 'argnames'
  argnames <- it$argnames
  argnames <- argnames[nzchar(argnames)]

  ## Global variables?
  stopifnot(!is.null(globalsAs), length(globalsAs) == 1L)

  ## Automatic or manual?
  if (grepl("-unless-manual$", globalsAs)) {
    if (is.null(obj$export)) {
      globalsAs <- gsub("-unless-manual$", "", globalsAs)
    } else {
      globalsAs <- "manual"
    }
  }

  ## Warn if manual does not match automatic?
  withWarning <- grepl("-with-warning$", globalsAs)
  if (withWarning) globalsAs <- gsub("-with-warning$", "", globalsAs)
  
  if (globalsAs == "manual") {
    globals <- unique(c(unique(obj$export), "...future.x_ii"))
  } else if (globalsAs == "foreach") {
    noexport <- union(obj$noexport, argnames)
    globals <- findGlobals_foreach(expr, envir = envir, noexport = noexport)
    globals <- unique(c(globals, "...future.x_ii"))
  } else if (globalsAs == "future") {
    globals <- TRUE
  } else {
    stop("Unknown value of argument 'globalsAs' for registerDoFuture(): ",
         sQuote(globalsAs))
  }

  ## Any packages to be on the search path?
  pkgs <- obj$packages
  if (length(pkgs) > 0L) {
    exprs <- lapply(pkgs, FUN = function(p) call("library", p))
    exprs <- c(exprs, expr)
    expr <- Reduce(function(a, b) {
      substitute({ a; b }, list(a = a, b = b))
    }, x = exprs)
    exprs <- NULL
  }


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 2. The future expression to use
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## The iterator arguments in 'argnames' should be exported as globals, which
  ## they also are as part of the 'globals = globals_ii' list that is passed
  ## to each future() call.  However, getGlobalsAndPackages(..., globals = TRUE)
  ## below requires that they are found.  If not, an error is produced.
  ## As a workaround, we will inject them as dummy variables in the expression
  ## inspected, making them look like local variables.
  if (debug) {
    mdebug("- dummy globals (as locals): [%d] %s",
           length(argnames), paste(sQuote(argnames), collapse = ", "))
  }
  dummy_globals <- NULL  #nolint
  for (kk in seq_along(argnames)) {
    name <- as.symbol(argnames[kk])  #nolint
    if (kk == 1L) {
      dummy_globals <- bquote(.(name) <- NULL)
    } else {
      dummy_globals <- bquote({ .(dummy_globals); .(name) <- NULL })
    }
  }


  ## Tell foreach to keep using futures also in nested calls
  expr <- bquote({
    doFuture::registerDoFuture()

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

  if (debug) {
    mdebug("- R expression:")
    mprint(expr)
  }


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 3. Indentify globals and packages
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if (debug) {
    mdebug("- identifying globals and packages ...")
  }
  globals_envir <- new.env(parent = envir)
  assign("...future.x_ii", NULL, envir = globals_envir, inherits = FALSE)
  ## BUG FIX/WORKAROUND: '...' must be last unless globals (> 0.11.0)
  if (packageVersion("globals") <= "0.11.0") {
    idx <- which(globals == "...")
    if (length(idx) > 0) globals <- c(globals[-idx], "...")
  }
  gp <- getGlobalsAndPackages(expr, envir = globals_envir,
                              globals = globals)
  globals <- gp$globals
  packages <- unique(c(gp$packages, pkgs))
  expr <- gp$expr
  rm(list = c("gp", "pkgs"))
  names_globals <- names(globals)


  ## Warn about globals found automatically, but not listed in '.export'?
  if (withWarning) {
    globals2 <- unique(obj$export)
    missing <- setdiff(names_globals, c(globals2, "...future.x_ii",
                                        "future.call.arguments"))
    if (length(missing) > 0) {
      warning(sprintf("Detected a foreach(..., .export = c(%s)) call where '.export' might lack one or more variables (as identified by globalsAs = %s of which some might be false positives): %s", paste(dQuote(globals2), collapse = ", "), sQuote(globalsAs), paste(dQuote(missing), collapse = ", ")))
    }
    globals2 <- NULL
  }
  
  ## Add automatically found globals to explicit '.export' globals?
  if (globalsAs != "manual") {
    globals2 <- unique(obj$export)
    ## Drop duplicates
    globals2 <- setdiff(globals2, names_globals)
    if (length(globals2) > 0) {
      mdebug("  - appending %d '.export' globals (not already found): %s",
             length(globals2), paste(sQuote(globals2)), collapse = ", ")
      gp <- getGlobalsAndPackages(expr, envir = globals_envir,
                                  globals = globals2)
      globals2 <- gp$globals
      packages <- unique(c(gp$packages, packages))
      globals <- c(globals, globals2)
      rm(list = "gp")
    }
    rm(list = "globals2")
  }
  
  rm(list = c("globals_envir"))

  if (debug) {
    mdebug("  - globals: [%d] %s", length(globals),
           paste(sQuote(names_globals), collapse = ", "))
    mstr(globals)
    mdebug("  - packages: [%d] %s", length(packages),
           paste(sQuote(packages), collapse = ", "))
    mdebug("  - R expression:")
    mprint(expr)
    mdebug("- identifying globals and packages ... DONE")
  }

  ## At this point a globals should be resolved and we should know
  ## their total size.
  ## NOTE: This is 1st of the 2 places where we req future (>= 1.4.0)
##  stopifnot(attr(globals, "resolved"), !is.na(attr(globals, "total_size")))
  
  ## Also make sure we've got our in-house '...future.x_ii' covered.
  stopifnot("...future.x_ii" %in% names(globals))


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 4. Load balancing ("chunking")
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Options:
  ## (a) .options.future = list(scheduling = <numeric>)
  ##      cf. future_lapply(..., future.scheduling)
  scheduling <- obj[["options"]][["future"]][["scheduling"]]

  ## If not set, fall back to:
  ## (b) .options.multicore = list(preschedule = <logical>)
  ##      cf. mclapply(..., preschedule)
  if (is.null(scheduling)) {
    preschedule <- obj[["options"]][["multicore"]][["preschedule"]]
    if (!is.null(preschedule)) {
      preschedule <- as.logical(preschedule)
      stopifnot(length(preschedule) == 1L, !is.na(preschedule))
      if (preschedule) {
        scheduling <- 1.0
      } else {
        scheduling <- Inf
      }
    }
  }

  ## (c) Otherwise, the default is to preschedule ("chunk")
  if (is.null(scheduling)) scheduling <- 1.0

  stopifnot(length(scheduling) == 1, !is.na(scheduling),
            is.numeric(scheduling) || is.logical(scheduling))

  nbr_of_elements <- length(args_list)
  if (is.logical(scheduling)) {
    if (scheduling) {
      nbr_of_futures <- nbrOfWorkers()
      if (nbr_of_futures > nbr_of_elements)
        nbr_of_futures <- nbr_of_elements
    } else {
      nbr_of_futures <- nbr_of_elements
    }
  } else {
    stopifnot(scheduling >= 0)
    nbr_of_workers <- nbrOfWorkers()
    if (nbr_of_workers > nbr_of_elements) {
      nbr_of_workers <- nbr_of_elements
    }
    nbr_of_futures <- scheduling * nbr_of_workers
    if (nbr_of_futures < 1) {
      nbr_of_futures <- 1L
    }
    else if (nbr_of_futures > nbr_of_elements) {
      nbr_of_futures <- nbr_of_elements
    }
  }

  chunks <- splitIndices(nbr_of_elements, ncl = nbr_of_futures)
  mdebug("Number of chunks: %d", length(chunks))


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 5. Create futures
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  nchunks <- length(chunks)
  fs <- vector("list", length = nchunks)
  mdebug("Number of futures (= number of chunks): %d", nchunks)

  mdebug("Launching %d futures (chunks) ...", nchunks)
  for (ii in seq_along(chunks)) {
    chunk <- chunks[[ii]]
    mdebug("Chunk #%d of %d ...", ii, length(chunks))

    ## Subsetting outside future is more efficient
    globals_ii <- globals
    globals_ii[["...future.x_ii"]] <- args_list[chunk]
    ## NOTE: This is 2nd of the 2 places where we req future (>= 1.4.0)
##    stopifnot(attr(globals_ii, "resolved"))

    fs[[ii]] <- future(expr, substitute = FALSE, envir = envir,
                       globals = globals_ii, packages = packages)

    ## Not needed anymore
    rm(list = c("chunk", "globals_ii"))

    mdebug("Chunk #%d of %d ... DONE", ii, nchunks)
  } ## for (ii ...)
  rm(list = c("chunks", "globals", "packages"))
  mdebug("Launching %d futures (chunks) ... DONE", nchunks)
  stopifnot(length(fs) == nchunks)


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 6. Resolve futures, gather their values, and reduce
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Resolve futures
  if (debug) mdebug("- resolving future")
  resolve(fs, value = TRUE)

  ## Gather values
  if (debug) mdebug("- collecting values of future")
  results <- lapply(fs, FUN = value, signal = FALSE)
  rm(list = "fs")
  stopifnot(length(results) == nchunks)

  ## Reduce chunks
  results <- Reduce(c, results)
  stopifnot(length(results) == nbr_of_elements)

  ## Combine results (and identify errors)
  ## NOTE: This is adopted from foreach:::doSEQ()
  if (debug) mdebug("- accumulating results")
  tryCatch({
    accumulator(results, tags = seq_along(results))
  }, error = function(e) {
    cat("error calling combine function:\n")
    print(e)
    NULL
  })
  stopifnot(length(results) == nbr_of_elements)


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 7. Error handling
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## throw an error or return the combined results
  ## NOTE: This is adopted from foreach:::doSEQ()
  error_handling <- obj$errorHandling
  if (debug) {
    mdebug("- processing errors (handler = %s)", sQuote(error_handling))
  }
  error_value <- getErrorValue(it)
  if (identical(error_handling, "stop") && !is.null(error_value)) {
    error_index <- getErrorIndex(it)
    msg <- sprintf('task %d failed - "%s"', error_index,
                   conditionMessage(error_value))
    stop(simpleError(msg, call = expr))
  }
  rm(list = c("expr"))


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 8. Final results
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if (debug) mdebug("- extracting results")
  res <- getResult(it)

  if (debug) mdebug("doFuture() ... DONE")

  res
} ## doFuture()
