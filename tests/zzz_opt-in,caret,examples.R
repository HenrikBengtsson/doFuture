testsets <- strsplit(Sys.getenv("_R_CHECK_TESTSETS_"), split = "[, ]")[[1]]
print(testsets)
if ("caret" %in% testsets) {
  source("incl/start.R")

  ## Avoid going over 4GB-log size limit on Travis CI
  if (Sys.getenv("TRAVIS") == "true") {
    options(doFuture.debug = FALSE, future.debug = FALSE)
  }
  
  path <- system.file("tests2", package = "doFuture")
  pathname <- file.path(path, "caret", "examples.R")
  source(pathname, echo = TRUE)
  source("incl/end.R")
}
rm(list = "testsets")
