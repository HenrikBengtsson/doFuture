library("future")

options(warnPartialMatchArgs=FALSE)
ovars <- ls(all.names=TRUE)
oopts <- options(mc.cores=2L, warn=1L, digits=3L)

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")
if (require("future.BatchJobs")) strategies <- c(strategies, "batchjobs")
strategies <- getOption("doFuture.tests.strategies", strategies)


message("*** BiocParallel w/ DoparParam and doFuture() ...")

library("BiocParallel")
register(SerialParam(), default=TRUE)


library("doFuture")
registerDoFuture()

res0 <- list()
p <- SerialParam()
res0$a <- bplapply(1:5, sqrt, BPPARAM=p)
res0$b <- bpvec(1:5, sqrt, BPPARAM=p)
str(res0)


for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)
  registerDoFuture()

  register(SerialParam(), default=TRUE)
  p <- DoparParam()
  res1 <- list()
  res1$a <- bplapply(1:5, sqrt, BPPARAM=p)
  res1$b <- bpvec(1:5, sqrt, BPPARAM=p)
  stopifnot(identical(res1, res0))

  register(DoparParam(), default=TRUE)
  res2 <- list()
  res2$a <- bplapply(1:5, sqrt, BPPARAM=p)
  res2$b <- bpvec(1:5, sqrt, BPPARAM=p)
  stopifnot(identical(res2, res0))

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** BiocParallel w/ DoparParam and doFuture() ... DONE")

## CLEANUP
register(SerialParam(), default=TRUE)
options(oopts)
rm(list=setdiff(ls(all.names=TRUE), ovars))
