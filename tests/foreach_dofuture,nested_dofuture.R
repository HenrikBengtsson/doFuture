source("incl/start.R")

## WORKAROUND: To avoid `R CMD check --as-cran` on MS Windows triggering:
##
## * checking for detritus in the temp directory ... NOTE
##   Found the following files/directories:
##    'Rscript171866c62e'
##
## we can set cluster nodes to use a temporary folder *inside* the parent
## temporary folder. This will hide the above files from 'R CMD check'.
## See https://bugs.r-project.org/show_bug.cgi?id=18133 for more details.
if (.Platform$OS.type == "windows") Sys.setenv(TMPDIR = tempdir())

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

options(future.debug = FALSE)
options(doFuture.debug = FALSE)

plan_nested <- "sequential"

message("*** doFuture - nested %dofuture% ...")

message("*** doFuture - nested %dofuture%  and tricky globals ...")

## This works ...
x <- foreach(j = 1) %dofuture% { j }
str(x)
rm(list = "x")

## ... but this would give a "globals-not-found" error in
## doFuture (<= 0.4.0) because 'j' was interpreted as global variable
x <- foreach(i = 1, .packages = "foreach") %dofuture% {
  foreach(j = 1) %dofuture% { j }
}
str(x)
rm(list = "x")

message("*** doFuture - nested %dofuture%  and tricky globals ... DONE")


for (strategy1 in strategies) {
  for (strategy2 in strategies) {
    message(sprintf("- plan(list('%s', '%s')) ...", strategy1, strategy2))
    plan(list(a = strategy1, b = strategy2))

    as <- 1:2
    bs <- 3:1

    stopifnot(!exists("a", inherits = FALSE), !exists("b", inherits = FALSE))

    message("foreach() - level 1 ...")
    x <- foreach(a = as, .export = c("bs", "strategy2"),
                 .packages = "foreach") %dofuture% {
      plan_list <- future::plan("next")
      stopifnot(inherits(plan_list, strategy2))
      plan_a <- future::plan("list")
      str(plan_a)
      stopifnot(inherits(plan_a[[1]], strategy2))

      message("foreach() - level 2 ...")
      y <- foreach(b = bs, .export = c("a", "plan_a")) %dofuture% {
        plan_list <- future::plan("next")
        message(capture.output(print(plan_list)))

        stopifnot(inherits(plan_list, "future"))
        ## future.plan can be either a string or a future function
        default <- getOption("future.plan", "sequential")
        if (is.function(default)) default <- class(default)
        message("Option 'future.plan': ", sQuote(default))
        stopifnot(inherits(plan_list, default))

        plan_b <- future::plan("list")
        str(plan_b)
        stopifnot(
          inherits(plan_b[[1]], "future"),
          inherits(plan_b[[1]], default)
        )

        list(a = a, plan_a = plan_a,
             b = b, plan_b = plan_b)
      }
      message("foreach() - level 2 ... DONE")

      y
    }
    message("foreach() - level 1 ... DONE")

    local({
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
            inherits(x_aa_bb$plan_b[[1]], plan_nested)
          )
        }
      }
    })

    ## Cleanup in order make sure none of these variables exist as
    ## proxies for missing globals of the name names
    rm(list = c("as", "bs", "x"))

    ## WORKAROUND: Shut down *nested* parallel workers as an attempt to avoid
    ## * checking for detritus in the temp directory ... NOTE
    ## from 'R CMD check --as-cran' when running on MS Windows. This looks
    ## like a bug in R, cf. https://bugs.r-project.org/show_bug.cgi?id=18133    
    message("- shut down nested workers")
    dummy <- foreach(ii = 1:nbrOfWorkers()) %dofuture% plan("sequential")
    plan("sequential")
    
    message(sprintf("- plan(list('%s', '%s')) ... DONE", strategy1, strategy2))
  }
}

message("*** doFuture - nested %dofuture% ... DONE")

source("incl/end.R")
