#' Options used by the doFuture adapter 
#'
#' Below are all \R options specific to the \pkg{doFuture} package.
#' For options controlling futures in general, see
#' [the options][future::future.options] for the \pkg{future} package.\cr
#' \cr
#' _WARNING: Note that the names and the default values of
#' these options may change in future versions of the package.
#' Please use with care until further notice._
#'
#' \describe{
#'  \item{\option{doFuture.foreach.export}:}{
#'    Specifies to what extent the \code{.export} argument of
#'    \code{\link[foreach]{foreach}()} should be respected or if globals
#'    should be automatically identified.
#' 
#'    If \code{".export"}, then the globals specified by the \code{.export}
#'    argument will be used "as is".
#' 
#'    If \code{"automatic"}, the future framework will be used to automatically
#'    identify globals.
#' 
#'    If \code{".export-and-automatic"}, then globals specified by
#'    \code{.export} as well as those automatically identified are used.
#' 
#'    If \code{"automatic-unless-.export"}, then globals are automatic
#'    identified if argument \code{.export} is missing or \code{NULL}.
#' 
#'    The \code{".export-and-automatic-with-warning"} is the same as
#'    \code{".export-and-automatic"}, but produces a warning if \code{.export}
#'    lacks some of the globals that the automatic identification locates
#'    - this is helpful feedback to developers using \code{foreach()}.
#' 
#'    (Default: \code{"automatic-unless-.export"})}
#'
#'  \item{\option{doFuture.debug}:}{If `TRUE`, extensive debug messages are
#'        generated. (Default: `FALSE`)}
#' }
#'
#' @keywords internal
#' @name doFuture.options
NULL
