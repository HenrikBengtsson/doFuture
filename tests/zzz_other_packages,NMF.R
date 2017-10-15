testsets <- strsplit(Sys.getenv("_R_CHECK_TESTSETS_"), split = "[, ]")[[1]]
print(testsets)
if ("NMF" %in% testsets) {
  source("incl/start.R")
  path <- system.file("tests2", package = "doFuture")
  pathname <- file.path(path, "NMF", "manual.R")
  source(pathname, echo = TRUE)
  source("incl/end.R")
}
rm(list = "testsets")
