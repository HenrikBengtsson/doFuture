library("doFuture")
oopts <- options(mc.cores=2L, warn=1L)
strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

registerDoFuture()

message("*** doFuture() - error handling w/ 'stop' ...")

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  mu <- 1.0
  sigma <- 2.0

  res <- try({
    foreach(i=1:10, .errorhandling="stop") %dopar% {
      set.seed(0xBEEF)
      if (i %% 2 == 0) stop(sprintf("Index error %d", i))
      rnorm(i, mean=mu, sd=sigma)
    }
  })
  str(res)
  stopifnot(inherits(res, "try-error"))

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** doFuture() - error handling w/ 'stop' ... DONE")


message("*** doFuture() - error handling w/ 'pass' ...")

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  mu <- 1.0
  sigma <- 2.0
  res <- foreach(i=1:10, .errorhandling="pass") %dopar% {
    set.seed(0xBEEF)
    if (i %% 2 == 0) stop(sprintf("Index error %d", i))
    rnorm(i, mean=mu, sd=sigma)
  }
  str(res)

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** doFuture() - error handling w/ 'pass' ... DONE")


message("*** doFuture() - error handling w/ 'remove' ...")

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  mu <- 1.0
  sigma <- 2.0
  res <- foreach(i=1:10, .errorhandling="remove") %dopar% {
    set.seed(0xBEEF)
    if (i %% 2 == 0) stop(sprintf("Index error %d", i))
    rnorm(i, mean=mu, sd=sigma)
  }
  str(res)

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** doFuture() - error handling w/ 'remove' ... DONE")

options(oopts)
