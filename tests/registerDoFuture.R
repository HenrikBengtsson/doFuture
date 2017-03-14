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
  message(nbrOfWorkers <- getDoParWorkers())
  stopifnot(nbrOfWorkers == nbrOfWorkers())

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** registerDoFuture() ... DONE")

print(sessionInfo())

source("incl/end.R")
