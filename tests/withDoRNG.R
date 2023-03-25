source("incl/start.R")

strategies <- future:::supportedStrategies()

if (require("doRNG")) {
  truth <- NULL
  
  my_fcn_dopar <- function() {
    y <- foreach(i = 1:10) %dopar% {
      sample.int(n = 100L, size = 1L)
    }
    mean(unlist(y))
  }

  my_fcn_dorng <- function() {
    y <- foreach(i = 1:10) %dorng% {
      sample.int(n = 100L, size = 1L)
    }
    mean(unlist(y))
  }

  registerDoFuture()

  message("*** withDoRNG() ...")
  print(sessionInfo())

  for (strategy in strategies) {
    message(sprintf("- plan('%s') ...", strategy))
    plan(strategy)

    if (is.null(truth)) {
      set.seed(1234)
      truth <- my_fcn_dorng()
    }
    
    set.seed(1234)
    res <- withDoRNG(my_fcn_dopar())
    print(res)
    stopifnot(identical(res, truth))

    # Shutdown current plan
    plan(sequential)

    message(sprintf("- plan('%s') ... DONE", strategy))
  } ## for (strategy ...)

  message("*** withDoRNG() ... DONE")

} ## if (require("doRNG"))

source("incl/end.R")
