#' doFuture: Foreach Parallel Adapter using Futures
#'
#' The \pkg{doFuture} package provides a \code{\%dopar\%} adapter for
#' the \pkg{foreach} package such that _any_ type of future
#' (that is supported by Future API of the \pkg{future} package) can
#' be used for asynchronous (parallel/distributed) or synchronous
#' (sequential) processing.
#'
#' In other words, _if a computational backend is supported via
#' the Future API, it'll be automatically available for all functions
#' and packages making using the \pkg{foreach} framework._
#' Neither the developer nor the end user has to change any code.
#'
#' @section Usage:
#' To use futures with the \pkg{foreach} package, load \pkg{doFuture},
#' use [registerDoFuture()] to register it to be used as a
#' \code{\%dopar\%} adapter (no need to ever use \code{\%do\%}).
#' After this, how and where the computations are performed is controlled
#' solely by the future strategy set, which in controlled by
#' [future::plan()].  For example:
#'
#' * `plan(multisession)`: 
#'      multiple R processes on the local machine.
#' * `plan(cluster, workers = c("n1", "n2", "n2", "n3"))`:
#'      multiple R processes on external machines.
#'
#' See the \pkg{future} package for more examples.
#'
#' @section Built-in backends:
#' The built-in backends of \pkg{doFuture} are for instance 'multicore'
#' (forked processes), 'multisession' (background R sessions), and
#' ad-hoc 'cluster' (background R sessions on local and / or remote machines).
#' Additional futures are provided by other "future" packages
#' (see below for some examples).
#'
#' @section Backends for high-performance compute clusters:
#' The \pkg{future.batchtools} package provides support for high-performance
#' compute (HPC) cluster schedulers such as SGE, Slurm, and TORQUE / PBS.
#' For example,
#'
#' * `plan(batchtools_slurm)`:
#'      Process via a Slurm scheduler job queue.
#' * `plan(batchtools_torque)`:
#'      Process via a TORQUE / PBS scheduler job queue.
#' 
#' This builds on top of the queuing framework that the \pkg{batchtools}
#' package provides. For more details on backend configuration, please see
#' the \pkg{future.Batchtools} and \pkg{batchtools} packages.
#'
#' @section Global variables and packages:
#' Unless running locally in the global environment (= at the \R prompt),
#' the \pkg{foreach} package requires you do specify what global variables
#' and packages need to be available and attached in order for the
#' "foreach" expression to be evaluated properly.  It is not uncommon to
#' get errors on one or missing variables when moving from running a
#' \code{res <- foreach() \%dopar\% { ... }} statement on the local machine
#' to, say, another machine on the same network.  The solution to the
#' problem is to explicitly export those variables by specifying them in
#' the `.export` argument to [foreach::foreach()],
#' e.g. `foreach(..., .export = c("mu", "sigma"))`.  Likewise, if the
#' expression needs specific packages to be attached, they can be listed
#' in argument `.packages` of `foreach()`.
#'
#' When using `doFuture::registerDoFuture()`, the above becomes less
#' critical, because by default the Future API identifies all globals and
#' all packages automatically (via static code inspection).  This is done
#' exactly the same way regardless of future backend.
#' This automatic identification of globals and packages is illustrated
#' by the below example, which does _not_ specify
#' `.export = c("my_stat")`.  This works because the future framework
#' detects that function `my_stat()` is needed and makes sure it is
#' exported.  If you would use, say, `cl <- parallel::makeCluster(2)`
#' and `doParallel::registerDoParallel(cl)`, you would get a run-time
#' error on \code{Error in \{ : task 1 failed - \"could not find function "my_stat" ...}.
#'
#' Having said this, note that, in order for your "foreach" code to work
#' everywhere and with other types of foreach adapters as well, you may
#' want to make sure that you always specify arguments `.export`
#' and `.packages`.
#'
#' @section Load balancing ("chunking"):
#' Whether load balancing ("chunking") should take place or not can be
#' controlled by specifying either argument
#' `.options.future = list(scheduling = <ratio>)` or
#' `.options.future = list(chunk.size = <count>)` to `foreach()`.
#'
#' The value `chunk.size` specifies the average number of elements
#' processed per future ("chunks").
#' If `+Inf`, then all elements are processed in a single future (one worker).
#' If `NULL`, then argument `future.scheduling` is used.
#'
#' The value `scheduling` specifies the average number of futures
#' ("chunks") that each worker processes.
#' If `0.0`, then a single future is used to process all iterations;
#' none of the other workers are not used.
#' If `1.0` or `TRUE`, then one future per worker is used.
#' If `2.0`, then each worker will process two futures (if there are
#' enough iterations).
#' If `+Inf` or `FALSE`, then one future per iteration is used.
#' The default value is `scheduling = 1.0`.
#'
#' The name of `foreach()` argument `.options.future` follows the naming
#' conventions of the \pkg{doMC}, \pkg{doSNOW}, and \pkg{doParallel} packages,
#. i.e. `.options.multicore` and `.options.snow`.
#' _This argument should not be mistaken for the \R
#' \link[future:future.options]{options of the future package}_.
#'
#' For backward-compatibility reasons with existing foreach code, one may
#' also use arguments `.options.multicore = list(preschedule = <logical>)` and
#' `.options.snow = list(preschedule = <logical>)` when using \pkg{doFuture}.
#" Using the latter corresponds to the following `.options.future` settings:
#' `.options.multicore = list(preschedule = TRUE)` is equivalent to
#' `.options.future = list(scheduling = 1.0)` and
#' `.options.multicore = list(preschedule = FALSE)` is equivalent to
#' `.options.future = list(scheduling = +Inf)`.
#' and analogously for `.options.snow`.
#' Argument `.options.future` takes precedence over argument 
#' `.option.multicore` which takes precedence over argument `.option.snow`,
#' when it comes to chunking.
#'
#' @section Random Number Generation (RNG):
#' The \pkg{doFuture} package does _not_ itself provide a framework
#' for generating proper random numbers in parallel. This is a deliberate
#' design choice based on how the foreach ecosystem is set up.  For valid
#' parallel RNG, it is recommended to use the \pkg{doRNG} package, where
#' the \code{\link[doRNG:\%dorng\%]{\%dorng\%}} operator is used in place
#' of \code{\link[foreach:\%dopar\%]{\%dopar\%}}.
#' Note that \pkg{doRNG} is designed to work with any type of foreach
#' adapter including \pkg{doFuture}.
#'
#' @example incl/doFuture.R
#'
#' @docType package
#' @aliases doFuture-package
#' @name doFuture
NULL
