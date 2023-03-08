#' doFuture: Foreach Parallel Adapter using Futures
#'
#' The \pkg{doFuture} package provides mechanisms for using the
#' \pkg{foreach} package together with the \pkg{future} package
#' such that `foreach()` parallelizes via _any_ future backend.
#'
#' @section Usage:
#' There are two alternative ways to use this package:
#'
#' 1. `y <- foreach(...) %dopar% { ... }` with `registerDoFuture()`
#' 2. `y <- foreach(...) %dofuture% { ... }`
#'
#' The _first alternative_ is based on the traditional **foreach**
#' approach where one registers a foreach adapter to be used by `%dopar%`.
#' A popular adapter is `doParallel::registerDoParallel()`, which
#' parallelizes on the local machine using the **parallel** package.
#' This package provides `registerDoFuture()`, which parallelizes using
#' the **future** package, meaning any future-compliant parallel backend
#' can be used.
#' An example is:
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
#' See [registerDoFuture()] for more details and examples on this approach.
#'
#' The _second alternative_, which uses `%dofuture%`, avoids having to use
#' `registerDoFuture()`.  The `%dofuture%` operator provides a more
#' consistent behavior than `%dopar%`, e.g. there is a unique set of
#' foreach arguments instead of one per possible adapter.  Identification
#' of globals, random number generation (RNG), and error handling is
#' handled by the future ecosystem, just like with other map-reduce
#' solutions such as **future.apply** and **furrr**.
#' An example is:
#'
#' ```r
#' library(doFuture)
#' plan(multisession)
#'
#' y <- foreach(x = 1:4, y = 1:10) %dofuture% {
#'   z <- x + y
#'   slow_sqrt(z)
#' }
#' ```
#'
#' See [`%dofuture%`] for more details and examples on this approach.
#'
#' @docType package
#' @aliases doFuture-package
#' @name doFuture
NULL
