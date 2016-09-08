source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

message("*** doFuture - nested ...")

registerDoFuture()

for (strategy1 in strategies) {
  for (strategy2 in strategies) {
    message(sprintf("- plan(list('%s', '%s')) ...", strategy1, strategy2))
    plan(list(strategy1, strategy2))
    
    x <- foreach(a=1:2) %:% foreach(b=1:3) %dopar% {
      list(a=a, b=b, plan=plan("list"))
    } 
    
    message(sprintf("- plan(list('%s', '%s')) ... DONE", strategy1, strategy2))
  }
}

message("*** doFuture - nested ... DONE")

source("incl/end.R")
