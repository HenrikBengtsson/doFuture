#' Registers the future \%dopar\% backend
#'
#' @return Nothing
#'
#' @importFrom foreach setDoPar
#' @export
#' @keywords utilities
registerDoFuture <- function() {
  setDoPar(doFuture)
}
