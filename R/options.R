#' Options used by the doFuture adaptor 
#'
#' Below are all \R options specific to the \pkg{doFuture} package.
#' For options controlling futures in general,
#' see [the options][future::future.options] for the
#' \pkg{future} package.\cr
#' \cr
#' _WARNING: Note that the names and the default values of
#' these options may change in future versions of the package.
#' Please use with care until further notice._
#'
#' @section Options for controlling futures:
#' \describe{
#'  \item{\option{doFuture.globalsAs}:}{
#'    Specifies to what extent the `.export` argument of
#'    [foreach::foreach()] should be respected or if globals
#'    should be automatically identified.
#' 
#'    If `".export"`, then the globals specified by the `.export`
#'    argument will be used "as is".
#' 
#'    If `"foreach+.export"`, then the globals identified by
#'    [foreach::getexports] and those specified by the `.export` argument will
#'    be used.  This is setting emulates how the doParallel package works.
#' 
#'    If `"automatic"`, the future framework will be used to automatically
#'    identify globals.
#' 
#'    If `".export-and-automatic"`, then globals specified by
#'    `.export` as well as those automatically identified are used.
#' 
#'    If `"automatic-unless-.export"`, then globals are automatic
#'    identified if argument `.export` is missing or `NULL`.
#' 
#'    The `".export-and-automatic-with-warning"` is the same as
#'    `".export-and-automatic"`, but produces a warning if `.export`
#'    lacks some of the globals that the automatic identification locates
#'    - this is helpful feedback to developers using `foreach()`.
#' 
#'    (Default: `"automatic-unless-.export"`)
#'  }
#' }
#'
#' @section Options for debugging:
#' \describe{
#'  \item{\option{doFuture.debug}:}{If `TRUE`, extensive debug messages are
#'        generated. (Default: `FALSE`)}
#' }
#'
#' @section Deprecated options:
#' \describe{
#'  \item{\option{doFuture.foreach.export}:}{This option has been renamed and
#'        is deprecated. Use \option{doFuture.globalsAs} instead.}
#' }
#'
#' @keywords internal
#' @name doFuture.options
NULL
