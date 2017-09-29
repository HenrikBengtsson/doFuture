source("incl/start,load-only.R")

message("*** utils ...")

message("*** mdebug() ...")

mdebug("Hello #1")
mprint(list(a = 1, b = 2))
mstr(list(a = 1, b = 2))

options(doFuture.debug = TRUE)
mdebug("Hello #2")
mprint(list(a = 1, b = 2))
mstr(list(a = 1, b = 2))

options(doFuture.debug = FALSE)
mdebug("Hello #3")
mprint(list(a = 1, b = 2))
mstr(list(a = 1, b = 2))

message("*** mdebug() ... DONE")

message("*** utils ... DONE")

source("incl/end.R")
