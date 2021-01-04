#' Registers the future %dopar% backend
#'
#' Register the [doFuture] parallel adapter to be used by
#' the \pkg{foreach} package.
#'
#' @return Nothing
#'
#' @section For package developers:
#' Please refrain from modifying the foreach backend inside your packages /
#' functions, i.e. do not call `registerNnn()` in your code.  Instead, leave
#' the control on what backend to use to the end user.  This idea is part of
#' the core philosophy of the foreach framework.
#'
#' However, if you think it necessary to register the \pkg{doFuture} backend
#' in a function, please make sure to undo your changes when exiting the
#' function.
#' This can be done using:
#'
#' \preformatted{
#'   oldDoPar <- registerDoFuture()
#'   on.exit(with(oldDoPar, foreach::setDoPar(fun=fun, data=data, info=info)), add = TRUE)
#'   [...]
#' }
#'
#' This is important because the end-user might have already registered a
#' foreach backend elsewhere for other purposes and will most likely not known
#' that calling your function will break their setup.
#' _Remember, your package and its functions might be used in a greater
#' context where multiple packages and functions are involved and those might
#' also rely on the foreach framework, so it is important to avoid stepping on 
#' others' toes._
#'
#' @examples
#' registerDoFuture()
#' 
#' @importFrom future nbrOfWorkers
#' @importFrom foreach setDoPar
#' @importFrom utils packageVersion
#' @export
#' @keywords utilities
registerDoFuture <- function() {  #nolint
  info <- function(data, item) {
    switch(item,
      name = "doFuture",
      version = packageVersion("doFuture"),
      workers = nbrOfWorkers(),
    )
  }

  ## Tell doRNG (>= 1.8.2) to not check the RNG type
  value <- getOption("doRNG.rng_change_warning_skip")
  if (!isTRUE(value)) {
    if (isFALSE(value)) {
      warning("doRNG option 'doRNG.rng_change_warning_skip' was set to FALSE, which was overridden by doFuture::registerDoFuture()")
      value <- NULL
    }
    
    ## Append to existing character vector, if any
    value <- unique(c(value, "doFuture"))
    
    options(doRNG.rng_change_warning_skip = value)
  }

  ## WORKAROUND:
  ## Until https://github.com/RevolutionAnalytics/foreach/issues/19
  ## is supported. /HB 2020-12-28
  oldDoPar <- .getDoPar()

  setDoPar(doFuture, info = info)

  invisible(oldDoPar)
}


.getDoPar <- function() {
  ns <- getNamespace("foreach")
  .foreachGlobals <- get(".foreachGlobals", envir = ns)
  if (exists("fun", envir = .foreachGlobals, inherits = FALSE)) {
    structure(list(
      fun  = .foreachGlobals$fun,
      data = .foreachGlobals$data, 
      info = .foreachGlobals$info
    ), class = "DoPar")
  } else {
    structure(list(
      fun  = get("doSEQ", mode = "function", envir = ns),
      data = NULL,
      info = NULL
    ), class = c("DoPar", "DoSeq"))
  }
}
