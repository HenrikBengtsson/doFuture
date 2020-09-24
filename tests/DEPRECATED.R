source("incl/start.R")

message("*** DEPRECATED & DEFUNCT ...")

message("- options")

options(doFuture.globals.nullexport = TRUE)
res <- tryCatch({
  y <- foreach(1:2) %dopar% TRUE
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))
options(doFuture.globals.nullexport = NULL)

options(doFuture.foreach.export = "automatic")
res <- tryCatch({
  y <- foreach(1:2) %dopar% TRUE
}, error = identity)
print(res)
stopifnot(inherits(res, "error"))

options(doFuture.foreach.export = ".export-and-automatic")
res <- tryCatch({
  y <- foreach(1:2) %dopar% TRUE
}, warning = identity)
print(res)
#stopifnot(inherits(res, "warning"))

message("*** DEPRECATED & DEFUNCT ... DONE")

source("incl/end.R")
