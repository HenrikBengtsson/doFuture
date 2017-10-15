mprintf <- function(...) message(sprintf(...))

find_rd_topics <- function(package) {
  path <- find.package(package)
  file <- file.path(path, "help", "aliases.rds")
  topics <- readRDS(file)
  unique(topics)
}

test_topics <- local({
  topics <- NULL
  function(package) {
    if (is.null(topics)) {
      topics <- getOption("doFuture.tests.topics", find_rd_topics(package))
    
      ## Some examples may give errors when used with futures
      excl <- getOption("doFuture.tests.topics.ignore", NULL)
      topics <- setdiff(topics, excl)
    }
    topics
  }
})

run_example <- function(topic, package, local = FALSE, envir = globalenv()) {
  ovars <- ls(all.names = TRUE, envir = envir)
  on.exit({
    graphics.off()
    vars <- setdiff(ls(all.names = TRUE), c(ovars, "ovars"))
    suppressWarnings(rm(list = vars, envir = envir))
  })
  
  dt <- system.time({
    utils::example(topic = topic, package = package, character.only = TRUE,
                   echo = TRUE, ask = FALSE, local = local)
  })
  
  dt <- dt[1:3]; names(dt) <- c("user", "system", "elapsed")
  dt <- paste(sprintf("%s: %g", names(dt), dt), collapse = ", ")
  message("  Total processing time for example: ", dt)
  
  invisible(dt)
}

run_examples <- function(package, topics = test_topics(package), strategy, ...) {
  if (length(topics) == 0) return

  ## Workaround for https://github.com/HenrikBengtsson/future/issues/166
  ns <- getNamespace("future")
  strategy_fcn <- get(strategy, envir = ns, mode = "function")
  
  for (ii in seq_along(topics)) {
    topic <- topics[ii]
    mprintf("- #%d of %d example('%s', package = '%s') using plan(%s) ...", ii, length(topics), topic, package, strategy) #nolint
    registerDoFuture()
    plan(strategy_fcn)
    dt <- run_example(topic = topic, package = package, ...)
    mprintf("- #%d of %d example('%s', package = '%s') using plan(%s) ... DONE (%s)", ii, length(topics), topic, package, strategy, dt) #nolint
  } ## for (ii ...)
}

package_dependencies <- function(package, needs = NULL) {
  desc <- packageDescription(package)
  what <- c("Depends", "Imports")
  if (identical(needs, "Suggests")) what <- c(what, "Suggests")
  pkgs <- unlist(strsplit(unlist(desc[what]), split = "[,\n]"),
                 use.names = FALSE)
  pkgs <- gsub(" ", "", pkgs)
  pkgs <- gsub("[(].*[)]", "", pkgs)
  pkgs <- pkgs[nzchar(pkgs)]
  excl <- c("R", "methods", "base", "compiler", "datasets", "graphics",
            "grDevices", "stats", "tools", "utils")
  pkgs <- pkgs[!pkgs %in% excl]
  if (!identical(needs, "Suggests")) pkgs <- c(pkgs, needs)
  unique(pkgs)
}

install_missing_packages <- function(pkgs, repos = "https://cloud.r-project.org") {
  oenv <- Sys.getenv("R_TESTS")
  on.exit(Sys.setenv(R_TESTS = oenv))
  Sys.setenv(R_TESTS = "")
  for (pkg in unique(pkgs)) {
    path <- system.file(package = pkg, mustWork = FALSE)
    if (nzchar(path)) next
    mprintf("- Install package: %s", pkg)
    install.packages(pkg, repos = repos)
    system.file(package = pkg, mustWork = TRUE)
  }
}

test_strategies <- function() {
  strategies <- Sys.getenv("_R_CHECK_FUTURE_STRATEGIES_",
                           "sequential,multisession")
  strategies <- getOption("doFuture.tests.strategies", strategies)
  strategies <- unlist(strsplit(strategies, split = "[, ]"))
  strategies <- strategies[nzchar(strategies)]
  ## Default is to use what's provided by the future package
  if (length(strategies) == 0) {
    strategies <- future:::supportedStrategies()
    strategies <- setdiff(strategies, c("multiprocess", "lazy", "eager"))
  }
  if (any(grepl("batchjobs_", strategies))) {
    install_missing_packages("future.BatchJobs")
    library("future.BatchJobs")
  }
  if (any(grepl("batchtools_", strategies))) {
    install_missing_packages("future.batchtools")
    library("future.batchtools")
  }
  strategies
}


tests2_step <- local({
  oopts <- NULL
  
  function(action = c("start", "end"), package = NULL, ...) {
    if (action == "start") {
      library("doFuture")
      oopts <<- options(warnPartialMatchArgs = FALSE, warn = 1L,
                        digits = 3L, mc.cores = 2L)
      if (!is.null(package)) {
        mprintf("- Attaching package: %s", package)

        ## WORKAROUND: The package tests depends on the following packages
        ## that need to be installed if missing.  This is done in order to
        ## avoid having to add them under 'Suggests:'.
        install_missing_packages(package)
        pkgs <- package_dependencies(package, ...)
        mprintf("- Dependent packages: %s", paste(pkgs, collapse = ", "))
        install_missing_packages(pkgs)
        
        library(package, character.only = TRUE)
      }
    } else if (action == "end") {
      options(oopts)
    }
    
    invisible(package)
  }
})

