source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

message("*** doFuture - nested w/ %:% ...")

registerDoFuture()

for (strategy1 in strategies) {
  for (strategy2 in strategies) {
    message(sprintf("- plan(list('%s', '%s')) ...", strategy1, strategy2))
    plan(list(a = strategy1, b = strategy2))
    nested <- plan("list")
    
    as <- 1:2
    bs <- 3:1
    
    x <- foreach(a = as) %:% foreach(b = bs) %dopar% {
      list(a = a, b = b, plan_b = future::plan("list"), plan = future::plan("next"))
    }

    stopifnot(length(x) == length(as))
    for (aa in seq_along(as)) {
      x_aa <- x[[aa]]
      stopifnot(length(x_aa) == length(bs))
      a <- as[aa]
      for (bb in seq_along(bs)) {
        x_aa_bb <- x_aa[[bb]]
        b <- bs[bb]
        stopifnot(
          length(x_aa_bb) == 4L,
          all(names(x_aa_bb) == c("a", "b", "plan_b", "plan")),
          x_aa_bb$a == a,
          x_aa_bb$b == b,
          length(x_aa_bb$plan_b) == length(nested[-1]),
          inherits(x_aa_bb$plan_b[[1]], strategy2),
          inherits(x_aa_bb$plan, strategy2)
        )
      }
    }

    ## Cleanup in order make sure none of these variables exist as
    ## proxies for missing globals of the name names
    rm(list = c("as", "bs", "x", "nested"))

    ## WORKAROUND: Shut down *nested* parallel workers as an attempt to avoid
    ## * checking for detritus in the temp directory ... NOTE
    ## from 'R CMD check --as-cran' when running on MS Windows. This looks
    ## like a bug in R, cf. https://bugs.r-project.org/show_bug.cgi?id=18133    
    message("- shut down nested workers")
    dummy <- foreach(ii = 1:nbrOfWorkers()) %dopar% plan("sequential")
    plan("sequential")
    
    message(sprintf("- plan(list('%s', '%s')) ... DONE", strategy1, strategy2))
  }
}

message("*** doFuture - nested w/ %:% ... DONE")

source("incl/end.R")
