findRdTopics <- function(package) {
  path <- find.package(package)
  file <- file.path(path, "help", "aliases.rds")
  topics <- readRDS(file)
  unique(topics)
} ## findRdTopics()


## Tweak plyr to always use .parallel=TRUE
tweakPlyr <- function() {
  ns <- getNamespace("plyr")
  llply <- getFromNamespace("llply", ns=ns)
  formals(llply)$.parallel <- TRUE
  assignInNamespace("llply", llply, ns=ns)

  setup_parallel <- getFromNamespace("setup_parallel", ns=ns)
  body(setup_parallel) <- body(setup_parallel)[-3]
  assignInNamespace("setup_parallel", setup_parallel, ns=ns)
} ## tweakPlyr()


message("*** doFuture() - all plyr examples ...")

library("future")
oopts <- options(mc.cores=2L, warn=1L, digits=3L, warnPartialMatchArgs=FALSE)
strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")
strategies <- getOptions("doFuture.tests.strategies", strategies)

library("doFuture")
registerDoFuture()
library("plyr")
tweakPlyr()
topics <- getOptions("doFuture.tests.topics", findRdTopics("plyr"))

## Some examples give errors when used with futures
excl <- getOptions("doFuture.tests.topics.ignore", "ozone")
topics <- setdiff(topics, excl)

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  for (ii in seq_along(topics)) {
    topic <- topics[ii]
    message(sprintf("- #%d of %d example(%s, package='plyr') using plan(%s) ...", ii, length(topics), topic, strategy))

    example(topic, package="plyr", character.only=TRUE, ask=FALSE)
    graphics.off()

    message(sprintf("- #%d of %d example(%s, package='plyr') using plan(%s) ... DONE", ii, length(topics), topic, strategy))
  } ## for (ii ...)

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** doFuture() - all plyr examples ... DONE")

options(oopts)
