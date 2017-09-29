source("incl/start.R")

message("*** options  ...")

plan(multisession, workers = 2L)

a <- 3.14
y_truth <- foreach(1:2, .export = "a") %do% { 2 * a }
str(y_truth)

options(doFuture.foreach.export = "automatic")
y1 <- foreach(1:2, .export = "a") %dopar% { 2 * a }
str(y1)
stopifnot(identical(y1, y_truth))
y2 <- foreach(1:2) %dopar% { 2 * a }
str(y2)
stopifnot(identical(y2, y_truth))
y3 <- foreach(1:2, .export = NULL) %dopar% { 2 * a }
str(y3)
stopifnot(identical(y3, y_truth))

options(doFuture.foreach.export = "automatic-unless-.export")
y1 <- foreach(1:2, .export = "a") %dopar% { 2 * a }
str(y1)
stopifnot(identical(y1, y_truth))
y2 <- foreach(1:2) %dopar% { 2 * a }
str(y2)
stopifnot(identical(y2, y_truth))
y3 <- foreach(1:2, .export = NULL) %dopar% { 2 * a }
str(y3)
stopifnot(identical(y3, y_truth))
res4 <- tryCatch({
  y4 <- foreach(1:2, .export = "b") %dopar% { 2 * a }
}, error = identity)
stopifnot(inherits(res4, "error"))

options(doFuture.foreach.export = ".export")
y1 <- foreach(1:2, .export = "a") %dopar% { 2 * a }
str(y1)
stopifnot(identical(y1, y_truth))
res2 <- tryCatch({
  y2 <- foreach(1:2) %dopar% { 2 * a }
}, error = identity)
stopifnot(inherits(res2, "error"))
res3 <- tryCatch({
  y3 <- foreach(1:2, .export = NULL) %dopar% { 2 * a }
}, error = identity)
stopifnot(inherits(res3, "error"))
res4 <- tryCatch({
  y4 <- foreach(1:2, .export = "b") %dopar% { 2 * a }
}, error = identity)
stopifnot(inherits(res4, "error"))


message("- exceptions")

options(doFuture.foreach.export = "unknown")
res <- tryCatch({
  y <- foreach(1:2) %dopar% TRUE
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))

message("*** options ... DONE")

source("incl/end.R")
