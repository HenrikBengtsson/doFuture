\donttest{
library("doFuture")
registerDoFuture()
plan(multiprocess)

mu <- 1.0
sigma <- 2.0
foreach(i=1:3) %dopar% {
  rnorm(i, mean=mu, sd=sigma)
}
}
