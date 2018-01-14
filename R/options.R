#' Options used by the doFuture adaptor 
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
#'  \item{\option{doFuture.globalsAs}:}{
#'    Specifies the method used to identify globals.
#'    For details on possible values, see [registerDoFuture()].
#'    The default method is `"future-unless-manuals"`.
#'  }
#'
#'  \item{\option{doFuture.debug}:}{If `TRUE`, extensive debug messages are
#'        generated. (Default: `FALSE`)}
#' }
#'
#' @keywords internal
#' @name doFuture.options
NULL
