path <- system.file("tests2", "incl", package = "doFuture", mustWork = TRUE)
source(file.path(path, "utils.R"))
install_missing_packages(c("class", "cluster", "lattice", "MASS", "Matrix", "nlme", "nnet", "rpart", "survival"))
#install_missing_packages(c("ddalpha", "dimRed", "ipred", "ggplot2", "recipes"))
pkg <- tests2_step("start", package = "caret")
#                   needs = c("Suggests",
#                     "ddalpha", "dimRed", "ggplot2", "ipred", "recipes"))

excl <- "featurePlot"
excl <- getOption("doFuture.tests.topics.ignore", excl)
options(doFuture.tests.topics.ignore = excl)

subset <- as.integer(Sys.getenv("R_CHECK_SUBSET_", 1))
topics <- test_topics(pkg, subset = subset, max_subset = 4)
topics <- test_topics(pkg, subset = subset, max_subset = 4)


## WORKAROUND: Several of caret's foreach() calls use faulty '.export'
## specifications, i.e. not all globals are exported.
options(doFuture.foreach.export = "automatic")

mprintf("*** doFuture() - all %s examples ...", pkg)

for (strategy in test_strategies()) {
  mprintf("- plan('%s') ...", strategy)
  run_examples(pkg, topics = topics, strategy = strategy)
  mprintf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

mprintf("*** doFuture() - all %s examples ... DONE", pkg)

tests2_step("stop")
