findRdTopics <- function(package) {
  path <- find.package(package)
  file <- file.path(path, "help", "aliases.rds")
  topics <- readRDS(file)
  unique(topics)
} ## findRdTopics()


message("*** doFuture() - all foreach examples ...")

library("future")
options(warnPartialMatchArgs=FALSE)
oopts <- options(mc.cores=2L, warn=1L, digits=3L)
strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")
strategies <- getOption("doFuture.tests.strategies", strategies)

library("doFuture")
registerDoFuture()
library("foreach")
topics <- getOption("doFuture.tests.topics", findRdTopics("foreach"))

## Some examples may give errors when used with futures
excl <- getOption("doFuture.tests.topics.ignore", NULL)
topics <- setdiff(topics, excl)

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)
  registerDoFuture()

  for (ii in seq_along(topics)) {
    topic <- topics[ii]
    message(sprintf("- #%d of %d example(%s, package='foreach') using plan(%s) ...", ii, length(topics), topic, strategy))

    ovars <- ls(all.names=TRUE)
    example(topic, package="foreach", character.only=TRUE, ask=FALSE)
    graphics.off()
    rm(list=setdiff(ls(all.names=TRUE), c(ovars, "ovars")))

    message(sprintf("- #%d of %d example(%s, package='foreach') using plan(%s) ... DONE", ii, length(topics), topic, strategy))
  } ## for (ii ...)

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** doFuture() - all foreach examples ... DONE")

options(oopts)
