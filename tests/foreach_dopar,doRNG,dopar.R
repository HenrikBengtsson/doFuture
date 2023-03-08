source("incl/start.R")

strategies <- future:::supportedStrategies()

## Adopted from demo("doRNG", package = "doRNG")
if (require("doRNG")) {

  registerDoFuture()

  message("*** doFuture() w/ doRNG + %nopar% ...")
  print(sessionInfo())

  for (strategy in strategies) {
    message(sprintf("- plan('%s') ...", strategy))
    plan(strategy)

    # One can make reproducible loops using the %dorng% operator
    r1 <- foreach(i = 1:4, .options.RNG = 1234) %dorng% { runif(1) }
    # or convert %dopar% loops using registerDoRNG
    registerDoRNG(1234)
    r2 <- foreach(i = 1:4) %dopar% { runif(1) }
    identical(r1, r2)

    # Registering another foreach backend disables doRNG
    registerDoSEQ()
    set.seed(1234)
    s1 <- foreach(i = 1:4) %dopar% { runif(1) }
    set.seed(1234)
    s2 <- foreach(i = 1:4) %dopar% { runif(1) }
    stopifnot(identical(s1, s2))

    # doRNG is re-nabled by re-registering it
    registerDoRNG()
    set.seed(1234)
    r3 <- foreach(i = 1:4) %dopar% { runif(1) }
    identical(r2, r3)
    # NB: the results are identical independently of the task scheduling
    # (r2 used 2 nodes, while r3 used 3 nodes)


    # argument `once = FALSE` reseeds doRNG's seed at the beginning
    # of each loop
    registerDoRNG(1234, once = FALSE)
    r1 <- foreach(i = 1:4) %dopar% { runif(1) }
    r2 <- foreach(i = 1:4) %dopar% { runif(1) }
    stopifnot(identical(r1, r2))

    # Once doRNG is registered the seed can also be passed as an
    # option to %dopar%
    r1_2 <- foreach(i = 1:4, .options.RNG = 456) %dopar% { runif(1) }
    r2_2 <- foreach(i = 1:4, .options.RNG = 456) %dopar% { runif(1) }
    stopifnot(identical(r1_2, r2_2), !identical(r1_2, r1))

    # Shutdown current plan
    plan(sequential)

    message(sprintf("- plan('%s') ... DONE", strategy))
  } ## for (strategy ...)

  message("*** doFuture() w/ doRNG + %nopar% ... DONE")

} ## if (require("doRNG"))

source("incl/end.R")
