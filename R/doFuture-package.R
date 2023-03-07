#' doFuture: Foreach Parallel Adapter using Futures
#'
#' The \pkg{doFuture} package provides mechanisms for using the
#' \pkg{foreach} package together with the \pkg{future} package
#' such that `foreach()` parallelizes via _any_ future backend.
#'
#' For example,
#'
#' ```r
#' library(doFuture)
#' registerDoFuture()
#' plan(multisession)
#'
#' y <- foreach(x = 1:4, y = 1:10) %dopar% {
#'   z <- x + y
#'   slow_sqrt(z)
#' }
#' ```
#'
#' will parallelize the foreach iterations on the local machine.
#'
#' For more details and examples, see [registerDoFuture()].
#'
#' @docType package
#' @aliases doFuture-package
#' @name doFuture
NULL
