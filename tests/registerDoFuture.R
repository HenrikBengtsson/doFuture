source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

message("*** registerDoFuture() ...")

message("doSEQ() %dopar% information:")
registerDoSEQ()
message(getDoParName())
message(getDoParVersion())
message(getDoParWorkers())

registerDoFuture()
message("doFuture() %dopar% information:")

for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  message(name <- getDoParName())
  stopifnot(name == "doFuture")
  message(version <- getDoParVersion())
  stopifnot(packageVersion(name) == version)
  message(nbr_of_workers <- getDoParWorkers())
  stopifnot(nbr_of_workers == nbrOfWorkers())

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** registerDoFuture() ... DONE")

source("incl/end.R")
