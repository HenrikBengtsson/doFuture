path <- system.file("tests2", "incl", package = "doFuture", mustWork = TRUE)
source(file.path(path, "utils.R"))
install_missing_packages(c("cluster", "foreign", "lattice", "MASS"))
pkg <- tests2_step("start", package = "TSP", needs = c("Suggests"))
topics <- test_topics(pkg)

mprintf("*** doFuture() - all %s examples ...", pkg)

for (strategy in test_strategies()) {
  mprintf("- plan('%s') ...", strategy)

  for (ii in seq_along(topics)) {
    topic <- topics[ii]

    ## Don't rest examples that require the external 'Concorde' software
    run.dontrun <- !is.element(topic, c("Concorde", "solve_TSP"))
    
    mprintf("- #%d of %d example('%s', package = '%s', run.dontrun = %s) using plan(%s) ...", ii, length(topics), topic, pkg, run.dontrun, strategy) #nolint
    registerDoFuture()
    plan(strategy)
    dt <- run_example(topic = topic, package = pkg, run.dontrun = run.dontrun)
    mprintf("- #%d of %d example('%s', package = '%s', run.dontrun = %s) using plan(%s) ... DONE (%s)", ii, length(topics), topic, pkg, run.dontrun, strategy, dt) #nolint
  } ## for (ii ...)
  
  mprintf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

mprintf("*** doFuture() - all %s examples ... DONE", pkg)

tests2_step("stop")
