mprintf <- function(...) message(sprintf(...))

## Package for which examples should be run
pkg <- "NMF"

mprintf("*** doFuture() - manual %s tests ...", pkg)

library("future")
options(warnPartialMatchArgs = FALSE)
oopts <- options(mc.cores = 2L, warn = 1L, digits = 3L)

strategies <- getOption("doFuture.tests.strategies",
                        c("sequential", "multisession"))
strategies <- unlist(strsplit(strategies, split = "[, ]"))
strategies <- strategies[nzchar(strategies)]
## Default is to use what's provided by the future package
if (length(strategies) == 0) {
  strategies <- future:::supportedStrategies()
  strategies <- setdiff(strategies, c("multiprocess", "lazy", "eager"))
}
if (any(grepl("batchjobs_", strategies))) library("future.BatchJobs")
if (any(grepl("batchtools_", strategies))) library("future.batchtools")

library("doFuture")
registerDoFuture()
library(pkg, character.only = TRUE)

## From NMF vignette
## run on all workers using the current parallel backend
data("esGolub", package = "NMF")
res_truth <- nmf(esGolub, rank = 3L, method = "brunet", nrun = 2L, .opt = "p",
                 seed = 0xBEEF)

for (strategy in strategies) {
  mprintf("- plan('%s') ...", strategy)

  ## Workaround for https://github.com/HenrikBengtsson/future/issues/166
  ns <- getNamespace("future")
  strategy_fcn <- get(strategy, envir = ns, mode = "function")
  plan(strategy_fcn)

  registerDoFuture()

  res <- nmf(esGolub, rank = 3L, method = "brunet", nrun = 2L, .opt = "p",
             seed = 0xBEEF, .pbackend = NULL)
  str(res)
  stopifnot(all.equal(res, res_truth, check.attributes = FALSE))
  
  mprintf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

mprintf("*** doFuture() - manual %s tests ... DONE", pkg)

options(oopts)
