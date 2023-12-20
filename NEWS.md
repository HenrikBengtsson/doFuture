# Version 1.0.1 (2023-12-19)

## Bug Fixes

 * Using `.options.future = list(conditions = NULL)` would be ignored
   as if it would never had been specified.


# Version 1.0.0 (2023-03-23)

## New Features

 * Add `%dofuture%` operator, which can be used like `%dopar%`, but
   without the need for `registerDoFuture()`, e.g. `y <- foreach(x =
   1:3) %dofuture% { slow_fcn(x) }`.  One advantage, contrary to using
   `%dopar%`, is that a developer then has full control on
   `foreach()`; with `%dopar%` the exact behavior depends also on what
   `%dopar%` adapter the user has registered.  Another advantage is
   that `%dofuture%` can hand over random number generation,
   identification of globals, and error handling to the future
   ecosystem, which result in a more predictable and concise behavior,
   similar to that provided by **future.apply** and **furrr**.

 * Now **future** operators such as `%stdout%` and `%conditions%` can
   be used to control the corresponding `options.future` arguments,
   e.g. `y <- foreach(i = 1:3) %dopar% { my_fun(i) } %stdout% FALSE`
   is the same as `y <- foreach(i = 1:3, .options.future = list(stdout
   = FALSE)) %dopar% { my_fun(i) }`.
   
 * Add `withDoRNG()` for evaluating a foreach `%dopar%` expression
   with `doRNG::registerDoRNG()` temporarily set.


# Version 0.12.2 [2022-04-25]

## Performance

 * Now captured standard output and conditions are deleted as soon as
   they have been relayed. This requires **future** (>= 1.25.0).


# Version 0.12.1 [2022-03-30]

## Performance

 * `options(doFuture.rng.onMisuse = "ignore")` is now a tad faster
   than before.

## Miscellaneous

 * Moved all internal opt-in package tests that test
   `registerDoFuture()` with popular packages (e.g. **BiocParallel**,
   **foreach**, **plyr**, **caret**, **glmnet**, **NSP**, and **TSP**)
   relying on **foreach** to a separate **doFuture.tests.extra**
   package.  This reduced the size of the package tarball from 140 kB
   to 40 kB.
 

# Version 0.12.0 [2021-01-02]

## New Features

 * Now `registerDoFuture()` returns the previously set foreach
   backend, making it possible to reset the the foreach backend to the
   previous settings.

 * Now **doFuture** recognizes when it is called via the
   **BiocParallel** package in which case it skips the check whether
   or not RNG was used by mistake.
 
 * Add option `doFuture.rng.onMisuse` which can be used to temporarily
   override option `future.rng.onMisuse` when the **doFuture** adaptor
   is running.

 * Add option `doFuture.workarounds`, which can be set by environment
   variable `R_DOFUTURE_WORKAROUNDS` when the package is loaded.

 * Adding `"BiocParallel.DoParam.errors"` to option
   `doFuture.workarounds` will prefix `RngFutureError` messages with
   `"task <index> failed - "` in order for such errors to be
   recognized by the **BiocParallel** DoParam backend.


# Version 0.11.0 [2020-12-11]

## New Features

 * `foreach()` argument `.options.snow = list(preschedule =
   <logical>)` is now acknowledged as a fallback to analogous argument
   `.options.multicore` - two arguments defined by the **doMC** and
   the **doSNOW** packages and also used by the **doParallel**
   package.  As before, argument `.options.future` will always take
   precedence if `list(scheduling = <logical>/<numeric>)` or
   `list(chunk.size = <integer>)` is given.

 * Warnings and errors produced when using the RNG without using
   `%dorng%` of the **doRNG** package are now tailored to the
   **doFuture** package.

## Bug Fixes

 * `foreach()` argument `.noexport` was completely ignored by
   **doFuture**.

## Deprecated and Defunct

 * Removed defunct option `doFuture.foreach.export` values
   `"automatic"` and `"automatic-unless-.export"`. They were made
   defunct in **doFuture** 0.8.2.


# Version 0.10.0 [2020-09-23]

## Significant Changes

 * Package now only imports packages **globals**, **iterators**,
 **parallel** and **utils** - packages that were attached previously.

## New Features

 * `%dorng%` of the **doRNG** package no longer produces a warning on
   'Foreach loop had changed the current RNG type: RNG was restored to
   same type, next state' when using the **doFuture** adapter.
   
## Documentation

 * The package help incorrectly mentioned `chunk_size`, which now has
   been corrected to mention `chunk.size`.


# Version 0.9.0 [2020-01-10]

## New Features

 * Now **doFuture** sets a label on each future that reflects its name
   and the index of the chunk, e.g. `"doFuture-3"`.

 * **doFuture** will now detect when **doRNG** is in use allowing
   underlying futures to skip the test of incorrectly generated random
   numbers - an optional validation of parallel RNG that will be added
   to **future** (>= 1.16.0).


# Version 0.8.2 [2019-10-29]

## Documentation

 * Document also `.options.future = list(chunk.size = <count>)` to
   `foreach()`.

## Deprecated and Defunct

 * Option `doFuture.foreach.export` values `automatic-unless-.export`
   and `automatic` are defunct. They have been deprecated since
   **doFuture** 0.7.0.

## Bug Fixes

 * Package could set `.Random.seed` to NULL, instead of removing it,
   which in turn would produce a warning on ".Random.seed is not an
   integer vector but of type `NULL`, so ignored" when the next random
   number generated.


# Version 0.8.1 [2019-07-20]

## New Features

 * Standard output and conditions are now relayed as soon as possible.

## Bug Fixes

 * One of the package tests had a `_R_CHECK_LENGTH_1_LOGIC2_=true`
   bug. This bug did _not_ affect how the package worked or any of its
   results.
 

# Version 0.8.0 [2019-03-17]

## New Features

 * The `foreach()` argument `.options.future` (a named list) can
   already be used to control whether "chunking" should take place or
   not, and if so, how much, e.g. `.options.future = list(scheduling =
   2.0))`.  As an alternative to `scheduling`, this can now be
   specified by `chunk.size` - the number of elements processed per
   future ("chunk").  In R 3.5.0, the **parallel** package introduced
   argument `chunk.size`.

 * Elements can be processed in random order by setting attribute
   `ordering` of `.options.future` elements `chunk.size` or
   `scheduling`, e.g.  `.options.future = list(chunk.size =
   structure(TRUE, ordering = "random"))`.  This improve load
   balancing in cases where there is a correlation between processing
   time and ordering of the elements. Note that the order of the
   returned values is not affected when randomizing the processing
   order.

 * Passing argument `.options.future = list(stdout = ...)` can be used
   to to control how standard output should be relayed.  See
   `?future::Future` for further details.  Analogously,
   `.options.future = list(conditions = ...)` can be used to control
   how messages and warnings are relayed, if at all.

 * Debug messages are now prepended with a timestamp.
 

# Version 0.7.0 [2019-01-05]

## Significant Changes

 * Globals are now searched for also among elements that `foreach()`
   iterates over, e.g. `foreach(f = F, g = G) %dopar% { f() + g() }`.
   
## New Features

 * The maximum total size of globals allowed (option
   `future.globals.maxSize`) per future ("chunk") is now scaled up by
   the number of elements processed by the future ("chunk") making the
   protection approximately invariant to the amount of chunking done
   by **foreach**.
   
 * Added support for option `doFuture.foreach.export = "manual"`,
   which will strictly follow argument `.export` of `foreach()` for
   identifying global variables.  None of the **future** + **globals**
   framework for identifying global variables will be used. This is
   useful for asserting that the `.export` argument is correct.

## Documentation

 * Added section on Random Number Generation (RNG) to
   `help("doFuture")` and updated `example("doFuture")` with a
   best-practices RNG example.

## Software Quality

 * TESTS: The opt-in tests for third-party packages now run their
   examples with `example(..., run.dontrun = TRUE)` to cover even more
   use cases.

 * TESTS: Added **future.callr** to the backend opt-in tested with
   **plyr**.

## Bug Fixes

 * If the **doFuture** package is missing on a worker, an error on
   "length(results) == nbr_of_elements is not TRUE" would be produced.
   Now a more informative error is produced.

 * `foreach(..., .export)` with `.export` containing `"..."` would
   produce an error when using **globals** (<= 0.11.0).

 * `foreach()` would not relay captured conditions as provided by
   **future** (>= 0.11.0).

## Deprecated and Defunct

 * Previously deprecated option `doFuture.foreach.nullexport` is
   defunct.

 * Option `doFuture.foreach.export` values `automatic-unless-.export`
   and `automatic` are defunct and will fall back to
   `export-and-automatic`.


# Version 0.6.0 [2017-10-17]

## New Features

 * **doFuture** now respects option `future.globals.resolve` instead
   of being hardcoded to always resolve globals
   (`future.globals.resolve = TRUE`).  This makes **doFuture**
   consistent with other future frontends.

 * Added option `doFuture.foreach.export` making it possible ignore a
   faulty `.export` argument to `foreach()` and instead rely on the
   future framework to identify globals.  For instance, all examples
   of **caret** 6.0-77 works with **doFuture** and any backend when
   setting this option to `"automatic"` (or `".export-and-automatic"`)
   whereas they will only work on forked backends if using `".export"`
   or the default `"automatic-unless-.export"`.  If using
   `".export-and-automatic-with-warning"`, a warning that lists
   globals potentially missing from the `.export` argument is produced
   - this is helpful for developers writing `foreach()` code.
   
## Documentation

 * Added `help("doFuture.options")`.

## Software Quality

 * TESTS: The **doFuture** package gained more opt-in tests for
   third-party packages across all known future backends.  These tests
   are not performed on the CRAN servers; instead they are performed
   on Travis CI.  Third-party packages that are currently tested are:
   **caret**, **foreach**, **glmnet**, **NMF**, **plyr**, and **TSP**.

 * TESTS: Testing global functions that call themselves recursively.


# Version 0.5.1 [2017-09-11]

## Random Number Generation

 * Package now suggests **doRNG** (>= 1.6.6), which fixes several bugs
   in **doRNG** (>= 1.6) previously suggested.
   
## Software Quality

 * TESTS: Adding tests for globals part of other packages for
   **future.BatchJobs** and **future.batchtools** futures because in
   previous versions of those, such globals would not be found because
   the corresponding package was never attached in the worker.
 

# Version 0.5.0 [2017-03-31]

## New Features

 * Added `foreach()` option to control whether scheduling ("chunking")
   should take place or not, and if so, how granular it should be.
   This is specified as `foreach(..., .options.future =
   list(scheduling = <value>))`.  With `scheduling = 1.0` (or
   equivalently `scheduling = TRUE`), the the elements (iterations)
   will be split up in equally sized chunks such that each backend
   worker will process exactly one chunk.  With `scheduling = Inf` (or
   equivalently `scheduling = FALSE`), chunking is disabled, i.e. each
   worker process exactly one element at the time.  If `scheduling =
   0.0`, then a single workers processes all elements (and the other
   workers will not be used).  If `2.0`, then each worker will process
   two chunks, and so on.  If above option is not set, then
   `.options.multicore = list(preschedule = <logical>))` which is
   defined by **doParallel**, is used to mean scheduling =
   preschedule.  If that is not set, then `scheduling = 1.0` is used
   by default.

## Software Quality
	 
 * TESTS: Now the **doFuture** package tests can be configured to also
   run the the help examples of the **foreach** and **plyr** packages
   with the **doFuture** adapter.  To further increase the coverage of
   these tests, the **plyr** example code is tweaked on-the-fly to set
   `.parallel = TRUE`.  The default is to test against all of the
   future strategies that comes with the **future** package, but it is
   possible to also test against **future.BatchJobs**,
   **future.batchtools**, and so on.  These tests are performed on all
   possible future backends before each release (as well as via
   continuous integration).

## Bug Fixes

 * Using a nested `foreach()` call would incorrectly produce an error
   on not being able to locate the iterator variable of the inner-most
   `foreach()` as a global variable.

 * If a `foreach()` call would result in an error, the error thrown
   would report on "object 'expr' not found" and not the actually
   error message.


# Version 0.4.0 [2017-03-13]

## Significant Changes

 * SPEED / LOAD BALANCING: The **doFuture** `%dopar%` backend now
   processes all elements in chunks such that each backend worker will
   process a subset of data at once (and only once).  This
   significantly speeds up processing time when iterating over a large
   number of elements that each has short a processing time.
  
## Globals

 * For consistency, globals and packages are now identified the same
   way as they are when using regular futures.
 
## Software Quality
	 
 * Now the package tests **future.batchtools** with **foreach** by
   itself, in combination with **plyr** (`parallel = TRUE`) as well as
   with `BiocParallel::bplapply()` and friends.  Similar tests are
   already done using **future.BatchJobs**.

 * Added test for `foreach::times() %dopar% { ... }`.  Especially, it
   is now tested that global variables are properly identified.  Note
   that `times()` does not allow you to specify neither `.export` nor
   `.packages` so it is not really designed for processing in external
   R process.  Having said this, `times()` does indeed work also in
   those cases when used with **doFuture** because it internally
   handles this automatically.

 * ROBUSTNESS: The package redundancy tests (not run by `R CMD check`;
   needed to be run manually for now) that run 89 **plyr** examples
   with the **doFuture** **foreach** adapter, now forces testing of
   `.parallel = TRUE` for all **plyr** functions that support that
   argument.  Each example is run across various future strategies,
   including 'sequential', 'multicore', 'multisession', and 'cluster',
   as well as 'batchjobs_local' and 'batchtools_local', if installed.
   See **doFuture** 0.2.0 notes below for how to run these tests.
   

# Version 0.3.0 [2016-10-27]

## New Features

 * Now argument `.export` of `foreach()` is acknowledged such that if
   a character vector of variables names to be exported is specified,
   then those variables and nothing else are exported to the future.
   If NULL, then automatic lookup of global variables is used.

## Bug Fixes

 * Nested future strategies were not respected by nested `%dopar%`
   calls, because **doFuture** forgot to remind **foreach** that
   **doFuture** should be used also deeper down.  Thank you Alex
   Vorobiev for reporting on this.
   
 
# Version 0.2.1 [2016-09-07]

## Bug Fixes

 * Internal R expression created to attach packages was not fully
   correct (but it still worked).
 
 
# Version 0.2.0 [2016-06-25]

## Software Quality

 * ROBUSTNESS: Added package redundancy tests that runs all examples
   of the **foreach** and the **plyr** packages using **doFuture** and
   all known types of futures.  These tests are not package tests and
   need to be run manually.  The test scripts are available in package
   directory `path <- system.file("tests2", package="doFuture")` and
   can be run as `source(file.path(path, "plyr", "examples.R"))`.
   
 * ROBUSTNESS: Added package tests validating `foreach()` on regular
   as well as **future.BatchJobs** futures.  Same for **plyr** and
   **BiocParallel** apply functions.
 
 
# Version 0.1.3 [2016-05-07]

## Documentation

 * Added package help page, i.e. `help("doFuture")`.

## Random Number Generation

 * Added package tests asserting random number generator (RNG)
   reproducibility when using the **doRNG** package.
 
 
# Version 0.1.2 [2016-05-05]

## New Features

 * Now `foreach::getDoParWorkers()` gives useful information with
   `registerDoFuture()` in most cases.  In cases where the number of
   workers cannot be inferred easily from `future::plan()` it will
   default to returning a large number (= 99).
 
 
# Version 0.1.1 [2016-05-05]

## New Features

 * Now `foreach::getDoParName()` and `foreach::getDoParVersion()`
   gives useful information with `registerDoFuture()`.


# Version 0.1.0 [2016-05-04]

 * Created.
