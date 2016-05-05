#' @importFrom foreach getErrorIndex getErrorValue getResult makeAccum
#' @importFrom iterators iter
#' @importFrom future future values
doFuture <- function(obj, expr, envir, data) {
  stopifnot(inherits(obj, "foreach"))
  stopifnot(inherits(envir, "environment"))

  ## Setup
  it <- iter(obj)
  argsList <- as.list(it)
  accumulator <- makeAccum(it)

  ## Any packages to be on the search path?
  pkgs <- obj$packages
  if (length(pkgs) > 0L) {
    exprs <- lapply(pkgs, FUN=function(pkg) {
      parse(text=sprintf('library("%s")', pkg))
    })
    exprs <- c(exprs, expr)
    expr <- Reduce(function(a, b) {
      substitute({ a; b }, list(a=a, b=b))
    }, x=exprs)
  }

  ## Iterate
  fs <- list()
  for (ii in seq_along(argsList)) {
    args <- argsList[[ii]]

    ## "Export" arguments to future environment
    env <- new.env(parent=envir)
    for (name in names(args)) env[[name]] <- args[[name]]

    ## FIXME: Although foreach already provides us with
    ## globals and packages to load, the future() will do
    ## its own search and import of globals and packages.
    ## This is inefficient.  Ideally one should be able
    ## to setup a future where one specifies globals and
    ## packages explicitly. /HB 2016-05-04
    f <- future(expr, substitute=FALSE, envir=env)

    fs[[ii]] <- f
  } ## for (ii ...)

  ## Resolve futures
  results <- values(fs)

  ## check for errors before calling combine function if error handling
  ## is 'stop' so we can exit early
  if (identical(obj$errorHandling, "stop")) {
    errorIndex <- 1L
    for (r in results) {
      if (inherits(r, "error")) {
        msg <- sprintf('task %d failed - "%s"', errorIndex,
                       conditionMessage(r))
        stop(simpleError(msg, call=expr))
      }
      errorIndex <- errorIndex + 1L
    }
  }


  ## Combine results
  tryCatch({
    accumulator(results, tags=seq_along(results))
  }, error = function(e) {
    cat("error calling combine function:\n")
    print(e)
    NULL
  })


  ## check for errors
  errorValue <- getErrorValue(it)
  errorIndex <- getErrorIndex(it)

  ## throw an error or return the combined results
  if (identical(obj$errorHandling, "stop") && !is.null(errorValue)) {
    msg <- sprintf('task %d failed - "%s"', errorIndex,
                   conditionMessage(errorValue))
    stop(simpleError(msg, call=expr))
  }

  getResult(it)
} ## doFuture()
