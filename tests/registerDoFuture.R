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

  message(getDoParName())
  message(getDoParVersion())
  message(getDoParWorkers())

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)

message("*** registerDoFuture() ... DONE")

source("incl/end.R")
