#' Registers the future %dopar% backend
#'
#' Register the [doFuture] parallel adapter to be used by
#' the \pkg{foreach} package.
#'
#' @return Nothing
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
  
  setDoPar(doFuture, info = info)
}
