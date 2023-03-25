#' Evaluates a foreach `%dopar%` expression with the doRNG adapter
#'
#' @param expr An R [expression].
#'
#' @param substitute (logical) If TRUE, `expr` is substituted, otherwise not.
#'
#' @param envir The [environment] where to evaluate `expr`.
#'
#' @returns
#' The value of `expr`.
#'
#' @details
#' This function is useful when there is a foreach `%dopar%` expression that
#' uses the random-number generator (RNG).  Such code should ideally use
#' `%doRNG%` of the \pkg{doRNG} package instead of `%dopar%`.  Alternatively,
#' and second best, is if the code would temporarily register the **doRNG**
#' foreach adapter.  If neither is done, then there is a risk that the
#' random numbers are not statistically sound, e.g. they might be correlated.
#' For what it is worth, the **doFuture** adapter, which is set by
#' [`registerDoFuture()`], detects when **doRNG** is forgotten, and produced
#' an informative warning reminding us to use **doRNG**.
#'
#' If you do not have control over the foreach code, you can use
#' `withDoRNG()` to evaluate the foreach statement with
#' `doRNG::registerDoRNG()` temporarily set.
#'
#' @section Examples:
#' Consider a function:
#'
#' ```r
#' my_fcn <- function(n) {
#'   y <- foreach(i = seq_len(n)) %dopar% {
#'     stats::runif(n = 1L)
#'   }
#'   mean(unlist(y))
#' }
#' ```
#'
#' This function generates random numbers, but without involving \pkg{doRNG},
#' which risks generating poor randomness.  If we call it as-is, with the
#' **doFuture** adapter, we will get a warning about the problem:
#'
#' ```r
#' > my_fcn(10)
#' [1] 0.5846141
#' Warning message:
#' UNRELIABLE VALUE: One of the foreach() iterations ('doFuture-1')
#' unexpectedly generated random numbers without declaring so. There is a
#' risk that those random numbers are not statistically sound and the overall
#' results might be invalid. To fix this, use '%dorng%' from the 'doRNG'
#' package instead of '%dopar%'. This ensures that proper, parallel-safe
#' random numbers are produced via the L'Ecuyer-CMRG method. To disable this
#' check, set option 'doFuture.rng.onMisuse' to "ignore".
#' >
#' ```
#'
#' To fix this, we use `withDoRNG()` as:
#'
#' ```r
#' > withDoRNG(my_fcn(10))
#' [1] 0.535326
#' ```
#'
#' @importFrom foreach setDoPar
#' @export
withDoRNG <- function(expr, substitute = TRUE, envir = parent.frame()) {
  if (substitute) {
    expr <- substitute(expr)
  }
  
  oldDoPar <- .getDoPar()
  doRNG::registerDoRNG()
  on.exit(with(oldDoPar, setDoPar(fun=fun, data=data, info=info)))

  eval(expr, envir = envir, enclos = baseenv())
}
