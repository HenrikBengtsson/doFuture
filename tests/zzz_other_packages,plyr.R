testsets <- strsplit(Sys.getenv("_R_CHECK_TESTSETS_"), split = "[, ]")[[1]]
if ("plyr" %in% testsets) {
  source("incl/start.R")
  library(plyr, character.only = TRUE)
  options(doFuture.tests.strategies = Sys.getenv("_R_CHECK_FUTURE_STRATEGIES_"))
  path <- system.file("tests2", package = "doFuture")
  pathname <- file.path(path, "plyr", "examples.R")
  source(pathname, echo = TRUE)
  source("incl/end.R")
}
rm(list = "testsets")
