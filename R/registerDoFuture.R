#' Registers the future \%dopar\% backend
#'
#' @return Nothing
#'
#' @importFrom foreach setDoPar
#' @importFrom utils packageVersion
#' @export
#' @keywords utilities
registerDoFuture <- function() {
  info <- function(data, item) {
    switch(item,
      name = "doFuture",
      version = packageVersion("doFuture")
    )
  }
  setDoPar(doFuture, data=NULL, info=info)
}
