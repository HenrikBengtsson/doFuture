testsets <- strsplit(Sys.getenv("_R_CHECK_TESTSETS_"), split = "[, ]")[[1]]
if ("caret" %in% testsets) {
  source("incl/start.R")
  library(caret, character.only = TRUE)

  ## Packages used by some of the caret examples
  pkgs <- c("lattice", "mlbench", "earth", "mda", "MLmetrics")
  lapply(pkgs, FUN = loadNamespace)

  excl <- "featurePlot"
  excl <- getOption("doFuture.tests.topics.ignore", excl)
  options(doFuture.tests.topics.ignore = excl)

  ## WORKAROUND: Several of caret's foreach() calls use faulty '.export'
  ## specifications, i.e. not all globals are exported.
  options(doFuture.foreach.export = "automatic")
  
  options(doFuture.tests.strategies = Sys.getenv("_R_CHECK_FUTURE_STRATEGIES_"))
  path <- system.file("tests2", package = "doFuture")
  pathname <- file.path(path, "caret", "examples.R")
  source(pathname, echo = TRUE)
  source("incl/end.R")
}
rm(list = "testsets")
