#' @importFrom foreach getErrorIndex getErrorValue getResult makeAccum
#' @importFrom iterators iter
#' @importFrom future future resolve value
#' @importFrom globals as.Globals
#' @importFrom utils capture.output object.size
#' @importFrom parallel splitIndices
doFuture <- function(obj, expr, envir, data) {
  stopifnot(inherits(obj, "foreach"))
  stopifnot(inherits(envir, "environment"))
  getGlobalsAndPackages <- importFuture("getGlobalsAndPackages")

  debug <- getOption("doFuture.debug", FALSE)
  if (debug) mdebug("doFuture() ...")
  
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
    globals <- unique(c(export, argnames))
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

  ## Tell foreach to keep using futures also in nested calls
  expr <- bquote({
    doFuture::registerDoFuture()
    .(expr)
  })

  globals_envir <- new.env(parent = envir)
  if (length(argnames) > 0) {
    ## Add the arguments as dummy variables
    mdebug("- Adding dummy variables for arguments: %s",
           paste(sQuote(argnames), collapse = ", "))
    for (name in argnames) {
      mdebug("- argument: %s", sQuote(name))
      assign(name, NULL, envir = globals_envir, inherits = TRUE)
    }
  }  

  gp <- getGlobalsAndPackages(expr, envir = globals_envir,
                              globals = globals, resolve = TRUE)
  globals <- gp$globals
  packages <- unique(c(gp$packages, pkgs))
  expr <- gp$expr

  names_globals <- names(globals)  
  if (debug) {
    mdebug("- globals: [%d] %s", length(globals),
           paste(sQuote(names_globals), collapse = ", "))
    mstr(globals)
  }
  
  ## Make sure all elements of `argnames` are in the 'globals' set.
  ## If not, then add the missing ones.
  globals_missing <- setdiff(argnames, names_globals)
  if (length(globals_missing) > 0) {
    ## Create dummy place holders
    globals_extra <- vector("list", length = length(globals_missing))
    names(globals_extra) <- globals_missing
    attr(globals_extra, "resolved") <- TRUE
    attr(globals_extra, "size") <- unclass(object.size(globals_extra))
    globals <- c(globals, globals_extra)
    names_globals <- names(globals)
    if (debug) {
      mdebug("- adding remaining arguments as globals: [%d] %s", length(globals_extra), paste(sQuote(globals_extra), collapse = ", "))
      mdebug("- updated globals: [%d] %s", length(globals), paste(sQuote(names_globals), collapse = ", "))
      mstr(globals)
    }
  }


  x <- argsList
  
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 4. Load balancing ("chunking")
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  nx <- length(x)
  nbr_of_futures <- nbrOfWorkers()
  if (nbr_of_futures > nx) nbr_of_futures <- nx
  
  chunks <- splitIndices(nx, ncl = nbr_of_futures)
  mdebug("Number of chunks: %d", length(chunks))   


  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## 5. Create futures
  ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  ## Add argument placeholders
  globals_extra <- as.Globals(list(...future.x_ii = NULL))
  attr(globals_extra, "resolved") <- TRUE
  attr(globals_extra, "total_size") <- 0
  globals <- c(globals, globals_extra)

  ## FIXME:
  attr(globals, "resolved") <- TRUE
  attr(globals, "total_size") <- 0
  
  ## At this point a globals should be resolved and we should know their total size
  stopifnot(attr(globals, "resolved"), !is.na(attr(globals, "total_size")))

    ## To please R CMD check
  ...future.x_ii <- NULL

  
  nchunks <- length(chunks)
  fs <- vector("list", length = nchunks)
  mdebug("Number of futures (= number of chunks): %d", nchunks)
  
  mdebug("Launching %d futures (chunks) ...", nchunks)
  for (ii in seq_along(chunks)) {
    chunk <- chunks[[ii]]
    mdebug("Chunk #%d of %d ...", ii, length(chunks))

    ## Subsetting outside future is more efficient
    globals_ii <- globals
    globals_ii[["...future.x_ii"]] <- x[chunk]
    stopifnot(attr(globals_ii, "resolved"))
    
    fs[[ii]] <- future({
      lapply(seq_along(...future.x_ii), FUN = function(jj) {
         ...future.x_jj <- ...future.x_ii[[jj]]
         ...future.FUN(...future.x_jj, ...)
      })
    }, envir = envir, lazy = future.lazy, globals = globals_ii, packages = packages)
    
    ## Not needed anymore
    rm(list = c("chunk", "globals_ii"))

    mdebug("Chunk #%d of %d ... DONE", ii, nchunks)
  } ## for (ii ...)
  mdebug("Launching %d futures (chunks) ... DONE", nchunks)
  
  
  ## Iterate
  fs <- list()
  for (ii in seq_along(argsList)) {
    if (debug) mdebug("- creating future #%d of %d ...", ii, nx)
    args <- argsList[[ii]]
    
    ## WORKAROUND: foreach::times() passes an empty string in 'argList[[*]]'
    names_args <- names(args)
    names_args <- names_args[nzchar(names_args)]
    if (debug) {
      mdebug("- foreach::`%%dopar%%` arguments: [%d] %s", length(args), paste(sQuote(names_args), collapse = ", "))
    }
    ## Internal sanity check of Globals object
    stopifnot(all(names_args %in% names(globals)))
    
    globals_ii <- globals
    for (name in names_args) globals_ii[[name]] <- args[[name]]
    ## Internal sanity check of Globals object
    stopifnot(length(attr(globals_ii, "where")) == length(globals_ii))
    if (debug) {
      mdebug("- future globals: [%d] %s", length(globals_ii), paste(sQuote(names(globals_ii)), collapse = ", "))
      mstr(globals_ii)
    }
    
    ## FIXME: Although foreach already provides us with
    ## globals and packages to load, the future() will do
    ## its own search and import of globals and packages.
    ## This is inefficient.  Ideally one should be able
    ## to setup a future where one specifies globals and
    ## packages explicitly. /HB 2016-05-04
    f <- eval({
      ## In case there's an error setting up the future, make sure to 
      ## move on to the next one and only signal the error below.
      ## NOTE: There shouldn't really be errors produced at this stage,
      ## but who knows. /HB 2017-03-11
      tryCatch({
        future(expr, substitute = FALSE, envir = envir,
               globals = globals_ii, packages = packages)
      }, error = identity)
    }, envir = envir)

    if (debug) mprint(f)
    
    fs[[ii]] <- f
    if (debug) mdebug("- creating future #%d of %d ... DONE", ii, nx)
  } ## for (ii ...)
  stopifnot(length(fs) == nx)

  ## Resolve futures
  if (debug) mdebug("- resolving future")
  resolve(fs, value=TRUE)

  ## Gather values
  if (debug) mdebug("- collecting values of future")
  results <- lapply(fs, FUN=value, signal=FALSE)
  stopifnot(length(results) == nx)


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
  stopifnot(length(results) == nx)


  ## throw an error or return the combined results
  ## NOTE: This is adopted from foreach:::doSEQ()
  errorHandling <- obj$errorHandling
  if (debug) mdebug("- processing errors (handler = %s)", sQuote(errorHandling))
  errorValue <- getErrorValue(it)
  if (identical(errorHandling, "stop") && !is.null(errorValue)) {
    errorIndex <- getErrorIndex(it)
    msg <- sprintf('task %d failed - "%s"', errorIndex,
                   conditionMessage(errorValue))
    stop(simpleError(msg, call=expr))
  }


  if (debug) mdebug("- extracting results")
  res <- getResult(it)

  if (debug) mdebug("doFuture() ... DONE")
  
  res
} ## doFuture()
