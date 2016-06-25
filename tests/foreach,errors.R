source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

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

message("*** doFuture() - invalid accumulator ...")

## This replicates how foreach:::doSEQ() handles it
boom <- function(...) stop("boom!")
res <- foreach(i = 1:3, .combine=boom) %dopar% { i }
print(res)
stopifnot(is.null(res))

message("*** doFuture() - invalid accumulator ... DONE")

print(sessionInfo())

source("incl/end.R")

