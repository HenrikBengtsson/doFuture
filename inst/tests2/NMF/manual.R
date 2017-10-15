path <- system.file("tests2", "incl", package = "doFuture", mustWork = TRUE)
source(file.path(path, "utils.R"))
install_missing_packages(c("cluster", "lattice", "MASS"))
pkg <- tests2_step("start", package = "NMF")

mprintf("*** doFuture() - manual %s tests ...", pkg)

## From NMF vignette
## run on all workers using the current parallel backend
data("esGolub", package = "NMF")
res_truth <- nmf(esGolub, rank = 3L, method = "brunet", nrun = 2L, .opt = "p",
                 seed = 0xBEEF)

for (strategy in test_strategies()) {
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

tests2_step("stop")
