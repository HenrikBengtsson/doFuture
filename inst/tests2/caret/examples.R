path <- system.file("tests2", "incl", package = "doFuture", mustWork = TRUE)
source(file.path(path, "utils.R"))
pkg <- tests2_step("start", package = "caret")

## WORKAROUND: Several of caret's foreach() calls use faulty '.export'
## specifications, i.e. not all globals are exported.
options(doFuture.foreach.export = "automatic")

## Packages used by some of the caret examples
#pkgs <- c("lattice", "mlbench", "earth", "mda", "MLmetrics")
#lapply(pkgs, FUN = loadNamespace)

mprintf("*** doFuture() - all %s examples ...", pkg)

for (strategy in test_strategies()) {
  mprintf("- plan('%s') ...", strategy)
  run_examples(pkg, strategy = strategy)
  mprintf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

mprintf("*** doFuture() - all %s examples ... DONE", pkg)

tests2_step("stop")
