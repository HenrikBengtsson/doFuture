## Record original state
ovars <- ls()
oopts <- options(warn = 1L,
                 mc.cores = 2L,
                 future.debug = TRUE,
                 doFuture.debug = TRUE)
oplan <- future::plan()

future::plan(future::sequential)
doFuture::registerDoFuture()

hpaste <- future:::hpaste
mdebug <- future:::mdebug

## To please R CMD check when using require().
future.batchtools <- "future.batchtools"  #nolint
future.BatchJobs <- "future.BatchJobs"    #nolint
plyr <- "plyr"                            #nolint
BiocParallel <- "BiocParallel"            #nolint

## Local functions for test scripts
printf <- function(...) cat(sprintf(...))
mstr <- function(...) message(paste(capture.output(str(...)), collapse = "\n"))
