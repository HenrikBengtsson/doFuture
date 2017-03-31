find_rd_topics <- function(package) {
  path <- find.package(package)
  file <- file.path(path, "help", "aliases.rds")
  topics <- readRDS(file)
  unique(topics)
}

mprintf <- function(...) message(sprintf(...))

## Package for which examples should be run
pkg <- "foreach"

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
topics <- getOption("doFuture.tests.topics", find_rd_topics(pkg))

## Some examples may give errors when used with futures
excl <- getOption("doFuture.tests.topics.ignore", NULL)
topics <- setdiff(topics, excl)

for (strategy in strategies) {
  mprintf("- plan('%s') ...", strategy)
  plan(strategy)
  registerDoFuture()

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
