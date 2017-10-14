testsets <- strsplit(Sys.getenv("_R_CHECK_TESTSETS_"), split = "[, ]")[[1]]
if ("TSP" %in% testsets) {
  source("incl/start.R")
  path <- system.file("tests2", package = "doFuture")
  pathname <- file.path(path, "TSP", "examples.R")
  source(pathname, echo = TRUE)
  source("incl/end.R")
}
rm(list = "testsets")
