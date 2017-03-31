find_rd_topics <- function(package) {
  path <- find.package(package)
  file <- file.path(path, "help", "aliases.rds")
  topics <- readRDS(file)
  unique(topics)
}


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

mprintf <- function(...) message(sprintf(...))


## Package for which examples should be run
pkg <- "plyr"

mprintf("*** doFuture() - all %s examples ...", pkg)

library("future")
options(warnPartialMatchArgs = FALSE)
oopts <- options(mc.cores = 2L, warn = 1L, digits = 3L)
strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, c("multiprocess", "lazy", "eager"))
if (require("future.BatchJobs")) {
  strategies <- c(strategies, "batchjobs_local")
}
if (require("future.batchtools")) {
  strategies <- c(strategies, "batchtools_local")
}
strategies <- getOption("doFuture.tests.strategies", strategies)

library("doFuture")
registerDoFuture()
library(pkg, character.only = TRUE)
tweak_plyr()
topics <- getOption("doFuture.tests.topics", find_rd_topics(pkg))

## Exclude a few tests that takes very long time to run:
excl <- NULL
## (1) example(raply) runs 100's of tasks that each parallelizes only
##     few subtasks. Doing so using  batchjobs_local and
##     batchtools_local futures will take quite some time, because of
##     the overhead of creating BatchJobs / batchtools jobs.
excl <- c(excl, "raply")
## (2) example(rdply) is as above (but only over 20 iterations).
excl <- c(excl, "rdply")

## (2) Takes 45+ seconds each
excl <- c(excl, "aaply", "quoted")
excl <- getOption("doFuture.tests.topics.exclude", excl)
topics <- setdiff(topics, excl)

## Some examples may give errors when used with futures
excl <- getOption("doFuture.tests.topics.ignore", NULL)
topics <- setdiff(topics, excl)

for (strategy in strategies) {
  mprintf("- plan('%s') ...", strategy)
  plan(strategy)

  for (ii in seq_along(topics)) {
    topic <- topics[ii]
    mprintf("- #%d of %d example(%s, package = '%s') using plan(%s) ...", ii, length(topics), topic, pkg, strategy) #nolint
    dt <- NULL
    ovars <- ls(all.names = TRUE)
    dt <- system.time({
      example(topic, package = pkg, character.only = TRUE, ask = FALSE)
    })
    graphics.off()
    rm(list = setdiff(ls(all.names = TRUE), c(ovars, "ovars")))
    dt <- dt[1:3]; names(dt) <- c("user", "system", "elapsed")
    dt <- paste(sprintf("%s: %g", names(dt), dt), collapse = ", ")
    message("  Total processing time for example: ", dt)
    mprintf("- #%d of %d example(%s, package = '%s') using plan(%s) ... DONE (%s)", ii, length(topics), topic, pkg, strategy, dt) #nolint
  } ## for (ii ...)

  mprintf("- plan('%s') ... DONE", strategy)
} ## for (strategy ...)

mprintf("*** doFuture() - all %s examples ... DONE", pkg)

options(oopts)
