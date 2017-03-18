#' @importFrom foreach getErrorIndex getErrorValue getResult makeAccum
#' @importFrom iterators iter
#' @importFrom future future resolve value
#' @importFrom parallel splitIndices
doFuture <- function(obj, expr, envir, data) {
  stopifnot(inherits(obj, "foreach"))
  stopifnot(inherits(envir, "environment"))
  getGlobalsAndPackages <- importFuture("getGlobalsAndPackages")

  debug <- getOption("doFuture.debug", FALSE)
  if (debug) mdebug("doFuture() ...")
  
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 1. Input from foreach
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Setup
  it <- iter(obj)
  argsList <- as.list(it)
  accumulator <- makeAccum(it)

  ## WORKAROUND: foreach::times() passes an empty string in 'argnames'
  argnames <- it$argnames
  argnames <- argnames[nzchar(argnames)]
  
  ## Global variables?
  export <- unique(obj$export)
  if (is.null(export)) {
    ## Automatic lookup of global variables by default
    ## NOTE: To fully emulate foreach's behavior in most
    ##       cases, we could disable this. /HB 2016-10-10
    globals <- getOption("doFuture.globals.nullexport", TRUE)
  } else {
    ## Export also the other foreach arguments
    globals <- unique(c(export, "...future.x_ii"))
  }
  export <- NULL
  
  ## Any packages to be on the search path?
  pkgs <- obj$packages
  if (length(pkgs) > 0L) {
    exprs <- lapply(pkgs, FUN=function(p) call("library", p))
    exprs <- c(exprs, expr)
    expr <- Reduce(function(a, b) {
      substitute({ a; b }, list(a=a, b=b))
    }, x=exprs)
    exprs <- NULL
  }

  
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 2. The future expression to use
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Tell foreach to keep using futures also in nested calls
  expr <- bquote({
    doFuture::registerDoFuture()
    
    lapply(seq_along(...future.x_ii), FUN = function(jj) {
      ...future.x_jj <- ...future.x_ii[[jj]]
      ...future.env <- environment()
      local({
        for (name in names(...future.x_jj)) {
          assign(name, ...future.x_jj[[name]], envir = ...future.env, inherits = FALSE)
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
  globals_envir <- new.env(parent = envir)
  assign("...future.x_ii", NULL, envir = globals_envir, inherits = FALSE)
  gp <- getGlobalsAndPackages(expr, envir = globals_envir,
                              globals = globals, resolve = TRUE)
  globals <- gp$globals
  packages <- unique(c(gp$packages, pkgs))
  expr <- gp$expr
  rm(list = c("gp", "globals_envir", "pkgs"))
  
  names_globals <- names(globals)  
  if (debug) {
    mdebug("- globals: [%d] %s", length(globals),
           paste(sQuote(names_globals), collapse = ", "))
    mstr(globals)
    mdebug("- packages: [%d] %s", length(packages),
           paste(sQuote(packages), collapse = ", "))
    mdebug("- R expression:")
    mprint(expr)
  }

  ## At this point a globals should be resolved and we should know
  ## their total size.
  ## NOTE: This is 1st of the 2 places where we req future (>= 1.4.0)
  stopifnot(attr(globals, "resolved"), !is.na(attr(globals, "total_size")))
  ## Also make sure we've got our in-house '...future.x_ii' covered.
  stopifnot("...future.x_ii" %in% names(globals))

  
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 4. Load balancing ("chunking")
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  nbr_of_elements <- length(argsList)
  nbr_of_futures <- nbrOfWorkers()
  if (nbr_of_futures > nbr_of_elements) nbr_of_futures <- nbr_of_elements
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
    globals_ii[["...future.x_ii"]] <- argsList[chunk]
    ## NOTE: This is 2nd of the 2 places where we req future (>= 1.4.0)
    stopifnot(attr(globals_ii, "resolved"))

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
    accumulator(results, tags=seq_along(results))
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
  errorHandling <- obj$errorHandling
  if (debug) mdebug("- processing errors (handler = %s)", sQuote(errorHandling))
  errorValue <- getErrorValue(it)
  if (identical(errorHandling, "stop") && !is.null(errorValue)) {
    errorIndex <- getErrorIndex(it)
    msg <- sprintf('task %d failed - "%s"', errorIndex,
                   conditionMessage(errorValue))
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
