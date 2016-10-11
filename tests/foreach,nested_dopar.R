source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

message("*** doFuture - nested %dopar% ...")

registerDoFuture()

for (strategy1 in strategies) {
  for (strategy2 in strategies) {
    message(sprintf("- plan(list('%s', '%s')) ...", strategy1, strategy2))
    plan(list(a=strategy1, b=strategy2))
    nested <- plan("list")
    
    as <- 1:2
    bs <- 3:1
    
    message("foreach() - level 1 ...")
    x <- foreach(a=as, .export = c("bs", "strategy2"), .packages = "foreach") %dopar% {
      plan <- future::plan()
      stopifnot(inherits(plan, strategy2))
      plan_a <- future::plan("list")
      str(plan_a)
      stopifnot(inherits(plan_a[[1]], strategy2))
      
      message("foreach() - level 2 ...")
      y <- foreach(b=bs, .export = c("a", "plan_a")) %dopar% {
        plan <- future::plan()
	message(capture.output(print(plan)))
        stopifnot(
	  inherits(plan, "future"),
	  packageVersion("future") <= "1.0.1" || inherits(plan, getOption("future.default", "eager"))
	)
	
        plan_b <- future::plan("list")
	str(plan_b)
        stopifnot(
	  inherits(plan_b[[1]], "future"),
	  packageVersion("future") <= "1.0.1" || inherits(plan_b[[1]], getOption("future.default", "eager"))
	)
	
        list(a = a, plan_a = plan_a,
	     b = b, plan_b = plan_b)
      }
      message("foreach() - level 2 ... DONE")

      y
    }
    message("foreach() - level 1 ... DONE")


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
	  all(names(x_aa_bb) == c("a", "plan_a", "b", "plan_b")),
	  x_aa_bb$a == a,
	  x_aa_bb$b == b,
	  inherits(x_aa_bb$plan_a[[1]], strategy2),
	  inherits(x_aa_bb$plan_b[[1]], "future"),
	  packageVersion("future") <= "1.0.1" || inherits(x_aa_bb$plan_b[[1]], getOption("future.default", "eager"))
	)
      }
    }

    message(sprintf("- plan(list('%s', '%s')) ... DONE", strategy1, strategy2))
  }
}

message("*** doFuture - nested %dopar% ... DONE")

source("incl/end.R")
