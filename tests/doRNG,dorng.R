source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

## Due to a bug in doRNG (https://github.com/renozao/doRNG/issues/12), we
## need to initiate the RNG state in order to achieve full reproducibility
## FIXME: Keep an eye on doRNG and remove this if it get fixed /HB 2019-10-26
if (utils::packageVersion("future") > "1.14.0") sample.int(1L)

## Adopted from demo("doRNG", package = "doRNG")
if (require("doRNG")) {

  message("*** doFuture() w/ doRNG + %dorng% ...")
  print(sessionInfo())

  for (strategy in strategies) {
    message(sprintf("- plan('%s') ...", strategy))
    plan(strategy)

    # single %dorng% loops are reproducible
    r1 <- foreach(i = 1:4, .options.RNG = 1234) %dorng% { runif(1) }
    r2 <- foreach(i = 1:4, .options.RNG = 1234) %dorng% { runif(1) }
    str(list(r1 = r1, r2 = r2))
    stopifnot(identical(r1, r2))

    # sequences of %dorng% loops are reproducible
    set.seed(1234)
    s1 <- foreach(i = 1:4) %dorng% { runif(1) }
    s2 <- foreach(i = 1:4) %dorng% { runif(1) }
    str(list(s1 = s1, s2 = s2))
    # two consecutive (unseed) %dorng% loops are not identical
    stopifnot(!identical(s1, s2))
    # but the first one gives the same result as with .options.RNG
    stopifnot(identical(r1, s1))

    # But the whole sequence of loops is reproducible
    set.seed(1234)
    s1_2 <- foreach(i = 1:4) %dorng% { runif(1) }
    s2_2 <- foreach(i = 1:4) %dorng% { runif(1) }
    str(list(s1_2 = s1_2, s2_2 = s2_2))
    stopifnot(identical(s1, s1_2), identical(s2, s2_2))

    message(sprintf("- plan('%s') ... DONE", strategy))
  } ## for (strategy ...)

  message("*** doFuture() w/ doRNG + %dorng% ... DONE")

} ## if (require("doRNG"))

source("incl/end.R")
