

<div id="badges"><!-- pkgdown markup -->
<a href="https://CRAN.R-project.org/web/checks/check_results_doFuture.html"><img border="0" src="https://www.r-pkg.org/badges/version/doFuture" alt="CRAN check status"/></a> <a href="https://github.com/HenrikBengtsson/doFuture/actions?query=workflow%3AR-CMD-check"><img border="0" src="https://github.com/HenrikBengtsson/doFuture/actions/workflows/R-CMD-check.yaml/badge.svg?branch=develop" alt="R CMD check status"/></a>     <a href="https://app.codecov.io/gh/HenrikBengtsson/doFuture"><img border="0" src="https://codecov.io/gh/HenrikBengtsson/doFuture/branch/develop/graph/badge.svg" alt="Coverage Status"/></a> 
</div>

# doFuture: Use Foreach to Parallelize via the Future Framework 

## Introduction

The **[future]** package provides a generic API for using futures in
R.  A future is a simple yet powerful mechanism to evaluate an R
expression and retrieve its value at some point in time.  Futures can
be resolved in many different ways depending on which strategy is
used.  There are various types of synchronous and asynchronous futures
to choose from in the **[future]** package.  Additional future
backends are implemented in other packages.  For instance, the
**[future.batchtools]** package provides futures for _any_ type of
backend that the **[batchtools]** package supports.  For an
introduction to futures in R, please consult the vignettes of the
**[future]** package.

The **[foreach]** package implements a map-reduce API with functions
`foreach()` and `times()` that provides us with powerful methods for
iterating over one or more sets of elements with the option to do it
in parallel.


## Two alternatives

The **[doFuture]** package provides two alternatives for using futures
with **foreach**:

 1. `registerDoFuture()` + `y <- foreach(...) %dopar% { ... }`.
 
 2. `y <- foreach(...) %dofuture% { ... }`


### Alternative 1: `registerDoFuture()` + `%dopar%`

The _first alternative_ is based on the traditional **foreach**
approach where one registers a foreach adapter to be used by `%dopar%`.
A popular adapter is `doParallel::registerDoParallel()`, which
parallelizes on the local machine using the **parallel** package.
This package provides `registerDoFuture()`, which parallelizes using
the **future** package, meaning any future-compliant parallel backend
can be used.

An example is:

```r
library(doFuture)
registerDoFuture()
plan(multisession)

y <- foreach(x = 1:4, y = 1:10) %dopar% {
  z <- x + y
  slow_sqrt(z)
}
```

This alternative is useful if you already have a lot of R code that
uses `%dopar%` and you just want to switch to using the future
framework for parallelization.  Using `registerDoFuture()` is also
useful when you wish to use the future framework with packages and
functions that uses `foreach()` and `%dopar%` internally,
e.g. **[caret]**, **[plyr]**, **[NMF]**, and **[glmnet]**.  It can
also be used to configure the Bioconductor **[BiocParallel]** package,
and any package that rely on it, to parallelize via the future
framework.

See `help("registerDoFuture", package = "doFuture")` for more details
and examples on this approach.


### Alternative 2: `%dofuture%`

The _second alternative_, which uses `%dofuture%`, avoids having to use
`registerDoFuture()`.  The `%dofuture%` operator provides a more
consistent behavior than `%dopar%`, e.g. there is a unique set of
foreach arguments instead of one per possible adapter.  Identification
of globals, random number generation (RNG), and error handling is
handled by the future ecosystem, just like with other map-reduce
solutions such as **[future.apply]** and **[furrr]**.
An example is:

```r
library(doFuture)
plan(multisession)

y <- foreach(x = 1:4, y = 1:10) %dofuture% {
  z <- x + y
  slow_sqrt(z)
}
```

This alternative is the recommended way to let `foreach()` parallelize
via the future framework if you start out from scratch.

See `help("%dofuture%", package = "doFuture")` for more details and
examples on this approach.


[doFuture]: https://doFuture.futureverse.org
[future]: https://future.futureverse.org
[foreach]: https://cran.r-project.org/package=foreach
[batchtools]: https://cran.r-project.org/package=batchtools
[future.batchtools]: https://future.batchtools.futureverse.org
[future.apply]: https://future.apply.futureverse.org
[furrr]: https://furrr.futureverse.org
[caret]: https://cran.r-project.org/package=caret
[plyr]: https://cran.r-project.org/package=plyr
[NMF]: https://cran.r-project.org/package=NMF
[glmnet]: https://cran.r-project.org/package=glmnet
[BiocParallel]: https://bioconductor.org/packages/BiocParallel/

## Installation
R package doFuture is available on [CRAN](https://cran.r-project.org/package=doFuture) and can be installed in R as:
```r
install.packages("doFuture")
```


### Pre-release version

To install the pre-release version that is available in Git branch `develop` on GitHub, use:
```r
remotes::install_github("HenrikBengtsson/doFuture", ref="develop")
```
This will install the package from source.  

<!-- pkgdown-drop-below -->


## Contributing

To contribute to this package, please see [CONTRIBUTING.md](CONTRIBUTING.md).

