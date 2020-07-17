source("incl/start.R")

if (require(BiocParallel, character.only = TRUE) &&
    packageVersion("BiocParallel") >= "1.2.22") {
  message("*** BiocParallel w / doFuture + parallel ...")

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
  
    y0 <- list()
    p <- SerialParam()
    y0$a <- bplapply(1:5, sqrt, BPPARAM = p)
    y0$b <- bpvec(1:5, sqrt, BPPARAM = p)
    str(y0)

    register(SerialParam(), default = TRUE)
    p <- DoparParam()
    y1 <- list()
    y1$a <- bplapply(1:5, sqrt, BPPARAM = p)
    y1$b <- bpvec(1:5, sqrt, BPPARAM = p)
    stopifnot(identical(y1, y0))

    register(DoparParam(), default = TRUE)
    y2 <- list()
    y2$a <- bplapply(1:5, sqrt, BPPARAM = p)
    y2$b <- bpvec(1:5, sqrt, BPPARAM = p)
    stopifnot(identical(y2, y0))
  
    message(sprintf("- plan('%s') ... DONE", strategy))
  } ## for (strategy ...)

  message("*** BiocParallel w / doFuture + parallel ... DONE")
} ## if (require(BiocParallel))

source("incl/end.R")
