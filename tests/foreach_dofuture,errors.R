source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

message("*** doFuture() - error handling w/ .errorhandling in c('stop', 'remove', 'pass') ...")

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  mu <- 1.0
  sigma <- 2.0

  for (.errorhandling in c("stop", "remove", "pass")) {
    message(sprintf(".errorhandling = '%s' ...", .errorhandling))
    
    truth <- tryCatch({
      foreach(i = 1:10, .errorhandling = .errorhandling) %dopar% {
        if (i %% 2 == 0) stop(sprintf("Index error ('stop'), because i = %d", i))
        list(i = i, value = dnorm(i, mean = mu, sd = sigma))
      }
    }, error = identity)
    str(truth)
    
    res <- tryCatch({
      foreach(i = 1:10, .errorhandling = .errorhandling) %dofuture% {
        if (i %% 2 == 0) stop(sprintf("Index error ('stop'), because i = %d", i))
        list(i = i, value = dnorm(i, mean = mu, sd = sigma))
      }
    }, error = identity)
    str(res)

    stopifnot(
      length(res) == length(truth),
      identical(names(res), names(truth)),
      all(mapply(res, truth, FUN = function(r, t) identical(class(r), class(t))))
    )
    if (.errorhandling == "stop") {
      stopifnot(
        inherits(res, "error"),
        grepl("Index error", conditionMessage(res)),
        identical(conditionMessage(res), conditionMessage(truth))
      )
    } else if (.errorhandling == "remove") {
      stopifnot(identical(res, truth))
    } else if (.errorhandling == "pass") {
      mapply(res, truth, FUN = function(r, t) {
        if (inherits(r, "error")) {
          r$call <- NULL
          t$call <- NULL
          stopifnot(identical(r, t))
        }
      })
    }

    message(sprintf(".errorhandling = '%s' ... done", .errorhandling))
  } ## for (.errorhandling ...)

  # Shutdown current plan
  plan(sequential)

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** doFuture() - error handling w/ .errorhandling in c('stop', 'remove', 'pass') ... DONE")


message("*** doFuture() - error handling w/ 'pass' ...")

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  mu <- 1.0
  sigma <- 2.0
  res <- foreach(i = 1:10, .errorhandling = "pass") %dofuture% {
    if (i %% 2 == 0) stop(sprintf("Index error ('pass'), because i = %d", i))
    list(i = i, value = dnorm(i, mean = mu, sd = sigma))
  }
  str(res)
  stopifnot(
    is.list(res),
    length(res) == 10L
  )
  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** doFuture() - error handling w/ 'pass' ... DONE")


message("*** doFuture() - error handling w/ 'remove' ...")

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  mu <- 1.0
  sigma <- 2.0
  res <- foreach(i = 1:10, .errorhandling = "remove") %dofuture% {
    if (i %% 2 == 0) stop(sprintf("Index error ('remove'), because i = %d", i))
    list(i = i, value = dnorm(i, mean = mu, sd = sigma))
  }
  str(res)
  stopifnot(
    is.list(res),
    length(res) == 5L
  )

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** doFuture() - error handling w/ 'remove' ... DONE")

message("*** doFuture() - invalid accumulator ...")

## This replicates how foreach:::doSEQ() handles it
boom <- function(...) stop("boom!")
res <- foreach(i = 1:3, .combine = boom) %dofuture% { i }
print(res)
stopifnot(is.null(res))

message("*** doFuture() - invalid accumulator ... DONE")

source("incl/end.R")
