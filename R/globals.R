globalsAs <- function() {
  ## Assert that defunct options are not used
  if (!is.null(getOption("doFuture.globals.nullexport"))) {
    .Defunct(msg = "Option 'doFuture.globals.nullexport' is defunct. Use 'doFuture.foreach.export = \"automatic-unless-.export\" or \".export\" instead.")
  }

  t <- getOption("doFuture.foreach.export", ".export-and-automatic")
  if (t == ".export-and-automatic") {
    globalsAs <- "future"
  } else if (t == ".export-and-automatic-with-warning") {
    globalsAs <- "future-with-warning"
  } else if (t == ".export") {
    globalsAs <- "manual"
  } else if (t %in% c("automatic", "automatic-unless-.export")) {
    .Defunct(msg = sprintf("Option doFuture.foreach.export = %s is no longer supported. The closest is doFuture.foreach.export = '.export-and-automatic', which will be used instead.", dQuote(t)))
  } else {
    .Defunct(msg = sprintf("Option doFuture.foreach.export = %s is unknown.", dQuote(t)))
  }

  stop_if_not(is.character(globalsAs), !anyNA(globalsAs), length(globalsAs) == 1)

  globalsAs
}


#' @importFrom future getGlobalsAndPackages
getGlobalsAndPackages_doFuture <- function(expr, envir, export = NULL, noexport = NULL, packages = NULL, debug = FALSE) {
  stop_if_not(is.language(expr) || is.expression(expr))
  stop_if_not(is.environment(envir))
  stop_if_not(is.logical(debug))
  export <- unique(export)
  noexport <- unique(noexport)
  packages <- unique(packages)

  globalsAs <- globalsAs()
 
  ## Warn if manual does not match automatic findings?
  withWarning <- grepl("-with-warning$", globalsAs)
  if (withWarning) globalsAs <- gsub("-with-warning$", "", globalsAs)

  ## Environment from where to search for globals
  globals_envir <- new.env(parent = envir)
  assign("...future.x_ii", NULL, envir = globals_envir, inherits = FALSE)

  globals <- list()
  scanForGlobals <- TRUE
  if (globalsAs == "manual") {
    globals_by_name <- c(export, "...future.x_ii")
    gp <- getGlobalsAndPackages(expr, envir = globals_envir,
                                globals = globals_by_name)
    globals <- gp$globals
    expr <- gp$expr
    rm(list = c("gp"))
    scanForGlobals <- FALSE
  } else if (globalsAs == "future") {
    gp <- getGlobalsAndPackages(expr, envir = globals_envir, globals = TRUE)
    globals <- gp$globals
    packages <- unique(c(gp$packages, packages))
    expr <- gp$expr
    rm(list = c("gp"))
  } else {
    stop("INTERNAL ERROR: Unknown value of 'globalsAs': ", sQuote(globalsAs))
  }

  mstr(globals)
  stop_if_not("...future.x_ii" %in% names(globals))
  
  names_globals <- names(globals)

  ## Warn about globals found automatically, but not listed in '.export'?
  if (withWarning) {
    globals2 <- export
    missing <- setdiff(names_globals, c(globals2, "...future.x_ii",
                                        "future.call.arguments"))
    if (length(missing) > 0) {
      warning(sprintf("Detected a foreach(..., .export = c(%s)) call where '.export' might lack one or more variables of which some might be false positives: %s", paste(dQuote(globals2), collapse = ", "), paste(dQuote(missing), collapse = ", ")))
    }
    globals2 <- NULL
  }
  
  ## Add automatically found globals to explicit '.export' globals?
  if (globalsAs != "manual") {
    globals2 <- setdiff(export, names_globals)
    if (length(globals2) > 0) {
      mdebugf("  - appending %d '.export' globals (not already found through automatic lookup): %s",
             length(globals2), paste(sQuote(globals2), collapse = ", "))
      gp <- getGlobalsAndPackages(expr, envir = globals_envir,
                                  globals = globals2)
      globals <- unique(c(gp$globals, globals))
      rm(list = "gp")
    }
    rm(list = "globals2")
  }

  ## At this point a globals should be resolved and we should know
  ## their total size.
  
  ## Also make sure we've got our in-house '...future.x_ii' covered.
  stop_if_not("...future.x_ii" %in% names(globals),
            !any(duplicated(names(globals))),
            !any(duplicated(packages)))

  rm(list = c("globals_envir", "names_globals")) ## Not needed anymore

  list(expr = expr, globals = globals, packages = packages, scanForGlobals = scanForGlobals)
}
