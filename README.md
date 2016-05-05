# doFuture: Foreach Parallel Adaptor using the Future API of the 'future' Package

## Introduction
The [future] package provides a generic API for using futures in R.
A future is a simple yet powerful mechanism to evaluate an R expression
and retrieve its value at some point in time.  Futures can be resolved
in many different ways depending on which strategy is used.
There are various types of synchronous and asynchronous futures to
choose from in the [future] package.
Additional futures are implemented in other packages.
For instance, the [future.BatchJobs] package provides futures for
_any_ type of backend that the [BatchJobs] package supports.
For an introduction to futures in R, please consult the
vignettes of the [future] package.

The [doFuture] package provides a `%dopar%` adaptor for the [foreach]
package that works with _any_ type of future.
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
foreach(i=1:3) %dopar% {
  rnorm(i, mean=mu, sd=sigma)
}
```

## doFuture bring foreach to the HPC cluster
To do the same on high-performance computing (HPC) cluster, the
[future.BatchJobs] package can be used.  Assuming BatchJobs has
been configured correctly, then following foreach iterations will
be submitted to the HPC job scheduler and distributed for
evaluation on one of the compute nodes.
```r
library("doFuture")
registerDoFuture()
library("future.BatchJobs")
plan(batchjobs)

mu <- 1.0
sigma <- 2.0
foreach(i=1:3) %dopar% {
  rnorm(i, mean=mu, sd=sigma)
}
```


## doFuture replaces existing doNnn packages

Due to the generic nature of future, the [doFuture] package
provides the same functionality as many of the existing doNnn
packages combined, e.g. [doMC], [doParallel], [doMPI], and [doSNOW].

<table style="width: 100%;">
<tr>
<th>doNnn usage</th><th>doFuture alternative</th>
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
plan(cluster, cluster=cl)
</code></pre>
</td>
</tr>


<tr style="vertical-align: center;">
<td>
<pre><code class="r">library("doMPI")
cl <- startMPIcluster(count=4)
registerDoMPI(cl)

</code></pre>
</td>
<td>
<pre><code class="r">library("doFuture")
registerDoFuture()
cl <- makeCluster(4, type="MPI")
plan(cluster, cluster=cl)
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
plan(cluster, cluster=cl)
</code></pre>
</td>
</tr>

<table>

Comment: There is currently no known future implementation and therefore no known [doFuture] alternative to the [doRedis] packages.



## Futures for plyr
The [plyr] package uses [foreach] as a parallel backend.  This means that with [doFuture] any type of futures can be used for asynchronous (and synchronous) plyr processing including multicore, multisession, MPI, ad hoc clusters and HPC job schedulers.  For example,
```r
library("doFuture")
registerDoFuture()
plan(multiprocess)

library("plyr")
x <- list(a = 1:10, beta = exp(-3:3), logic = c(TRUE,FALSE,FALSE,TRUE))
llply(x, quantile, probs = 1:3/4, .parallel=TRUE)
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


[BatchJobs]: http://cran.r-project.org/package=BatchJobs
[doFuture]: https://github.com/HenrikBengtsson/doFuture
[doMC]: http://cran.r-project.org/package=doMC
[doMPI]: http://cran.r-project.org/package=doMPI
[doParallel]: http://cran.r-project.org/package=doParallel
[doSNOW]: http://cran.r-project.org/package=doSNOW
[foreach]: http://cran.r-project.org/package=foreach
[future]: http://cran.r-project.org/package=future
[future.BatchJobs]: https://github.com/HenrikBengtsson/future.BatchJobs
[plyr]: http://cran.r-project.org/package=plyr

## Installation
R package doFuture is only available via [GitHub](https://github.com/HenrikBengtsson/doFuture) and can be installed in R as:
```r
source('http://callr.org/install#HenrikBengtsson/doFuture')
```




## Software status

| Resource:     | GitHub        | Travis CI     | Appveyor         |
| ------------- | ------------------- | ------------- | ---------------- |
| _Platforms:_  | _Multiple_          | _Linux_       | _Windows_        |
| R CMD check   |  | <a href="https://travis-ci.org/HenrikBengtsson/doFuture"><img src="https://travis-ci.org/HenrikBengtsson/doFuture.svg" alt="Build status"></a> | <a href="https://ci.appveyor.com/project/HenrikBengtsson/dofuture"><img src="https://ci.appveyor.com/api/projects/status/github/HenrikBengtsson/doFuture?svg=true" alt="Build status"></a> |
| Test coverage |                     |    |                  |
