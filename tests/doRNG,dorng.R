source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

## Adopted from demo("doRNG", package="doRNG")
if (require("doRNG")) {

  message("*** doFuture() w/ doRNG + %dorng% ...")

  ## There's a bug in doRNG (<= 1.6.0) causing the first iteration
  ## of these tests to fail due to non-reproducibility of s1 and s1.2,
  ## cf. https://github.com/renozao/doRNG/issues/1.  /HB 2016-05-07
  if (packageVersion("doRNG") <= "1.6.0") {
    strategies <- setdiff(strategies, c("eager", "lazy"))
  }

  for (strategy in strategies) {
    message(sprintf("- plan('%s') ...", strategy))
    plan(strategy)

    # single %dorng% loops are reproducible
    r1 <- foreach(i=1:4, .options.RNG=1234) %dorng% { runif(1) }
    r2 <- foreach(i=1:4, .options.RNG=1234) %dorng% { runif(1) }
    stopifnot(identical(r1, r2))

    # sequences of %dorng% loops are reproducible
    set.seed(1234)
    s1 <- foreach(i=1:4) %dorng% { runif(1) }
    s2 <- foreach(i=1:4) %dorng% { runif(1) }
    # two consecutive (unseed) %dorng% loops are not identical
    stopifnot(!identical(s1, s2))
    # but the first one gives the same result as with .options.RNG
    stopifnot(identical(r1, s1))

    # But the whole sequence of loops is reproducible
    set.seed(1234)
    s1.2 <- foreach(i=1:4) %dorng% { runif(1) }
    s2.2 <- foreach(i=1:4) %dorng% { runif(1) }
    str(list(s1.2=s1.2, s2.2=s2.2))
    stopifnot(identical(s1, s1.2), identical(s2, s2.2))

    message(sprintf("- plan('%s') ... DONE", strategy))
  } ## for (strategy ...)

  message("*** doFuture() w/ doRNG + %dorng% ... DONE")

} ## if (require("doRNG"))

source("incl/end.R")
