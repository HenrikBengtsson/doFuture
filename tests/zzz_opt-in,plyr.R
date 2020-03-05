source("incl/start.R")

if (require(plyr, character.only = TRUE)) {
  message("*** dplyr w / doFuture + parallel ...")

  strategies <- future:::supportedStrategies()
  strategies <- setdiff(strategies, "multiprocess")

  res0 <- NULL
  
  for (strategy in strategies) {
    message(sprintf("- plan('%s') ...", strategy))
    plan(strategy)
  
    mu <- 1.0
    sigma <- 2.0
    res <- foreach(i = 1:3, .packages = "stats") %dopar% {
      dnorm(i, mean = mu, sd = sigma)
    }
    print(res)
  
    if (is.null(res0)) {
      res0 <- res
    } else {
      stopifnot(all.equal(res, res0))
    }
  
    print(sessionInfo())

    x <- list(a = 1:10, beta = exp(-3:3), logic = c(TRUE, FALSE, FALSE, TRUE))
    y0 <- llply(x, quantile, probs = (1:3) / 4, .parallel = FALSE)
    print(y0)
    y1 <- llply(x, quantile, probs = (1:3) / 4, .parallel = TRUE)
    print(y1)
    stopifnot(all.equal(y1, y0))
  
    message(sprintf("- plan('%s') ... DONE", strategy))
  } ## for (strategy ...)

  message("*** dplyr w / doFuture + parallel ... DONE")
} ## if (require(plyr))

print(sessionInfo())

source("incl/end.R")
