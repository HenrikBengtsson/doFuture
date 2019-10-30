now <- function(x = Sys.time(), format = "[%H:%M:%OS3] ") {
  ## format(x, format = format) ## slower
  format(as.POSIXlt(x, tz = ""), format = format)
}

mdebug <- function(..., debug = getOption("doFuture.debug", FALSE)) {
  if (!debug) return()
  message(now(), ...)
}

mdebugf <- function(..., appendLF = TRUE,
                    debug = getOption("doFuture.debug", FALSE)) {
  if (!debug) return()
  message(now(), sprintf(...), appendLF = appendLF)
}

#' @importFrom utils capture.output str
mstr <- function(..., debug = getOption("doFuture.debug", FALSE)) {
  if (!debug) return()
  message(paste(now(), capture.output(str(...)), sep = "", collapse = "\n"))
}

#' @importFrom utils capture.output
mprint <- function(..., debug = getOption("doFuture.debug", FALSE)) {
  if (!debug) return()
  message(paste(now(), capture.output(print(...)), sep = "", collapse = "\n"))
}

stop_if_not <- function(...) {
  res <- list(...)
  n <- length(res)
  if (n == 0L) return()

  for (ii in 1L:n) {
    res_ii <- .subset2(res, ii)
    if (length(res_ii) != 1L || is.na(res_ii) || !res_ii) {
        mc <- match.call()
        call <- deparse(mc[[ii + 1]], width.cutoff = 60L)
        if (length(call) > 1L) call <- paste(call[1L], "...")
        stop(sQuote(call), " is not TRUE", call. = FALSE, domain = NA)
    }
  }
}

## From R.utils 2.0.2 (2015-05-23)
hpaste <- function(..., sep = "", collapse = ", ", lastCollapse = NULL, maxHead = if (missing(lastCollapse)) 3 else Inf, maxTail = if (is.finite(maxHead)) 1 else Inf, abbreviate = "...") {
  if (is.null(lastCollapse)) lastCollapse <- collapse

  # Build vector 'x'
  x <- paste(..., sep = sep)
  n <- length(x)

  # Nothing todo?
  if (n == 0) return(x)
  if (is.null(collapse)) return(x)

  # Abbreviate?
  if (n > maxHead + maxTail + 1) {
    head <- x[seq_len(maxHead)]
    tail <- rev(rev(x)[seq_len(maxTail)])
    x <- c(head, abbreviate, tail)
    n <- length(x)
  }

  if (!is.null(collapse) && n > 1) {
    if (lastCollapse == collapse) {
      x <- paste(x, collapse = collapse)
    } else {
      xT <- paste(x[1:(n-1)], collapse = collapse)
      x <- paste(xT, x[n], sep = lastCollapse)
    }
  }

  x
} # hpaste()


stealth_sample.int <- function(n, size = n, replace = FALSE, ...) {
  oseed <- .GlobalEnv$.Random.seed
  on.exit({
    if (is.null(oseed)) {
      rm(list = ".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    } else {
      .GlobalEnv$.Random.seed <- oseed
    }
  })
  sample.int(n = n, size = size, replace = replace, ...)
}


import_from <- function(name, default = NULL, package) {
  ns <- getNamespace(package)
  if (exists(name, mode = "function", envir = ns, inherits = FALSE)) {
    get(name, mode = "function", envir = ns, inherits = FALSE)
  } else if (!is.null(default)) {
    default
  } else {
    stop(sprintf("No such '%s' function: %s()", package, name))
  }
}

import_future <- function(name, default = NULL) {
  import_from(name, default = default, package = "future")
}
