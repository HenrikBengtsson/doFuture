#' @importFrom foreach getErrorIndex getErrorValue getResult makeAccum
#' @importFrom iterators iter
#' @importFrom future future resolve value FutureError
#' @importFrom parallel splitIndices
doFuture <- function(obj, expr, envir, data) {   #nolint
  stop_if_not(inherits(obj, "foreach"))
  stop_if_not(inherits(envir, "environment"))
  
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
  stop_if_not(!is.null(globalsAs), length(globalsAs) == 1L)
  
  ## WORKAROUND: foreach::times() passes an empty string in 'argnames'
  argnames <- it$argnames
  argnames <- argnames[nzchar(argnames)]


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
  dummy_globals <- NULL
  for (kk in seq_along(argnames)) {
    name <- as.symbol(argnames[kk])  #nolint
    if (kk == 1L) {
      dummy_globals <- bquote(.(name) <- NULL)
    } else {
      dummy_globals <- bquote({ .(dummy_globals); .(name) <- NULL })
    }
  }

  expr <- bquote({
    ## Tell foreach to keep using futures also in nested calls
    doFuture::registerDoFuture(globalsAs = .(globalsAs))

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

  rm(list = "dummy_globals") ## Not needed anymore

  if (debug) {
    mdebug("- R expression:")
    mprint(expr)
  }


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 3. Indentify globals and packages
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if (debug) mdebug("- identifying globals and packages ...")
  
  gp <- getGlobalsAndPackages_doFuture(expr, envir = envir,
                                       export = obj$export,
                                       noexport = c(obj$noexport, argnames),
                                       packages = obj$packages,
                                       globalsAs = globalsAs,
                                       debug = debug)

  expr <- gp$expr
  globals <- gp$globals
  packages <- gp$packages
  rm(list = "gp")
  
  if (debug) {
    mdebug("  - R expression:")
    mprint(expr)
    mdebug("  - globals: [%d] %s", length(globals),
           paste(sQuote(names(globals)), collapse = ", "))
    mstr(globals)
    mdebug("  - packages: [%d] %s", length(packages),
           paste(sQuote(packages), collapse = ", "))
  
    mdebug("- identifying globals and packages ... DONE")
  }


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
      stop_if_not(length(preschedule) == 1L, !is.na(preschedule))
      if (preschedule) {
        scheduling <- 1.0
      } else {
        scheduling <- Inf
      }
    }
  }

  ## (c) Otherwise, the default is to preschedule ("chunk")
  if (is.null(scheduling)) scheduling <- 1.0

  stop_if_not(length(scheduling) == 1, !is.na(scheduling),
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
    stop_if_not(scheduling >= 0)
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
  if (debug) mdebug("Number of chunks: %d", length(chunks))


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 5. Create futures
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  nchunks <- length(chunks)
  fs <- vector("list", length = nchunks)
  if (debug) mdebug("Number of futures (= number of chunks): %d", nchunks)

  if (debug) mdebug("Launching %d futures (chunks) ...", nchunks)
  for (ii in seq_along(chunks)) {
    chunk <- chunks[[ii]]
    if (debug) mdebug("Chunk #%d of %d ...", ii, length(chunks))

    ## Subsetting outside future is more efficient
    globals_ii <- globals
    globals_ii[["...future.x_ii"]] <- args_list[chunk]
    ## NOTE: This is 2nd of the 2 places where we req future (>= 1.4.0)
##    stop_if_not(attr(globals_ii, "resolved"))

    fs[[ii]] <- future(expr, substitute = FALSE, envir = envir,
                       globals = globals_ii, packages = packages)

    ## Not needed anymore
    rm(list = c("chunk", "globals_ii"))

    if (debug) mdebug("Chunk #%d of %d ... DONE", ii, nchunks)
  } ## for (ii ...)
  rm(list = c("chunks", "globals", "packages"))
  if (debug) mdebug("Launching %d futures (chunks) ... DONE", nchunks)
  stop_if_not(length(fs) == nchunks)


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
  stop_if_not(length(results) == nchunks)

  ## Reduce chunks
  results2 <- do.call(c, args = results)
    
  if (length(results2) != nbr_of_elements) {
    chunk_sizes <- sapply(results, FUN = length)
    chunk_sizes <- table(chunk_sizes)
    chunk_summary <- sprintf("%d chunks with %s elements",
                             chunk_sizes, names(chunk_sizes))
    chunk_summary <- paste(chunk_summary, collapse = ", ")
    msg <- sprintf("Unexpected error in doFuture(): After gathering and merging the results from %d chunks in to a list, the total number of elements (= %d) does not match the number of input elements in 'X' (= %d). There were in total %d chunks and %d elements (%s)", nchunks, length(results2), nbr_of_elements, nchunks, sum(chunk_sizes), chunk_summary)
    if (debug) {
      mdebug(msg)
      mprint(chunk_sizes)
      mdebug("Results before merge chunks:")
      mstr(results)
      mdebug("Results after merge chunks:")
      mstr(results2)
    }
    ex <- FutureError(msg)
    stop(ex)
  }
  results <- results2
  rm(list = "results2")
  
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
  rm(list = "results")

  
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
