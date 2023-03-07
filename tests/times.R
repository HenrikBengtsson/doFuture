source("incl/start.R")

strategies <- future:::supportedStrategies()

message("*** times() ...")

res0 <- NULL

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  mu <- 1.0
  sigma <- 2.0
  ## NOTE: Using times() with %dopar% without proper parallel RNG will likely
  ## produce unreliable results.  Here we don't produce random numbers so it
  ## is ok, but it's a toy example because just like base::replicate(),
  ## foreach::times() is commonly used for resampling purposes.
  res <- times(3L) %dopar% {
    dnorm(2L, mean = mu, sd = sigma)
  }
  print(res)

  if (is.null(res0)) {
    res0 <- res
  } else {
    stopifnot(all.equal(res, res0))
  }

  # Shutdown current plan
  plan(sequential)
  
  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** times() ... DONE")

source("incl/end.R")
