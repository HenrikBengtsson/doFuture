testsets <- strsplit(Sys.getenv("_R_CHECK_TESTSETS_"), split = "[, ]")[[1]]
if ("foreach" %in% testsets) {
  source("incl/start.R")
  options(doFuture.tests.strategies = Sys.getenv("_R_CHECK_FUTURE_STRATEGIES_"))
  path <- system.file("tests2", package = "doFuture")
  pathname <- file.path(path, "foreach", "examples.R")
  source(pathname, echo = TRUE)
  source("incl/end.R")
}
rm(list = "testsets")
