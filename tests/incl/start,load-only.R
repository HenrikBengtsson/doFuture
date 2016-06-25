## Record original state
ovars <- ls()
oopts <- options(warn=1L, mc.cores=2L, future.debug=TRUE)
oplan <- future::plan()

future::plan(future::eager)
doFuture::registerDoFuture()

hpaste <- future:::hpaste
mdebug <- future:::mdebug

## Local functions for test scripts
printf <- function(...) cat(sprintf(...))
mstr <- function(...) message(paste(capture.output(str(...)), collapse="\n"))
