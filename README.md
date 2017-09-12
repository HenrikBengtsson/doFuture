# doFuture: A Universal Foreach Parallel Adaptor using the Future API of the 'future' Package

## Introduction
The [future] package provides a generic API for using futures in R.
A future is a simple yet powerful mechanism to evaluate an R expression
and retrieve its value at some point in time.  Futures can be resolved
in many different ways depending on which strategy is used.
There are various types of synchronous and asynchronous futures to
choose from in the [future] package.
Additional futures are implemented in other packages.
For instance, the [future.batchtools] package provides futures for
_any_ type of backend that the [batchtools] package supports.
For an introduction to futures in R, please consult the
vignettes of the [future] package.

The [doFuture] package provides a `%dopar%` adaptor for the [foreach]
package that works with _any_ type of future.
The doFuture package is cross platform just as the future package.

Below is an example showing how to make `%dopar%` work with
_multiprocess_ futures.  A multiprocess future will be evaluated in
parallel using forked processes.  If process forking is not supported
by the operating system, then multiple background R sessions will
instead be used to resolve the futures.

```r
library("doFuture")
registerDoFuture()
plan(multiprocess)

mu <- 1.0
sigma <- 2.0
x <- foreach(i = 1:3, .export = c("mu", "sigma")) %dopar% {
  rnorm(i, mean = mu, sd = sigma)
}
```

## Futures bring foreach to the HPC cluster
To do the same on high-performance computing (HPC) cluster, the
[future.batchtools] package can be used.  Assuming batchtools has
been configured correctly, then following foreach iterations will
be submitted to the HPC job scheduler and distributed for
evaluation on the compute nodes.
```r
library("doFuture")
registerDoFuture()
library("future.batchtools")
plan(batchjobs_slurm)

mu <- 1.0
sigma <- 2.0
x <- foreach(i = 1:3, .export = c("mu", "sigma")) %dopar% {
  rnorm(i, mean = mu, sd = sigma)
}
```


## Futures for plyr
The [plyr] package uses [foreach] as a parallel backend.  This means that with [doFuture] any type of futures can be used for asynchronous (and synchronous) plyr processing including multicore, multisession, MPI, ad hoc clusters and HPC job schedulers.  For example,
```r
library("doFuture")
registerDoFuture()
plan(multiprocess)

library("plyr")
x <- list(a = 1:10, beta = exp(-3:3), logic = c(TRUE, FALSE, FALSE, TRUE))
y <- llply(x, quantile, probs = (1:3) / 4, .parallel = TRUE)
## $a
##  25%  50%  75%
## 3.25 5.50 7.75
##
## $beta
##       25%       50%       75%
## 0.2516074 1.0000000 5.0536690
##
## $logic
## 25% 50% 75%
## 0.0 0.5 1.0
```


## Futures and BiocParallel
The [BiocParallel] package supports any `%dopar%` adaptor as a parallel backend.  This means that with [doFuture], BiocParallel supports any type of future.  For example,
```r
library("doFuture")
registerDoFuture()
plan(multiprocess)
library("BiocParallel")
register(DoparParam(), default = TRUE)

mu <- 1.0
sigma <- 2.0
x <- bplapply(1:3, mu = mu, sigma = sigma, function(i, mu, sigma) {
  rnorm(i, mean = mu, sd = sigma)
})
```


## doFuture takes care of global variables for foreach

The foreach package has some support for automated handling of globals, but it does not work in all cases.  Specifically, if `foreach()` is called from within a function, you do need to export globals explicitly.  For example, although globals `a` and `b` are properly exported when we do
```r
> library("doParallel")
> registerDoParallel(parallel::makeCluster(2))
> mu <- 1.0
> sigma <- 2.0
> x <- foreach(i = 1:3) %dopar% { rnorm(i, mean = mu, sd = sigma) }
> str(x)
List of 3
 $ : num -1.42
 $ : num [1:2] 3.12 -1.33
 $ : num [1:3] -0.0376 -0.1446 1.6368
```
it falls short as soon as we try
```r
> foo <- function() foreach(i = 1:3) %dopar% { rnorm(i, mean = mu, sd = sigma) }
> x <- foo()
Error in { : task 1 failed - "object 'mu' not found"
```
The solution is to explicitly export global variables, e.g.
```r
> foo <- function() {
+   foreach(i = 1:3, .export = c("mu", "sigma")) %dopar% {
+     rnorm(i, mean = mu, sd = sigma)
+   }
+ }
> x <- foo()
```

However, when using the `%dopar%` adaptor of doFuture, all of the [future] machinery comes in to play including automatic handling of global variables, e.g.
```r
> library("doFuture")
> registerDoFuture()
> plan(cluster, workers = 2)
> mu <- 1.0
> sigma <- 2.0
> foo <- function() foreach(i = 1:3) %dopar% { rnorm(i, mean = mu, sd = sigma) }
> x <- foo()
> str(x)
List of 3
 $ : num 0.358
 $ : num [1:2] 3.317 -0.689
 $ : num [1:3] -0.104 1.237 2.474
```

Having said all this, in order to write foreach code that works everywhere, it is better to be conservative and not assume that all end users will use a doFuture backend.  Because of this, it is still recommended to explicitly specify all objects that need to be export whenever using the foreach API.



## doFuture replaces existing doNnn packages

Due to the generic nature of futures, the [doFuture] package
provides the same functionality as many of the existing doNnn
packages combined, e.g. [doMC], [doParallel], [doMPI], and [doSNOW].

<table style="width: 100%;">
<tr>
<th>doNnn usage</th><th>doFuture alternative</th>
</tr>

<tr style="vertical-align: center;">
<td>
<pre><code class="r">library("foreach")
registerDoSEQ()

</code></pre>
</td>
<td>
<pre><code class="r">library("doFuture")
registerDoFuture()
plan(sequential)
</code></pre>
</td>
</tr>

<tr style="vertical-align: center;">
<td>
<pre><code class="r">library("doMC")
registerDoMC()

</code></pre>
</td>
<td>
<pre><code class="r">library("doFuture")
registerDoFuture()
plan(multicore)
</code></pre>
</td>
</tr>

<tr style="vertical-align: center;">
<td>
<pre><code class="r">library("doParallel")
registerDoParallel()

</code></pre>
</td>
<td>
<pre><code class="r">library("doFuture")
registerDoFuture()
plan(multiprocess)
</code></pre>
</td>
</tr>

<tr style="vertical-align: center;">
<td>
<pre><code class="r">library("doParallel")
cl <- makeCluster(4)
registerDoParallel(cl)

</code></pre>
</td>
<td>
<pre><code class="r">library("doFuture")
registerDoFuture()
cl <- makeCluster(4)
plan(cluster, workers = cl)
</code></pre>
</td>
</tr>


<tr style="vertical-align: center;">
<td>
<pre><code class="r">library("doMPI")
cl <- startMPIcluster(count = 4)
registerDoMPI(cl)

</code></pre>
</td>
<td>
<pre><code class="r">library("doFuture")
registerDoFuture()
cl <- makeCluster(4, type = "MPI")
plan(cluster, workers = cl)
</code></pre>
</td>
</tr>


<tr style="vertical-align: center;">
<td>
<pre><code class="r">library("doSNOW")
cl <- makeCluster(4)
registerDoSNOW(cl)

</code></pre>
</td>
<td>
<pre><code class="r">library("doFuture")
registerDoFuture()
cl <- makeCluster(4)
plan(cluster, workers = cl)
</code></pre>
</td>
</tr>

<table>

Comment: There is currently no known future implementation and therefore no known [doFuture] alternative to the [doRedis] packages.



[batchtools]: https://cran.r-project.org/package=batchtools
[BiocParallel]: https://bioconductor.org/packages/release/bioc/html/BiocParallel.html
[doFuture]: https://cran.r-project.org/package=doFuture
[doMC]: https://cran.r-project.org/package=doMC
[doMPI]: https://cran.r-project.org/package=doMPI
[doParallel]: https://cran.r-project.org/package=doParallel
[doRedis]: https://cran.r-project.org/package=doRedis
[doSNOW]: https://cran.r-project.org/package=doSNOW
[foreach]: https://cran.r-project.org/package=foreach
[future]: https://cran.r-project.org/package=future
[future.batchtools]: https://cran.r-project.org/package=future.batchtools
[plyr]: https://cran.r-project.org/package=plyr

## Installation
R package doFuture is available on [CRAN](https://cran.r-project.org/package=doFuture) and can be installed in R as:
```r
install.packages('doFuture')
```

### Pre-release version

To install the pre-release version that is available in Git branch `develop` on GitHub, use:
```r
source('http://callr.org/install#HenrikBengtsson/doFuture@develop')
```
This will install the package from source.  



## Contributions

This Git repository uses the [Git Flow](http://nvie.com/posts/a-successful-git-branching-model/) branching model (the [`git flow`](https://github.com/petervanderdoes/gitflow-avh) extension is useful for this).  The [`develop`](https://github.com/HenrikBengtsson/doFuture/tree/develop) branch contains the latest contributions and other code that will appear in the next release, and the [`master`](https://github.com/HenrikBengtsson/doFuture) branch contains the code of the latest release, which is exactly what is currently on [CRAN](https://cran.r-project.org/package=doFuture).

Contributing to this package is easy.  Just send a [pull request](https://help.github.com/articles/using-pull-requests/).  When you send your PR, make sure `develop` is the destination branch on the [doFuture repository](https://github.com/HenrikBengtsson/doFuture).  Your PR should pass `R CMD check --as-cran`, which will also be checked by <a href="https://travis-ci.org/HenrikBengtsson/doFuture">Travis CI</a> and <a href="https://ci.appveyor.com/project/HenrikBengtsson/dofuture">AppVeyor CI</a> when the PR is submitted.


## Software status

| Resource:     | CRAN        | Travis CI       | Appveyor         |
| ------------- | ------------------- | --------------- | ---------------- |
| _Platforms:_  | _Multiple_          | _Linux & macOS_ | _Windows_        |
| R CMD check   | <a href="https://cran.r-project.org/web/checks/check_results_doFuture.html"><img border="0" src="http://www.r-pkg.org/badges/version/doFuture" alt="CRAN version"></a> | <a href="https://travis-ci.org/HenrikBengtsson/doFuture"><img src="https://travis-ci.org/HenrikBengtsson/doFuture.svg" alt="Build status"></a>   | <a href="https://ci.appveyor.com/project/HenrikBengtsson/dofuture"><img src="https://ci.appveyor.com/api/projects/status/github/HenrikBengtsson/doFuture?svg=true" alt="Build status"></a> |
| Test coverage |                     | <a href="https://codecov.io/gh/HenrikBengtsson/doFuture"><img src="https://codecov.io/gh/HenrikBengtsson/doFuture/branch/develop/graph/badge.svg" alt="Coverage Status"/></a>     |                  |
