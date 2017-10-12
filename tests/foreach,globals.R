source("incl/start.R")

strategies <- future:::supportedStrategies()
strategies <- setdiff(strategies, "multiprocess")

message("*** doFuture - automatically finiding globals ...")

## Example adopted from StackOverflow comment
## https://stackoverflow.com/a/10114192/1072091
fibonacci <- function(n) {
  if (n <= 1L) return(1L)
  return(fibonacci(n - 1L) + fibonacci(n - 2L))
}
X <- matrix(1:4, nrow = 3L, ncol = 4L)
y_truth <- foreach(rr = 1:nrow(X)) %do% {
  Vectorize(fibonacci)(X[rr, ])
}
str(y_truth)

res0 <- NULL

## Requires bug fix in globals 0.10.2-9000, cf.
## https://github.com/HenrikBengtsson/globals/issues/29
if (packageVersion("globals") > "0.10.2") {
for (strategy in strategies) {
  message(sprintf("- plan('%s') ...", strategy))
  plan(strategy)

  y <- foreach(rr = 1:nrow(X)) %dopar% {
    Vectorize(fibonacci)(X[rr, ])
  }
  str(y)
  stopifnot(all.equal(y, y_truth))

  message(sprintf("- plan('%s') ... DONE", strategy))
} ## for (strategy ...)
} ## if (packageVersion("globals") > "0.10.2")

message("*** doFuture - automatically finiding globals ... DONE")

print(sessionInfo())

source("incl/end.R")
