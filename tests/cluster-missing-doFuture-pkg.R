source("incl/start.R")
options(future.debug = FALSE)

message("*** cluster() ...")

message("Library paths: ", paste(sQuote(.libPaths()), collapse = ", "))
message("Package path: ", sQuote(system.file(package = "future")))

types <- "PSOCK"
#if (supportsMulticore()) types <- c(types, "FORK")

setupClusterWithoutPkgs <- function(type = "PSOCK",
                                    withs = c("digest", "globals",
                                              "listenv", "future"),
                                    withouts = c("doFuture")) {
  cl <- parallel::makeCluster(1L, type = type)

  ## Emulate a worker that does not have 'future' installed.
  ## by setting a different user library path on the worker.
  libs <- parallel::clusterEvalQ(cl, .libPaths(tempdir()))[[1]]
  attr(cl, "libs") <- libs

  ## 'withouts' tops 'withs' for conveniency
  withs <- setdiff(withs, withouts)
  
  ## "Install" any 'withs' packages?
  if (length(withs) > 0L) {
    paths <- find.package(withs)
    res <- parallel::clusterCall(cl, fun = sapply, X = paths,
                                 FUN = file.copy, to = libs[1],
                                 recursive = TRUE)[[1]]
    res <- parallel::clusterCall(cl, fun = sapply, X = withs,
                                 FUN = requireNamespace)[[1]]
  }
  attr(cl, "withs") <- res

  ## Check whether 'future' is still available on the worker or not.
  ## It could be that it is installed in the system library path, which
  ## in case we cannot "hide" the future package from the worker.
  res <- parallel::clusterCall(cl, fun = sapply, X = withouts,
                                   FUN = requireNamespace)[[1]]
  attr(cl, "withouts") <- res

  cl
}

cl <- NULL
for (type in types) {
  message(sprintf("Test set #1 with cluster type %s ...", sQuote(type)))

  cl <- setupClusterWithoutPkgs(type, withouts = c("future", "doFuture"))  
  if (all(attr(cl, "withs") && !all(attr(cl, "withouts")))) {
    plan(cluster, workers = cl, .init = FALSE)
    
    ## Here we will get:
    ##   <UnexpectedFutureResultError: Unexpected result (of class
    ##   'snow-try-error' != 'FutureResult') retrieved for ClusterFuture
    ##   future (label = '<none>', expression = '{ ... }'): Package 'future'
    ##   is not installed on worker (r_version: ...)>
    ## Note: This error is produced by the future backend when it recieves
    ##       the unexpected results.
    res <- tryCatch({
      y <- foreach(ii = 1:3) %dopar% ii
    }, error = identity)
    print(res)
    stopifnot(inherits(res, "FutureError"))
  }
  
  cl <- setupClusterWithoutPkgs(type)  
  if (all(attr(cl, "withs") && !all(attr(cl, "withouts")))) {
    plan(cluster, workers = cl, .init = FALSE)
    
    ## Here we will get:
    ##   <FutureError: Unexpected error in doFuture(): After gathering and
    ##   merging the results from 1 chunks in to a list, the total number
    ##   of elements (= 2) does not match the number of input elements in
    ##   'X' (= 3). There were in total 1 chunks and 1 elements (1 chunks
    ##   with 2 elements)>
    ## Note: This error is produced in doFuture(), because it currently does
    ##       not know how to deal with such errors.
    res <- tryCatch({
      y <- foreach(ii = 1:3) %dopar% ii
    }, error = identity)
    print(res)
    stopifnot(inherits(res, "FutureError"))
  }
  
  parallel::stopCluster(cl)
  cl <- NULL
  
  plan(sequential)
  
  message(sprintf("Test set #1 with cluster type %s ... DONE", sQuote(type)))
} ## for (type ...)

message("*** cluster() ... DONE")

source("incl/end.R")
