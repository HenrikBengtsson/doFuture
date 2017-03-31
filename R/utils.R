mdebug <- function(...) {
  if (!getOption("doFuture.debug", FALSE)) return()
  message(paste(sprintf(...), collapse = "\n"))
}

#' @importFrom utils capture.output str
mstr <- function(...) {
  if (!getOption("doFuture.debug", FALSE)) return()
  message(paste(capture.output(str(...)), collapse = "\n"))
}

#' @importFrom utils capture.output
mprint <- function(...) {
  if (!getOption("doFuture.debug", FALSE)) return()
  message(paste(capture.output(print(...)), collapse = "\n"))
}

import_future <- function(name, mode = "function") {
  ns <- getNamespace("future")
  get(name, envir = ns, mode = "function")
}
