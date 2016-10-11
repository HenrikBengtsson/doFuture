#' @importFrom foreach getErrorIndex getErrorValue getResult makeAccum
#' @importFrom iterators iter
#' @importFrom future future resolve value
doFuture <- function(obj, expr, envir, data) {
  stopifnot(inherits(obj, "foreach"))
  stopifnot(inherits(envir, "environment"))

  ## Setup
  it <- iter(obj)
  argsList <- as.list(it)
  accumulator <- makeAccum(it)

  ## Global variables?
  export <- unique(obj$export)
  if (is.null(export)) {
    ## Automatic lookup of global variables by default
    ## NOTE: To fully emulate foreach's behavior in most
    ##       cases, we could disable this. /HB 2016-10-10
    globals <- getOption("doFuture.globals.nullexport", TRUE)
  } else {
    globals <- unique(c(export, it$argnames))
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
  expr <- substitute({ doFuture::registerDoFuture(); e }, list(e = expr))

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
    f <- future(expr, substitute=FALSE, envir=env, globals=globals)

    fs[[ii]] <- f
  } ## for (ii ...)

  ## Resolve futures
  resolve(fs, value=TRUE)

  ## Gather values
  results <- lapply(fs, FUN=value, signal=FALSE)


  ## Combine results (and identify errors)
  ## NOTE: This is adopted from foreach:::doSEQ()
  tryCatch({
    accumulator(results, tags=seq_along(results))
  }, error = function(e) {
    cat("error calling combine function:\n")
    print(e)
    NULL
  })


  ## throw an error or return the combined results
  ## NOTE: This is adopted from foreach:::doSEQ()
  errorValue <- getErrorValue(it)
  if (identical(obj$errorHandling, "stop") && !is.null(errorValue)) {
    errorIndex <- getErrorIndex(it)
    msg <- sprintf('task %d failed - "%s"', errorIndex,
                   conditionMessage(errorValue))
    stop(simpleError(msg, call=expr))
  }


  getResult(it)
} ## doFuture()
