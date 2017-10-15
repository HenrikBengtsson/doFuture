path <- system.file("tests2", "incl", package = "doFuture", mustWork = TRUE)
source(file.path(path, "utils.R"))
pkg <- tests2_step("start", package = "caret",
                   needs = c("Suggests",
                             "class", "ddalpha", "dimRed", "ggplot2", "ipred",
                             "lattice", "MASS", "Matrix", "nlme", "nnet",
                             "recipes", "rpart", "survival"))

excl <- "featurePlot"
excl <- getOption("doFuture.tests.topics.ignore", excl)
options(doFuture.tests.topics.ignore = excl)

## WORKAROUND: Several of caret's foreach() calls use faulty '.export'
## specifications, i.e. not all globals are exported.
options(doFuture.foreach.export = "automatic")

mprintf("*** doFuture() - all %s examples ...", pkg)

for (strategy in test_strategies()) {
  mprintf("- plan('%s') ...", strategy)
  run_examples(pkg, strategy = strategy)
  mprintf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

mprintf("*** doFuture() - all %s examples ... DONE", pkg)

tests2_step("stop")
