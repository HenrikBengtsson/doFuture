source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

message("*** doFuture - reproducibility ...")

res0 <- NULL

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  mu <- 1.0
  sigma <- 2.0
  res <- foreach(i = 1:3, .packages = "stats") %dopar% {
    set.seed(0xBEEF)
    rnorm(i, mean = mu, sd = sigma)
  }
  print(res)

  if (is.null(res0)) {
    res0 <- res
  } else {
    stopifnot(all.equal(res, res0))
  }

  if (require(plyr, character.only = TRUE)) {
    message("*** dplyr w / doFuture + parallel ...")

    print(sessionInfo())

    x <- list(a = 1:10, beta = exp(-3:3), logic = c(TRUE, FALSE, FALSE, TRUE))
    y0 <- llply(x, quantile, probs = (1:3) / 4, .parallel = FALSE)
    print(y0)
    y1 <- llply(x, quantile, probs = (1:3) / 4, .parallel = TRUE)
    print(y1)
    stopifnot(all.equal(y1, y0))

    message("*** dplyr w / doFuture + parallel ... DONE")
  } ## if (require(plyr))

  if (require(BiocParallel, character.only = TRUE) &&
      packageVersion("BiocParallel") >= "1.2.22") {
    message("*** BiocParallel w / doFuture + parallel ...")

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

    message("*** BiocParallel w / doFuture + parallel ... DONE")
  } ## if (require(BiocParallel))

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** doFuture - reproducibility ... DONE")

print(sessionInfo())

source("incl/end.R")
