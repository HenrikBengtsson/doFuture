#' Options used by the doFuture adaptor 
#'
#' Below are all \R options specific to the \pkg{doFuture} package.
#' For options controlling futures in general,
#' see \link[future:future.options]{the options} for the
#' \pkg{future} package.\cr
#' \cr
#' \emph{WARNING: Note that the names and the default values of
#' these options may change in future versions of the package.
#' Please use with care until further notice.}
#'
#' @section Options for controlling futures:
#' \describe{
#'  \item{\option{doFuture.foreach.export}:}{
#'    Specifies to what extent the \code{.export} argument of
#'    \code{\link[foreach]{foreach}()} should be respected or if globals
#'    should be automatically identified.
#'    If \code{".export"}, then the globals specified by the \code{.export}
#'    argument will be used "as is".
#'    If \code{"automatic"}, the future framework will be used to automatically
#'    identify globals.
#'    If \code{".export-and-automatic"}, then globals specified by
#'    \code{.export} as well as those automatically identified are used.
#'    If \code{"automatic-unless-.export"}, then globals are automatic
#'    identified if argument \code{.export} is missing or \code{NULL}.
#'    (Default: \code{"automatic-unless-.export"})}
#' }
#'
#' @section Options for debugging:
#' \describe{
#'  \item{\option{doFuture.debug}:}{If \code{TRUE}, extensive debug messages are generated. (Default: \code{FALSE})}
#' }
#'
#' @keywords internal
#' @name doFuture.options
NULL
