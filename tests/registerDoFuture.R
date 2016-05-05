library("doFuture")

message("*** registerDoFuture() ...")

message("doSEQ() %dopar% information:")
registerDoSEQ()
message(getDoParName())
message(getDoParVersion())
message(getDoParWorkers())

registerDoFuture()
message("doFuture() %dopar% information:")
message(getDoParName())
message(getDoParVersion())
message(getDoParWorkers())

message("*** registerDoFuture() ... DONE")
