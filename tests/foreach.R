library("doFuture")
oopts <- options(mc.cores=2L, warn=1L)
strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

message("*** doFuture() - reproducibility ...")
registerDoFuture()

res0 <- NULL

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  mu <- 1.0
  sigma <- 2.0
  res <- foreach(i=1:3, .packages="stats") %dopar% {
    set.seed(0xBEEF)
    rnorm(i, mean=mu, sd=sigma)
  }
  print(res)

  if (is.null(res0)) {
    res0 <- res
  } else {
    stopifnot(all.equal(res, res0))
  }

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** doFuture() - reproducibility ... DONE")

options(oopts)
