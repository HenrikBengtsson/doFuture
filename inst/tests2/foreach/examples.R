path <- system.file("tests2", "incl", package = "doFuture", mustWork = TRUE)
source(file.path(path, "utils.R"))
pkg <- tests2_step("start", package = "foreach")

mprintf("*** doFuture() - all %s examples ...", pkg)

for (strategy in test_strategies()) {
  mprintf("- plan('%s') ...", strategy)
  run_examples(pkg, strategy = strategy, run.dontrun = TRUE)
  mprintf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

mprintf("*** doFuture() - all %s examples ... DONE", pkg)

tests2_step("stop")
