source("incl/start.R")

message("*** DEPRECATED & DEFUNCT ...")

message("- options")

options(doFuture.globals.nullexport = TRUE)
y <- foreach(1:2) %dopar% TRUE
str(y)
res <- tryCatch({
  y <- foreach(1:2) %dopar% TRUE
}, warning = identity)
print(res)
stopifnot(inherits(res, "warning"))

message("*** DEPRECATED & DEFUNCT ... DONE")

source("incl/end.R")
