path <- system.file("tests2", "incl", package = "doFuture", mustWork = TRUE)
source(file.path(path, "utils.R"))
install_missing_packages(c("cluster", "lattice", "MASS", "Matrix"))
pkg <- tests2_step("start", package = "glmnet",
                   needs = c("Suggests"))

## WORKAROUND: Some of the glmnet examples tries to use more parallel cores
## than accepted by R CMD check, i.e. more than two.  This avoids that.
if (require("doMC")) {
  registerDoMC <- function(cores, ...) {
    doMC::registerDoMC(cores = min(2L, cores))
  }
}

mprintf("*** doFuture() - all %s examples ...", pkg)

for (strategy in test_strategies()) {
  mprintf("- plan('%s') ...", strategy)
  run_examples(pkg, strategy = strategy, run.dontrun = TRUE)
  mprintf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

mprintf("*** doFuture() - all %s examples ... DONE", pkg)

tests2_step("stop")
