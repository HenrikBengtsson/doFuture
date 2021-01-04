## covr: skip=all
.onLoad <- function(libname, pkgname) {
  value <- getOption("doFuture.workarounds")
  if (is.null(value)) {
    value <- trim(Sys.getenv("R_DOFUTURE_WORKAROUNDS"))
    value <- unlist(strsplit(value, split = ",", fixed = TRUE))
    value <- trim(value)
    options(doFuture.workarounds = value)
  }
}
