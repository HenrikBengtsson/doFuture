source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

message("*** doFuture - nested ...")

registerDoSEQ()

x0 <- foreach(a=1:5, .combine='cbind') %:%
  foreach(b=1:3, .combine='c') %do% {
    10*a + b
  }

print(x0)

registerDoFuture()

for (strategy1 in strategies) {
  for (strategy2 in strategies) {
    message(sprintf("- plan(list('%s', '%s')) ...", strategy1, strategy2))
    plan(list(strategy1, strategy2))
    
    x <- foreach(a=1:5, .combine='cbind') %:%
      foreach(b=1:3, .combine='c') %do% {
        10*a + b
      }
    
    stopifnot(identical(x, x0))
    
    message(sprintf("- plan(list('%s', '%s')) ... DONE", strategy1, strategy2))
  }
}

message("*** doFuture - nested ... DONE")

source("incl/end.R")
