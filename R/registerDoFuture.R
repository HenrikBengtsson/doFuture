#' Use the Foreach `%dopar%` Adapter with Futures
#'
#' The `registerDoFuture()` function makes the
#' \code{\link[foreach:\%dopar\%]{\%dopar\%}} operator of the
#' \pkg{foreach} package to process foreach iterations via any of
#' the future backends supported by the \pkg{future} package, which
#' includes various parallel and distributed backends.
#' In other words, _if a computational backend is supported via
#' the Future API, it'll be automatically available for all functions
#' and packages making using the \pkg{foreach} framework._
#' Neither the developer nor the end user has to change any code.
#'
#' @section Parallel backends:
#' To use futures with the \pkg{foreach} package and its
#' \code{\link[foreach:\%dopar\%]{\%dopar\%}} operator, use
#' `doFuture::registerDoFuture()` to register \pkg{doFuture} to be
#' used as a `%dopar%` adapter.  After this, `%dopar%` will
#' parallelize with whatever \pkg{future} backend is set by
#' [future::plan()].
#'
#' The built-in \pkg{future} backends are always available, e.g.
#' \link[future:sequential]{sequential} (sequential processing),
#' \link[future:multicore]{multicore} (forked processes),
#' \link[future:multisession]{multisession} (background R sessions),
#' and \link[future:cluster]{cluster} (background R sessions on
#' local and remote machines).
#' For example, `plan(multisession)` will make `%dopar%`
#' parallelize via R processes running in the background on the
#' local machine, and
#' `plan(cluster, workers = c("n1", "n2", "n2", "n3"))` will
#' parallelize via R processes running on external machines.
#'
#' Additional backends are provided by other future-compliant
#' packages.  For example, the \pkg{future.batchtools} package
#' provides support for high-performance compute (HPC) cluster
#' schedulers such as SGE, Slurm, and TORQUE / PBS.
#' As an illustration, `plan(batchtools_slurm)` will parallelize
#' by submitting the foreach iterations as tasks to the Slurm
#' scheduler, which in turn will distribute the tasks to one
#' or more compute nodes.
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
#' When using `registerDoFuture()`, the above becomes less
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
#' The doFuture adapter registered by `registerDoFuture()` does _not_ itself 
#' provide a framework for generating proper random numbers in parallel. 
#' This is a deliberate design choice based on how the foreach ecosystem is
#' set up and to align it with other foreach adapters, e.g. **doParallel**.
#' To generate statistically sound parallel RNG, it is recommended to use
#' the \pkg{doRNG} package, where the \code{\link[doRNG:\%dorng\%]{\%dorng\%}}
#' operator is used in place of \code{\link[foreach:\%dopar\%]{\%dopar\%}}.
#' For example,
#'
#' ```r
#' y <- foreach(i = 1:3) %dorng% {
#'   rnorm(1)
#' }
#' ```
#'
#' This works because \pkg{doRNG} is designed to work with any type of foreach
#' `%dopar%` adapter including the one provided by \pkg{doFuture}.
#'
#' If you forget to use `%dorng%` instead of `%dopar%` when the foreach 
#' iteration generates random numbers, \pkg{doFuture} will detect the
#' mistake and produce an informative warning.
#'
#' @section For package developers:
#' Please refrain from modifying the foreach backend inside your package or
#' functions, i.e. do not call any `registerNnn()` in your code.  Instead, 
#' leave the control on what backend to use to the end user.  This idea is
#' part of the core philosophy of the \pkg{foreach} framework.
#'
#' However, if you think it necessary to register the \pkg{doFuture} backend
#' in a function, please make sure to undo your changes when exiting the
#' function. This can be done using:
#'
#' \preformatted{
#'   oldDoPar <- registerDoFuture()
#'   on.exit(with(oldDoPar, foreach::setDoPar(fun=fun, data=data, info=info)), add = TRUE)
#'   [...]
#' }
#'
#' This is important, because the end-user might have already registered a
#' foreach backend elsewhere for other purposes and will most likely not known
#' that calling your function will break their setup.
#' _Remember, your package and its functions might be used in a greater
#' context where multiple packages and functions are involved and those might
#' also rely on the foreach framework, so it is important to avoid stepping on 
#' others' toes._
#'
#' @return 
#' `registerDoFuture()` returns, invisibly, the previously registered 
#' foreach `%dopar%` backend.
#'
#' @example incl/doFuture.R
#' 
#' @importFrom future nbrOfWorkers
#' @importFrom foreach setDoPar
#' @importFrom utils packageVersion
#' @export
#' @keywords utilities
registerDoFuture <- function() {  #nolint
  info <- function(data, item) {
    switch(item,
      name = "doFuture",
      version = packageVersion("doFuture"),
      workers = nbrOfWorkers(),
    )
  }

  ## Tell doRNG (>= 1.8.2) to not check the RNG type
  value <- getOption("doRNG.rng_change_warning_skip")
  if (!isTRUE(value)) {
    if (isFALSE(value)) {
      warning("doRNG option 'doRNG.rng_change_warning_skip' was set to FALSE, which was overridden by doFuture::registerDoFuture()")
      value <- NULL
    }
    
    ## Append to existing character vector, if any
    value <- unique(c(value, "doFuture"))
    
    options(doRNG.rng_change_warning_skip = value)
  }

  ## WORKAROUND:
  ## Until https://github.com/RevolutionAnalytics/foreach/issues/19
  ## is supported. /HB 2020-12-28
  oldDoPar <- .getDoPar()

  setDoPar(doFuture, info = info)

  invisible(oldDoPar)
}


.getDoPar <- function() {
  ns <- getNamespace("foreach")
  .foreachGlobals <- get(".foreachGlobals", envir = ns)
  if (exists("fun", envir = .foreachGlobals, inherits = FALSE)) {
    structure(list(
      fun  = .foreachGlobals$fun,
      data = .foreachGlobals$data, 
      info = .foreachGlobals$info
    ), class = "DoPar")
  } else {
    structure(list(
      fun  = get("doSEQ", mode = "function", envir = ns),
      data = NULL,
      info = NULL
    ), class = c("DoPar", "DoSeq"))
  }
}
