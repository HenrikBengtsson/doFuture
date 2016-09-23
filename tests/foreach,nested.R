source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

message("*** doFuture - nested ...")

registerDoFuture()

for (strategy1 in strategies) {
  for (strategy2 in strategies) {
    message(sprintf("- plan(list('%s', '%s')) ...", strategy1, strategy2))
    plan(list(strategy1, strategy2))
    nested <- plan("list")

    as <- 1:2
    bs <- 3:1
    x <- foreach(a=as) %:% foreach(b=bs) %dopar% {
      list(a=a, b=b, plan=plan("list"))
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
	  length(x_aa_bb) == 3L,
	  all(names(x_aa_bb) == c("a", "b", "plan")),
	  x_aa_bb$a == a,
	  x_aa_bb$b == b
	)

	if (strategy1 == "multisession") {
          ## FIXME: This should not be the case; what's going on?
	  ## /HB 2016-09-22
          stopifnot(
	          length(x_aa_bb$plan) == length(nested),
		  all.equal(x_aa_bb$plan, nested)
          )
	} else {
          stopifnot(
	          length(x_aa_bb$plan) == length(nested) - 1,
		  all.equal(x_aa_bb$plan, nested[-1])
          )
	}
      }
    }

    message(sprintf("- plan(list('%s', '%s')) ... DONE", strategy1, strategy2))
  }
}

message("*** doFuture - nested ... DONE")

source("incl/end.R")
