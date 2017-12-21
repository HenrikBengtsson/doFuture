#' Registers the future \%dopar\% backend
#'
#' Register the [doFuture] parallel adaptor to be used by
#' the \pkg{foreach} package.
#'
#' @return Nothing
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
      workers = nbrOfWorkers()
    )
  }

  setDoPar(doFuture, data = NULL, info = info)
}
