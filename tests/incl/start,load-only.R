## Record original state
ovars <- ls()
oopts <- options(warn = 1L,
                 mc.cores = 2L,
                 future.debug = FALSE,
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

supportedStrategies <- function(cores = 1L, excl = c("cluster"), ...) {
  strategies <- future:::supportedStrategies(...)
  strategies <- setdiff(strategies, excl)
  if (cores > 1) {
    strategies <- setdiff(strategies, c("sequential", "uniprocess"))
  }
  strategies
}

availCores <- min(2L, future::availableCores())

print(sessionInfo())
