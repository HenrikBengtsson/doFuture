#' Registers the future \%dopar\% backend
#'
#' Register the [doFuture] parallel adaptor to be used by
#' the \pkg{foreach} package.
#'
#' @param globalsAs A character string specifying how globals are identified.
#' 
#' @return Nothing
#'
#' @section Global variables:
#' Argument `globalsAs` controls how the doFuture backend/adaptor should
#' identify globals part of the foreach expression.  Below are is a set of
#' predefined method that can be used:
#' 
#' \describe{
#'  \item{`"manual"`}{Globals are given by the [foreach::foreach] argument
#'    `.export` and `.noexport` "as is".
#'  }
#'
#'  \item{`"foreach"`}{Globals are identified by [foreach::getexports] while
#'    respecting [foreach::foreach] arguments `.export` and `.noexport`.
#'  }
#'
#'  \item{`"future"`}{Globals are identified by the future framework, or more
#'    specifically by [future::getGlobalsAndPackages] while respecting
#'    [foreach::foreach] arguments `.export` and `.noexport`.
#'  }
#'
#'  \item{`"future-unless-manual"`}{Use the `"future"` approach unless
#'    argument `.export` is specified or is `NULL`.
#'  }
#' 
#'  \item{`"future-with-warning"`}{Use the `"future"` approach, but produce a
#'    warning if argument `.export` lacks some of the globals that
#'    [future::getGlobalsAndPackages] identifies.  This provides useful
#'    feedback to developers using `foreach()`.
#'  }
#' }
#'
#' The following aliases \emph{deprecated}:
#' \describe{
#'  \item{`".export"`}{Renamed to `"manual"`.}
#'  \item{`".export-and-automatic"`}{Renamed to `"future"`.}
#'  \item{`"automatic-unless-.export"`}{Renamed to `"future-unless-manual"`.}
#'
#'  \item{`".export-and-automatic-with-warning"`}{Renamed to
#'        `"future-with-warning"`.}
#' }
#' 
#' 
#' @importFrom future nbrOfWorkers
#' @importFrom foreach setDoPar
#' @importFrom utils packageVersion
#' @export
#' @keywords utilities
registerDoFuture <- function(globalsAs = getOption("doFuture.globalsAs", "future-unless-manual")) {  #nolint
  ## BACKWARD COMPATIBILITY
  if (!is.null(getOption("doFuture.globals.nullexport"))) {
    .Defunct(msg = "Option 'doFuture.globals.nullexport' is deprecated. Use 'doFuture.globalsAs = \"future-unless-manual\" or \"manual\" instead.")
  }
  
  t <- getOption("doFuture.foreach.export")
  if (!is.null(t) && is.null(getOption("doFuture.globalsAs"))) {
    if (t %in% c("automatic", "automatic-unless-.export")) {
      .Defunct(msg = sprintf("Option doFuture.foreach.export = %s is no longer supported. The closest is doFuture.globalsAs = 'future'.", dQuote(t)))
    }
    
    if (t == ".export-and-automatic") {
      globalsAs <- "future"
    } else if (t == ".export-and-automatic-with-warning") {
      globalsAs <- "future-with-warning"
    }

    .Deprecated(msg = sprintf("Option doFuture.foreach.export = %s is deprecated and has been replaced by doFuture.globalsAs = %s", dQuote(t), sQuote(globalsAs)))
  }
  stopifnot(is.character(globalsAs), length(globalsAs) == 1, !is.na(globalsAs))
  
  nullexport <- getOption("doFuture.globals.nullexport")
  
  info <- function(data, item) {
    switch(item,
      name = "doFuture",
      version = packageVersion("doFuture"),
      workers = nbrOfWorkers(),
    )
  }

  setDoPar(doFuture, data = list(globalsAs = globalsAs), info = info)
}
