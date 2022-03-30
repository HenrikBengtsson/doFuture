## Record original state
ovars <- ls()
oopts <- options(warn = 1L,
                 mc.cores = 2L,
                 future.debug = TRUE,
                 doFuture.debug = TRUE)
oplan <- future::plan()

future::plan(future::sequential)
doFuture::registerDoFuture()

adHocStopPlanCluster <- function() {
  ## (i) AD HOC: Identify any PSOCK cluster and close it
  if (inherits(future::plan("next"), "cluster")) {
    f <- future::future(NULL)
    v <- future::value(f)
    cl <- f$workers
    f <- NULL
    if (inherits(cl, "cluster")) parallel::stopCluster(cl)
    cl <- NULL
  }

  ## (ii) Reset plan to sequential
  future::plan("sequential")
  
  gc()
}


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
