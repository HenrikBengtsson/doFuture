path <- system.file("tests2", "incl", package = "doFuture", mustWork = TRUE)
source(file.path(path, "utils.R"))
pkg <- tests2_step("start", package = "plyr")
topics <- test_topics(pkg)

## Tweak all plyr functions with argument '.parallel'
tweak_plyr <- function() {
  ns <- getNamespace("plyr")

  vars <- ls(envir = ns, all.names = TRUE)
  for (var in vars) {
    if (!exists(var, mode = "function", envir = ns)) next
    fcn <- get(var, mode = "function", envir = ns)
    fmls <- formals(fcn)
    if (!".parallel" %in% names(fmls)) next
    formals(fcn)$.parallel <- TRUE
    message(" - plyr function tweaked: ", var)
    assignInNamespace(var, fcn, ns = ns)
  }

  setup_parallel <- getFromNamespace("setup_parallel", ns = ns)
  body(setup_parallel) <- body(setup_parallel)[-3]
  assignInNamespace("setup_parallel", setup_parallel, ns = ns)
}

tweak_plyr()

## Exclude a few tests that takes very long time to run:
## (1) example(raply) runs 100's of tasks that each parallelizes only
##     few subtasks. Doing so using  batchjobs_local and
##     batchtools_local futures will take quite some time, because of
##     the overhead of creating BatchJobs / batchtools jobs.
excl <- "raply"
## (2) example(rdply) is as above (but only over 20 iterations).
excl <- c(excl, "rdply")
## (3) Takes 45+ seconds each
excl <- c(excl, "aaply", "quoted")
options("doFuture.tests.topics.ignore" = excl)

## See example(topic, package = "plyr") for why 'run.dontrun' must be FALSE
excl_dontrun <- c("failwith", "here")
## Exclude because it requires Tk, which is not available on Travis CI
excl_dontrun <- c(excl_dontrun, "create_progress_bar", "progress_tk")

mprintf("*** doFuture() - all %s examples ...", pkg)

for (strategy in test_strategies()) {
  mprintf("- plan('%s') ...", strategy)

  for (ii in seq_along(topics)) {
    topic <- topics[ii]
    run.dontrun <- !is.element(topic, excl_dontrun)
    
    mprintf("- #%d of %d example('%s', package = '%s', run.dontrun = %s) using plan(%s) ...", ii, length(topics), topic, pkg, run.dontrun, strategy) #nolint
    registerDoFuture()
    plan(strategy)
    dt <- run_example(topic = topic, package = pkg, run.dontrun = run.dontrun, local = TRUE)
    mprintf("- #%d of %d example('%s', package = '%s', run.dontrun = %s) using plan(%s) ... DONE (%s)", ii, length(topics), topic, pkg, run.dontrun, strategy, dt) #nolint
  } ## for (ii ...)
  
  mprintf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

mprintf("*** doFuture() - all %s examples ... DONE", pkg)

tests2_step("stop")
