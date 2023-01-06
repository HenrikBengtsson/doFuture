## Record original state
ovars <- ls()
oopts <- options(warn = 1L,
                 mc.cores = 2L,
                 future.debug = TRUE,
                 doFuture.debug = TRUE)
oplan <- future::plan()

## Record connected *after* the first future has been created,
## because the default plan might be a PSOCK cluster
future::value(future::future(NULL))
cons0 <- showConnections(all = FALSE)

future::plan(future::sequential)
oldDoPar <- doFuture:::.getDoPar()

mdebug <- doFuture:::mdebug
mprint <- doFuture:::mprint
mstr <- doFuture:::mstr

## To please R CMD check when using require().
future.batchtools <- "future.batchtools"  #nolint
caret <- "caret"                          #nolint
plyr <- "plyr"                            #nolint
BiocParallel <- "BiocParallel"            #nolint
NMF <- "NMF"                              #nolint

print(sessionInfo())
