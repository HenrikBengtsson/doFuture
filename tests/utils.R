source("incl/start.R")

stealth_sample.int <- doFuture:::stealth_sample.int

message("*** utils ...")

message("- stealth_sample.int()")

if (exists(".Random.seed", envir = globalenv(), inherits = FALSE)) {
  rm(".Random.seed", envir = globalenv(), inherits = FALSE)
}

stopifnot(!exists(".Random.seed", envir = globalenv(), inherits = FALSE))
x <- stealth_sample.int(10L)
str(x)
stopifnot(!exists(".Random.seed", envir = globalenv(), inherits = FALSE))

set.seed(42L)
seed0 <- globalenv()[[".Random.seed"]]
stopifnot(!is.null(seed0))
x0 <- stealth_sample.int(10L)
str(x0)
seed <- globalenv()[[".Random.seed"]]
stopifnot(!is.null(seed), identical(seed, seed0))

x <- stealth_sample.int(10L)
str(x)
stopifnot(identical(x, x0))
seed <- globalenv()[[".Random.seed"]]
stopifnot(!is.null(seed), identical(seed, seed0))

message("*** utils ... DONE")

source("incl/end.R")
