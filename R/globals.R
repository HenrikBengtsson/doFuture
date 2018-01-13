#' @importFrom foreach getexports
#' @importFrom globals findGlobals
findGlobals_foreach <- function(expr, envir = parent.frame(), noexport = NULL) {
  ## Extracted from doParallel 1.0.11
  makeDotsEnv <- function(...) {
    list(...)
    function() NULL
  }

  exportenv <- tryCatch({
    qargs <- quote(list(...))
    args <- eval(qargs, envir = envir)
    environment(do.call(makeDotsEnv, args = args))
  }, error = function(e) {
    new.env(parent = emptyenv())
  })

  ## NOTE: getexports() does not identify '...'
  getexports(expr, e = exportenv, env = envir, bad = noexport)
  globals <- ls(envir = exportenv)

  ## Is '...' a global?
  if (is.element("...", findGlobals(expr, dotdotdot = "return"))) {
    globals <- c(globals, "...")
  }
  
  globals
}
