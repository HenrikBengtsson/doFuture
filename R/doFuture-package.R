#' doFuture: Foreach Parallel Adaptor using Futures
#'
#' The \pkg{doFuture} package provides a \code{\%dopar\%} adaptor for
#' the \pkg{foreach} package such that \emph{any} type of future
#' (that is supported by Future API of the \pkg{future} package) can
#' be used for asynchronous (parallel/distributed) or synchronous
#' (sequential) processing.
#' 
#' In other words, \emph{if a computational backend is supported via
#' the Future API, it'll be automatically available for all functions
#' and packages making using the \pkg{foreach} framework.}
#' Neither the developer nor the end user has to change any code.
#'
#' @section Usage:
#' To use futures with the \pkg{foreach} package, load \pkg{doFuture},
#' use \code{\link{registerDoFuture}()} to register it to be used as a
#' \code{\%dopar\%} adaptor (need to ever use \code{\%do\%}).
#' After this, how and where the computations are performed is controlled
#' solely by the future strategy set, which in controlled by
#' \code{\link[future:plan]{future::plan}()}.  For example:
#'
#' \itemize{
#'  \item {\code{plan(multiprocess)}: }{multiple R processes on the local machine.}
#'  \item {\code{plan(cluster, workers = c("n1", "n2", "n2", "n3"))}: }{multiple R processes on external machines.}
#' }
#'
#' See the \pkg{future} package for more examples.
#' 
#' @section Built-in backends:
#' The built-in backends of \pkg{doFuture} are for instance multicore
#' (forked processes), multisession (background R sessions), and
#' ad-hoc cluster (background R sessions on local and / or remote machines).
#' Additional futures are provided by other "future" packages (see below for some examples).
#' 
#' @section Backends for high-performance compute clusters:
#' The \pkg{future.BatchJobs} package provides support for high-performance
#' compute (HPC) cluster schedulers such as SGE, Slurm, and TORQUE / PBS.
#' For example,
#' \itemize{
#'  \item {\code{plan(batchjobs_slurm)}: }{Process via a Slurm scheduler job queue.}
#'  \item {\code{plan(batchjobs_torque)}: }{Process via a TORQUE / PBS scheduler job queue.}
#' }
#' This builds on top of the queuing framework that the \pkg{BatchJobs}
#' package provides. For more details on backend configuration, please see
#' the \pkg{future.BatchJobs} and \pkg{BatchJobs} packages.
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
#' the \code{.export} argument to \code{\link[foreach:foreach]{foreach}()},
#' e.g. \code{foreach(..., .export = c("mu", "sigma"))}.  Likewise, if the
#' expression needs specific packages to be attached, they can be listed
#' in argument \code{.packages} of \code{foreach()}.
#'
#' When using \code{doFuture::registerDoFuture()}, the above becomes less
#' critical, because by default the Future API identifies all globals and
#' all packages automatically (via static code inspection).  This is done
#' exactly the same way regardless of future backend.
#' This automatic identification of globals and packages is illustrated
#' by the below example, which does \emph{not} specify
#' \code{.export = c("my_stat")}.  This works because the future framework
#' detects that function \code{my_stat()} is needed and makes sure it is
#' exported.  If you would use, say, \code{cl <- parallel::makeCluster(2)}
#' and \code{doParallel::registerDoParallel(cl)}, you would get a run-time
#' error on 'Error in \{ : task 1 failed - "could not find function "my_stat"'.
#'
#' Having said this, note that, in order for your "foreach" code to work
#' everywhere and with other types of foreach adaptors as well, you may
#' want to make sure that you always specify arguments \code{.export}
#' and \code{.packages}.
#' 
#' @example incl/doFuture.R
#'
#' @docType package
#' @name doFuture
NULL
