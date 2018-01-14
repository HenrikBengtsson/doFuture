#' @importFrom foreach getexports
#' @importFrom globals findGlobals
findGlobals_foreach <- function(expr, envir = parent.frame(), noexport = NULL) {
  ## Extracted from doParallel 1.0.11
  makeDotsEnv <- function(...) {
    list(...)
    function() NULL
  }

  exportenv <- tryCatch({
    qargs <- quote(list(...))
    args <- eval(qargs, envir = envir)
    environment(do.call(makeDotsEnv, args = args))
  }, error = function(e) {
    new.env(parent = emptyenv())
  })

  ## NOTE: getexports() does not identify '...'
  getexports(expr, e = exportenv, env = envir, bad = noexport)
  globals <- ls(envir = exportenv)

  ## Is '...' a global?
  if (is.element("...", findGlobals(expr, dotdotdot = "return"))) {
    globals <- c(globals, "...")
  }
  
  globals
}


getGlobalsAndPackages_fix <- local({
  if (packageVersion("globals") <= "0.11.0") {
    function(expr, envir, globals, ...) {
      ## BUG FIX/WORKAROUND: '...' must be last unless globals (> 0.11.0)
      if (packageVersion("globals") <= "0.11.0") {
        idx <- which(globals == "...")
        if (length(idx) > 0) globals <- c(globals[-idx], "...")
      }
      getGlobalsAndPackages(expr, envir = envir, globals = globals, ...)
    }
  } else {
    function(expr, envir, globals, ...) {
      getGlobalsAndPackages(expr, envir = envir, globals = globals, ...)
    }
  }
})


#' @importFrom future getGlobalsAndPackages
getGlobalsAndPackages_doFuture <- function(expr, envir, export = NULL, noexport = NULL, packages = NULL, globalsAs, debug = FALSE) {
  stopifnot(is.language(expr) || is.expression(expr))
  stopifnot(is.environment(envir))
  stopifnot(is.character(globalsAs), !anyNA(globalsAs), length(globalsAs) > 0)
  stopifnot(is.logical(debug))
  export <- unique(export)
  noexport <- unique(noexport)
  packages <- unique(packages)

  ## Set 'globalsAs' according to 'doFuture.*' options?
  if (identical(globalsAs, "*")) {
    ## Using defunct option?
    if (!is.null(getOption("doFuture.globals.nullexport"))) {
      .Defunct(msg = "Option 'doFuture.globals.nullexport' is deprecated. Use 'doFuture.globalsAs = \"future-unless-manual\" or \"manual\" instead.")
    }

    globalsAs <- getOption("doFuture.globalsAs")
    
    ## Backward compatibility with doFuture (<= 0.6.0) - with warning
    t <- getOption("doFuture.foreach.export")
    if (!is.null(t) && is.null(globalsAs)) {
      if (t %in% c("automatic", "automatic-unless-.export")) {
        .Defunct(msg = sprintf("Option doFuture.foreach.export = %s is no longer supported. The closest is doFuture.globalsAs = 'future'.", dQuote(t)))
      }
    
      if (t == ".export-and-automatic") {
        globalsAs <- "future"
      } else if (t == ".export-and-automatic-with-warning") {
        globalsAs <- "future-with-warning"
      } else {
        .Defunct(msg = sprintf("Option 'doFuture.foreach.export' is defunct and replaced by option 'doFuture.globalsAs'. Also, value '%s' is unknown.", dQuote(t)))
      }

      .Deprecated(msg = sprintf("Option doFuture.foreach.export = %s is deprecated and has been replaced by doFuture.globalsAs = %s", dQuote(t), sQuote(globalsAs)))
    }
  }

  ## No option set?
  if (is.null(globalsAs)) {
    globalsAs <- Sys.getenv("R_DOFUTURE_GLOBALSAS", "future-unless-manual")
    globalsAs <- getOption("doFuture.globalsAs.fallback", globalsAs)
  }

  ## Drop duplicates
  globalsAs <- unique(globalsAs)
  
  stopifnot(is.character(globalsAs), !anyNA(globalsAs), length(globalsAs) > 0)
  
  ## Automatic or manual?
  idxs <- grep("-unless-manual$", globalsAs)
  if (length(idxs) > 0) {
    if (is.null(export)) {
      globalsAs[idxs] <- gsub("-unless-manual$", "", globalsAs[idxs])
    } else {
      globalsAs[idxs] <- "manual"
    }
  }

  ## Warn if manual does not match automatic findings?
  withWarning <- any(grepl("-with-warning$", globalsAs))
  if (withWarning) globalsAs <- gsub("-with-warning$", "", globalsAs)

  ## Environment from where to search for globals
  globals_envir <- new.env(parent = envir)
  assign("...future.x_ii", NULL, envir = globals_envir, inherits = FALSE)

  if (globalsAs == "manual") {
    globals <- unique(c(export, "...future.x_ii"))
    gp <- getGlobalsAndPackages_fix(expr, envir = globals_envir,
                                    globals = globals)
    globals <- gp$globals
    expr <- gp$expr
    rm(list = c("gp"))
  } else if (globalsAs == "foreach") {
    globals <- findGlobals_foreach(expr, envir = envir, noexport = noexport)
    globals <- unique(c(export, "...future.x_ii"))
    gp <- getGlobalsAndPackages_fix(expr, envir = globals_envir,
                                    globals = globals)
    globals <- gp$globals
    expr <- gp$expr
    rm(list = c("gp"))
  } else if (globalsAs == "future") {
    gp <- getGlobalsAndPackages(expr, envir = globals_envir, globals = TRUE)
    globals <- gp$globals
    packages <- unique(c(gp$packages, packages))
    expr <- gp$expr
    rm(list = c("gp"))
  } else {
    stop("Unknown value of argument 'globalsAs' for registerDoFuture(): ",
         sQuote(globalsAs))
  }

  ## From here on, 'globals' is a named list with values
  stopifnot(is.list(globals))
            
  names_globals <- names(globals)

  ## Warn about globals found automatically, but not listed in '.export'?
  if (withWarning) {
    globals2 <- export
    missing <- setdiff(names_globals, c(globals2, "...future.x_ii",
                                        "future.call.arguments"))
    if (length(missing) > 0) {
      warning(sprintf("Detected a foreach(..., .export = c(%s)) call where '.export' might lack one or more variables (as identified by globalsAs = %s of which some might be false positives): %s", paste(dQuote(globals2), collapse = ", "), sQuote(globalsAs), paste(dQuote(missing), collapse = ", ")))
    }
    globals2 <- NULL
  }
  
  ## Add automatically found globals to explicit '.export' globals?
  if (globalsAs != "manual") {
    globals2 <- export
    ## Drop duplicates
    globals2 <- setdiff(globals2, names_globals)
    if (length(globals2) > 0) {
      mdebug("  - appending %d '.export' globals (not already found): %s",
             length(globals2), paste(sQuote(globals2)), collapse = ", ")
      gp <- getGlobalsAndPackages(expr, envir = globals_envir,
                                  globals = globals2)
      globals2 <- gp$globals
      packages <- unique(c(gp$packages, packages))
      globals <- c(globals, globals2)
      rm(list = "gp")
    }
    rm(list = "globals2")
  }
  
  ## At this point a globals should be resolved and we should know
  ## their total size.
  ## NOTE: This is 1st of the 2 places where we req future (>= 1.4.0)
##  stopifnot(attr(globals, "resolved"), !is.na(attr(globals, "total_size")))
  
  ## Also make sure we've got our in-house '...future.x_ii' covered.
  stopifnot("...future.x_ii" %in% names(globals))

  rm(list = c("globals_envir", "names_globals")) ## Not needed anymore

  list(expr = expr, globals = globals, packages = packages)
}
