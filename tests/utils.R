source("incl/start.R")

hpaste <- doFuture:::hpaste
stealth_sample.int <- doFuture:::stealth_sample.int
printf <- function(...) cat(sprintf(...))

message("*** utils ...")

message("*** hpaste() ...")

# Some vectors
x <- 1:6
y <- 10:1
z <- LETTERS[x]

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Abbreviation of output vector
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
printf("x = %s.\n", hpaste(x))
## x = 1, 2, 3, ..., 6.

printf("x = %s.\n", hpaste(x, maxHead = 2))
## x = 1, 2, ..., 6.

printf("x = %s.\n", hpaste(x), maxHead = 3) # Default
## x = 1, 2, 3, ..., 6.

# It will never output 1, 2, 3, 4, ..., 6
printf("x = %s.\n", hpaste(x, maxHead = 4))
## x = 1, 2, 3, 4, 5 and 6.

# Showing the tail
printf("x = %s.\n", hpaste(x, maxHead = 1, maxTail = 2))
## x = 1, ..., 5, 6.

# Turning off abbreviation
printf("y = %s.\n", hpaste(y, maxHead = Inf))
## y = 10, 9, 8, 7, 6, 5, 4, 3, 2, 1

## ...or simply
printf("y = %s.\n", paste(y, collapse = ", "))
## y = 10, 9, 8, 7, 6, 5, 4, 3, 2, 1

# Change last separator
printf("x = %s.\n", hpaste(x, lastCollapse = " and "))
## x = 1, 2, 3, 4, 5 and 6.

# No collapse
stopifnot(all(hpaste(x, collapse = NULL) == x))

# Empty input
stopifnot(identical(hpaste(character(0)), character(0)))

message("*** hpaste() ... DONE")


message("- stealth_sample.int() ...")

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

message("- stealth_sample.int() ... DONE")

message("*** utils ... DONE")

source("incl/end.R")
