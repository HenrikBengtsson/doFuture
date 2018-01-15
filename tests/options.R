source("incl/start.R")

message("*** options  ...")

globalsAs <- doFuture:::globalsAs

message("globalsAs: ", globalsAs())

plan(multisession, workers = 2L)

a <- 3.14
b <- 2
y_truth <- foreach(1:2, .export = c("a", "b")) %do% { b * a }
str(y_truth)

options(doFuture.globalsAs = "manual")
message("globalsAs: ", globalsAs())
y1 <- foreach(1:2, .export = c("a", "b")) %dopar% { b * a }
str(y1)
stopifnot(identical(y1, y_truth))

res2 <- tryCatch({
  y2 <- foreach(1:2) %dopar% { b * a }
}, error = identity)
stopifnot(inherits(res2, "error"))
res3 <- tryCatch({
  y3 <- foreach(1:2, .export = NULL) %dopar% { b * a }
}, error = identity)
stopifnot(inherits(res3, "error"))
res4 <- tryCatch({
  y4 <- foreach(1:2, .export = "b") %dopar% { b * a }
}, error = identity)
stopifnot(inherits(res4, "error"))
res5 <- tryCatch({
  y5 <- foreach(1:2, .export = "c") %dopar% { b * a }
}, error = identity)
stopifnot(inherits(res5, "error"))


options(doFuture.globalsAs = "future")
message("globalsAs: ", globalsAs())
y1 <- foreach(1:2, .export = c("a", "b")) %dopar% { b * a }
str(y1)
stopifnot(identical(y1, y_truth))
y2 <- foreach(1:2) %dopar% { b * a }
str(y2)
stopifnot(identical(y2, y_truth))
y3 <- foreach(1:2, .export = NULL) %dopar% { b * a }
str(y3)
stopifnot(identical(y3, y_truth))
y4 <- foreach(1:2, .export = "a") %dopar% { b * a }
str(y4)
stopifnot(identical(y4, y_truth))
y5 <- foreach(1:2, .export = "c") %dopar% { b * a }
str(y5)
stopifnot(identical(y5, y_truth))


options(doFuture.globalsAs = "future-with-warning")
message("globalsAs: ", globalsAs())
y1 <- foreach(1:2, .export = c("a", "b")) %dopar% { b * a }
str(y1)
stopifnot(identical(y1, y_truth))
y2 <- foreach(1:2) %dopar% { b * a }
str(y2)
stopifnot(identical(y2, y_truth))
y3 <- foreach(1:2, .export = NULL) %dopar% { b * a }
str(y3)
stopifnot(identical(y3, y_truth))
y4 <- foreach(1:2, .export = "a") %dopar% { b * a }
str(y4)
stopifnot(identical(y4, y_truth))
y5 <- foreach(1:2, .export = "c") %dopar% { b * a }
str(y5)
stopifnot(identical(y5, y_truth))


## Assert warnings, if any
res1 <- tryCatch({
  foreach(1:2, .export = c("a", "b")) %dopar% { b * a }
}, warning = identity)
str(res1)
stopifnot(identical(res1, y_truth))
res2 <- tryCatch({
  foreach(1:2) %dopar% { b * a }
}, warning = identity)
str(res2)
stopifnot(inherits(res2, "warning"))
res3 <- tryCatch({
  foreach(1:2, .export = NULL) %dopar% { b * a }
}, warning = identity)
str(res3)
stopifnot(inherits(res3, "warning"))
res4 <- tryCatch({
  foreach(1:2, .export = "a") %dopar% { b * a }
}, warning = identity)
str(res4)
stopifnot(inherits(res4, "warning"))
res5 <- tryCatch({
  foreach(1:2, .export = "c") %dopar% { b * a }
}, warning = identity)
str(res5)
stopifnot(inherits(res5, "warning"))


options(doFuture.globalsAs = "future-unless-manual")
message("globalsAs: ", globalsAs())
y1 <- foreach(1:2, .export = c("a", "b")) %dopar% { b * a }
str(y1)
stopifnot(identical(y1, y_truth))
y2 <- foreach(1:2) %dopar% { b * a }
str(y2)
stopifnot(identical(y2, y_truth))
y3 <- foreach(1:2, .export = NULL) %dopar% { b * a }
str(y3)
stopifnot(identical(y3, y_truth))
res4 <- tryCatch({
  y4 <- foreach(1:2, .export = "b") %dopar% { b * a }
}, error = identity)
stopifnot(inherits(res4, "error"))
res5 <- tryCatch({
  y5 <- foreach(1:2, .export = "c") %dopar% { b * a }
}, error = identity)
stopifnot(inherits(res5, "error"))


message("- exceptions")

options(doFuture.globalsAs = "unknown")
message("globalsAs: ", globalsAs())

res <- tryCatch({
  y <- foreach(1:2) %dopar% TRUE
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))


message("*** options ... DONE")

source("incl/end.R")
