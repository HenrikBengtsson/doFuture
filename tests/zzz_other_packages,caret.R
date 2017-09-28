testsets <- strsplit(Sys.getenv("_R_CHECK_TESTSETS_"), split = "[, ]")[[1]]
if ("caret" %in% testsets) {
  source("incl/start.R")
  library(caret, character.only = TRUE)

  ## Packages used by some of the caret examples
  pkgs <- c("mlbench", "earth", "mda", "MLmetrics")
  lapply(pkgs, FUN = loadNamespace)

  excl <- "featurePlot"
  excl <- c(excl, "confusionMatrix.train") ## export bug in caret
  excl <- getOption("doFuture.tests.topics.ignore", excl)
  options(doFuture.tests.topics.ignore = excl)

  options(doFuture.tests.strategies = Sys.getenv("_R_CHECK_FUTURE_STRATEGIES_"))
  path <- system.file("tests2", package = "doFuture")
  pathname <- file.path(path, "caret", "examples.R")
  source(pathname, echo = TRUE)
  source("incl/end.R")
}
rm(list = "testsets")
