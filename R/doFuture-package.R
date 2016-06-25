#' doFuture: Foreach Parallel Adaptor using Futures
#'
#' The \pkg{doFuture} package provides a \code{\%dopar\%} adaptor for
#' the \pkg{foreach} package such that \emph{any} type of future
#' (that is supported by Future API of the \pkg{future} package) can
#' be used for asynchronous (parallel/distributed) or synchronous
#' (sequential) processing.
#'
#' Futures themselves are provided by the \pkg{future} package, e.g.
#' multicore, multisession, ad hoc cluster, and MPI cluster futures.
#' Additional futures are provided by other packages.
#' For example, BatchJobs futures are implemented by the
#' \pkg{future.BatchJobs} package, which expands the support for
#' asynchronous processing to anything that the \pkg{BatchJobs}
#' package supports.
#'
#' To use futures with the \pkg{foreach} package, load \pkg{doFuture},
#' use \code{\link{registerDoFuture}()} to register
#' it to be used as a \code{\%dopar\%} adaptor, and select the type
#' of future you wish to use via \code{\link[future:plan]{plan()}}.
#'
#' @example incl/doFuture.R
#'
#' @docType package
#' @name doFuture
NULL