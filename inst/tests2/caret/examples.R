path <- system.file("tests2", "incl", package = "doFuture", mustWork = TRUE)
source(file.path(path, "utils.R"))

if (Sys.getenv("TRAVIS") != "true") {
  install_missing_packages(c("class", "cluster", "e1071", "earth", "fastICA", "foreign", "gam", "klaR", "lattice", "MASS", "Matrix", "mda", "mlbench", "MLmetrics", "nlme", "nnet", "pls", "proxy", "randomForest", "rpart", "survival", "partykit", "mboost"))
  ## install_missing_packages(c("ddalpha", "dimRed", "ipred", "ggplot2", "recipes"))
}
pkg <- tests2_step("start", package = "caret")

excl <- c(
  "featurePlot",
  ## Non-functional example, because they depend on
  ## an object that is not available/not loaded.
  "dotplot.diff.resamples",
  "xyplot.resamples",
  "prcomp.resamples",
  "diff.resamples"
)

excl_dontrun <- c(
  ## Non-functional example(run.dontrun = TRUE)
  ## (gives a parsing error)
  "gafs_initial",
  "safs_initial",
  ## Other non-functional/broken example(run.dontrun = TRUE)
  "sensitivity",
  "plotClassProbs",
  "plotObsVsPred",
  "rfeControl",
  "sbf",
  ## Very very slow
  "plsda",
  "rfe"
)

if (!grepl("foreach", doFuture:::globalsAs())) {
  ## example("avNNet", run.dontrun = TRUE) only works with a more liberal
  ## identification method for globals than 'future', e.g. 'foreach'
  ## See https://github.com/HenrikBengtsson/doFuture/issues/17
  excl_dontrun <- c(excl_dontrun, "avNNet")
}

excl <- getOption("doFuture.tests.topics.ignore", excl)
options(doFuture.tests.topics.ignore = excl)

subset <- as.integer(Sys.getenv("R_CHECK_SUBSET_"))
topics <- test_topics(pkg, subset = subset, max_subset = 4)

mprintf("*** doFuture() - all %s examples ...", pkg)

## Several examples of 'caret' only works with doSEQ and forked doParallel,
## but not cluster doParallel.  Try for instance,
##
##   library("doParallel")
##   registerDoParallel(cl <- makeCluster(2L))
##   example("train", package = "caret", run.dontrun = TRUE)
##   [...]
##   Error in e$fun(obj, substitute(ex), parent.frame(), e$data) : 
##     unable to find variable "optimism_boot"
##
## or equivalently:
##
##   library("doFuture")
##   registerDoFuture()
##   plan(multisession, workers = 2L)
##   example("train", package = "caret", run.dontrun = TRUE)
##

for (strategy in test_strategies()) {
  mprintf("- plan('%s') ...", strategy)

  for (ii in seq_along(topics)) {
    topic <- topics[ii]
    ## BUG?: example("calibration", run.dontrun = TRUE) only works
    ## for plan(transparent), but not even plan(sequential).  It gives:
    ## Error in qda.default(x, grouping, ...) : 
    ##     rank deficiency in group Inactive
    ## but it only happens if other examples were ran prior to this example.
    ## There seems to be some stray objects that affects this example.
    ## Leaving it at this for now. /HB 2017-12-19
    run.dontrun <- !is.element(topic, c("calibration", excl_dontrun))

    mprintf("- #%d of %d example('%s', package = '%s', run.dontrun = %s) using plan(%s) ...", ii, length(topics), topic, pkg, run.dontrun, strategy) #nolint
    registerDoFuture()
    plan(strategy)
    dt <- run_example(topic = topic, package = pkg, run.dontrun = run.dontrun, local = FALSE)

    mprintf("- #%d of %d example('%s', package = '%s', run.dontrun = %s) using plan(%s) ... DONE (%s)", ii, length(topics), topic, pkg, run.dontrun, strategy, dt) #nolint
  } ## for (ii ...)

  mprintf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

mprintf("*** doFuture() - all %s examples ... DONE", pkg)

tests2_step("stop")
