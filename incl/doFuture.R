\donttest{
library("doFuture")
registerDoFuture()
plan(multiprocess)

my_stat <- function(x) {
  median(x)
}

my_experiment <- function(n, mu = 0.0, sigma = 1.0) {
  foreach(i = 1:n) %dopar% {
    x <- rnorm(i, mean = mu, sd = sigma)
    list(mu = mean(x), sigma = sd(x), own = my_stat(x))
  }
}

y <- my_experiment(n = 3)
str(y)
}
