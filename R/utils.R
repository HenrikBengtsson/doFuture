## FIXME: This should probably be a feature of the future package.
## The below function only knows of the futures in the future package.
## For future strategies that are not covered by the below
## implementation, we assume that an "infinite" number (=99) of workers
## are available.  The latter will cover cases such as schedulers
## where one can submit any number of jobs to the queue. /HB 2016-05-05
#' @importFrom future plan
numberOfFutureWorkers <- function(unknown=99L) {
  evaluator <- plan()

  ## Uniprocess futures?
  if (inherits(evaluator, "uniprocess")) return(1L)

  ## Multicore futures?
  if (inherits(evaluator, "multicore")) {
    expr <- formals(evaluator)$maxCores
    maxCores <- eval(expr)
    stopifnot(length(maxCores) == 1, is.finite(maxCores), maxCores >= 1)
    return(maxCores)
  }

  ## Multisession futures?
  if (inherits(evaluator, "multisession")) {
    expr <- formals(evaluator)$maxCores
    maxCores <- eval(expr)
    stopifnot(length(maxCores) == 1, is.finite(maxCores), maxCores >= 1)
    return(maxCores)
  }

  ## Cluster futures?
  if (inherits(evaluator, "cluster")) {
    expr <- formals(evaluator)$cluster
    cluster <- eval(expr)
    stopifnot(is.list(cluster), length(cluster) >= 1)
    return(length(cluster))
  }

  stopifnot(length(unknown) == 1, is.finite(unknown), unknown >= 1)

  unknown
} ## numberOfFutureWorkers()
