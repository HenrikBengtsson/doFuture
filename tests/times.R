source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

message("*** times() ...")

res0 <- NULL

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  mu <- 1.0
  sigma <- 2.0
  res <- times(3L) %dopar% {
    set.seed(0xBEEF)
    rnorm(2L, mean = mu, sd = sigma)
  }
  print(res)

  if (is.null(res0)) {
    res0 <- res
  } else {
    stopifnot(all.equal(res, res0))
  }

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** times() ... DONE")

print(sessionInfo())

source("incl/end.R")
