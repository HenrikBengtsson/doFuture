source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

options(future.debug = FALSE, doFuture.debug = FALSE)

message("*** %dofuture% w/ RNG ...")
print(sessionInfo())

r1_0 <- r3_0 <- NULL

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  r1 <- foreach(i = 1:4, .options.future = list(seed = 42)) %dofuture% {
    runif(1)
  }
  str(r1)
  if (is.null(r1_0)) r1_0 <- r1
  ## FIXME: %dofuture% still does not implement reproducbile RNGs
  ## stopifnot(identical(r1_0, r1))
  
  r2 <- foreach(i = 1:4, .options.future = list(seed = 42)) %dofuture% {
    runif(1)
  }
  str(r2)
  stopifnot(identical(r2, r1))

  set.seed(42)
  r3 <- foreach(i = 1:4, .options.future = list(seed = TRUE)) %dofuture% {
    runif(1)
  }
  str(r3)
  if (is.null(r3_0)) r3_0 <- r3
  ## FIXME: %dofuture% still does not implement reproducbile RNGs
  ## stopifnot(identical(r3_0, r3))
  
  set.seed(42)
  r4 <- foreach(i = 1:4, .options.future = list(seed = TRUE)) %dofuture% {
    runif(1)
  }
  str(r4)
  stopifnot(identical(r4, r3))

  # Shutdown current plan
  plan(sequential)

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** %dofuture% w/ RNG ... DONE")

source("incl/end.R")
