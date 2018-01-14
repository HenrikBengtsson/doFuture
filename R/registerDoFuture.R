#' Registers the future \%dopar\% backend
#'
#' Register the [doFuture] parallel adaptor to be used by
#' the \pkg{foreach} package.
#'
#' @param globalsAs A character string specifying the method on how globals
#' are identified in all [foreach::foreach()] calls including nested ones.
#' 
#' @return Nothing
#'
#' @section Global variables:
#' Argument `globalsAs` controls how the doFuture adaptor should identify
#' globals part of the foreach expression.  By specifying the argument when
#' registering the adaptor, that method of global identification will be
#' used until the adaptor is re-registered.
#' An alternative is to use `globalsAs = "*"` (default), which will cause
#' the global-identification method to be decided by option
#' \option{doFuture.globalsAs} at each call to [foreach::foreach()].
#' 
#' Below is the set of method that can be used for argument `globalsAs`
#' and option \option{doFuture.globalsAs}:
#' 
#' \describe{
#'  \item{`"manual"`}{No automatic identification of globals is done.
#'    Only the [foreach::foreach()] arguments .export` and `.noexport` are
#'    used to control what globals are exported.
#'  }
#'
#'  \item{`"foreach"`}{Globals are identified by [foreach::getexports()]
#'    while respecting arguments `.export` and `.noexport`.
#'  }
#'
#'  \item{`"future"`}{Globals are identified by the future framework,
#'    or more specifically by [future::getGlobalsAndPackages()],
#'    while respecting arguments `.export` and `.noexport`.
#'  }
#'
#'  \item{`"future-unless-manual"`}{(default) Use the `"future"` approach
#'    unless argument `.export` is specified (or is `NULL`).
#'  }
#' 
#'  \item{`"foreach-with-warning"`, `"future-with-warning"`}{
#'    Use the `"foreach"` or the `"future"` approach to identify globals,
#'    but produce a warning if argument `.export` lacks some of those
#'    automatically identified globals.
#'    This can provide helpful feedback to developers using `foreach()`.
#'  }
#' }
#'
#' The following aliases are \emph{deprecated}:
#' `".export"` (renamed to `"manual"`),
#' `".export-and-automatic"` (renamed to `"future"`),
#' `"automatic-unless-.export"` (renamed to `"future-unless-manual"`), and
#' `".export-and-automatic-with-warning"` (renamed to `"future-with-warning"`)
#'
#' 
#' @examples
#' ## Rely on the future framework to identify globals
#' registerDoFuture(globalsAs = "future")
#' 
#' ## Like doParallel, rely on the foreach framework to identify globals
#' registerDoFuture(globalsAs = "foreach")
#' 
#' 
#' @importFrom future nbrOfWorkers
#' @importFrom foreach setDoPar
#' @importFrom utils packageVersion
#' @export
#' @keywords utilities
registerDoFuture <- function(globalsAs = "*") {  #nolint
  info <- function(data, item) {
    switch(item,
      name = "doFuture",
      version = packageVersion("doFuture"),
      workers = nbrOfWorkers(),
    )
  }
  setDoPar(doFuture, data = list(globalsAs = globalsAs), info = info)
}
