# biotmle

<details>

* Version: 1.8.0
* Source code: https://github.com/cran/biotmle
* URL: https://code.nimahejazi.org/biotmle
* BugReports: https://github.com/nhejazi/biotmle/issues
* Date/Publication: 2019-05-02
* Number of recursive dependencies: 104

Run `revdep_details(,"biotmle")` for more info

</details>

## In both

*   checking examples ... ERROR
    ```
    ...
    
        values
    
    The following object is masked from ‘package:GenomicRanges’:
    
        values
    
    The following object is masked from ‘package:IRanges’:
    
        values
    
    The following object is masked from ‘package:S4Vectors’:
    
        values
    
    Loading required package: foreach
    Loading required package: iterators
    Error: BiocParallel errors
      element index: 1
      first error: task 1 failed - "group length is 0 but data length > 0"
    Execution halted
    ```

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
             family = "gaussian", g_lib = c("SL.mean", "SL.glm"), Q_lib = "SL.mean") at testthat/test-modtest_ic.R:19
      2: BiocParallel::bplapply(Y[, seq_along(Y)], biomarkerTMLE_exposure, W = W, A = A, a = unique(A), 
             g_lib = g_lib, Q_lib = Q_lib, family = family, subj_ids = subj_ids, ...)
      3: BiocParallel::bplapply(Y[, seq_along(Y)], biomarkerTMLE_exposure, W = W, A = A, a = unique(A), 
             g_lib = g_lib, Q_lib = Q_lib, family = family, subj_ids = subj_ids, ...)
      4: bplapply(X, FUN, ..., BPREDO = BPREDO, BPPARAM = BPPARAM)
      5: bplapply(X, FUN, ..., BPREDO = BPREDO, BPPARAM = BPPARAM)
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      [ OK: 5 | SKIPPED: 0 | WARNINGS: 2 | FAILED: 2 ]
      1. Error: (unknown) (@test-biomarkertmle.R#20) 
      2. Error: (unknown) (@test-modtest_ic.R#19) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

# methyvim

<details>

* Version: 1.6.0
* Source code: https://github.com/cran/methyvim
* URL: https://github.com/nhejazi/methyvim
* BugReports: https://github.com/nhejazi/methyvim/issues
* Date/Publication: 2019-05-02
* Number of recursive dependencies: 184

Run `revdep_details(,"methyvim")` for more info

</details>

## In both

*   checking examples ... ERROR
    ```
    ...
    The following object is masked from ‘package:SummarizedExperiment’:
    
        values
    
    The following object is masked from ‘package:GenomicRanges’:
    
        values
    
    The following object is masked from ‘package:IRanges’:
    
        values
    
    The following object is masked from ‘package:S4Vectors’:
    
        values
    
    Loading required package: nnls
    > methyvolc(methyvim_out_ate)
    Error in Math.factor(pval) : ‘log10’ not meaningful for factors
    Calls: methyvolc ... mutate -> mutate.tbl_df -> mutate_impl -> Math.factor
    Execution halted
    ```

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      [2] -0.06913 - -0.07124 == 2.11e-03
      [3]  0.00658 -  0.00379 == 2.79e-03
      [4]  0.00149 -  0.00147 == 2.69e-05
      [5]  0.07352 -  0.06274 == 1.08e-02
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      [ OK: 45 | SKIPPED: 0 | WARNINGS: 0 | FAILED: 5 ]
      1. Failure: Variable importance results in tolerance and of correct length (@test-methyvim.R#61) 
      2. Failure: ATE procedure with M-values is consistent for target site (@test-tmle_classic.R#27) 
      3. Failure: RR procedure with M-values is consistent for target site (@test-tmle_classic.R#49) 
      4. Failure: ATE procedure with Beta-values is consistent for target site (@test-tmle_classic.R#72) 
      5. Failure: RR procedure with Beta-values is consistent for target site (@test-tmle_classic.R#94) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

*   checking whether the package can be unloaded cleanly ... WARNING
    ```
    Error in setGeneric("bumphunter", function(object, ...) { : 
      could not find function "setGeneric"
    Error: package or namespace load failed for ‘methyvim’:
     unable to load R code in package ‘bumphunter’
    Execution halted
    ```

*   checking whether the namespace can be loaded with stated dependencies ... WARNING
    ```
    Error in setGeneric("bumphunter", function(object, ...) { : 
      could not find function "setGeneric"
    Error: unable to load R code in package ‘bumphunter’
    Execution halted
    
    A namespace must be able to be loaded with just the base namespace
    loaded: otherwise if the namespace gets loaded by a saved object, the
    session will be unable to start.
    
    Probably some imports need to be declared in the NAMESPACE file.
    ```

*   checking S3 generic/method consistency ... WARNING
    ```
    ...
    5: value[[3L]](cond)
    4: tryCatchOne(expr, names, parentenv, handlers[[1L]])
    3: tryCatchList(expr, classes, parentenv, handlers)
    2: tryCatch({
           attr(package, "LibPath") <- which.lib.loc
           ns <- loadNamespace(package, lib.loc)
           env <- attachNamespace(ns, pos = pos, deps, exclude, include.only)
       }, error = function(e) {
           P <- if (!is.null(cc <- conditionCall(e))) 
               paste(" in", deparse(cc)[1L])
           else ""
           msg <- gettextf("package or namespace load failed for %s%s:\n %s", 
               sQuote(package), P, conditionMessage(e))
           if (logical.return) 
               message(paste("Error:", msg), domain = NA)
           else stop(msg, call. = FALSE, domain = NA)
       })
    1: library(package, lib.loc = lib.loc, character.only = TRUE, verbose = FALSE)
    Execution halted
    See section ‘Generic functions and methods’ in the ‘Writing R
    Extensions’ manual.
    ```

*   checking replacement functions ... WARNING
    ```
    ...
    5: value[[3L]](cond)
    4: tryCatchOne(expr, names, parentenv, handlers[[1L]])
    3: tryCatchList(expr, classes, parentenv, handlers)
    2: tryCatch({
           attr(package, "LibPath") <- which.lib.loc
           ns <- loadNamespace(package, lib.loc)
           env <- attachNamespace(ns, pos = pos, deps, exclude, include.only)
       }, error = function(e) {
           P <- if (!is.null(cc <- conditionCall(e))) 
               paste(" in", deparse(cc)[1L])
           else ""
           msg <- gettextf("package or namespace load failed for %s%s:\n %s", 
               sQuote(package), P, conditionMessage(e))
           if (logical.return) 
               message(paste("Error:", msg), domain = NA)
           else stop(msg, call. = FALSE, domain = NA)
       })
    1: library(package, lib.loc = lib.loc, character.only = TRUE, verbose = FALSE)
    Execution halted
    The argument of a replacement function which corresponds to the right
    hand side must be named ‘value’.
    ```

*   checking for code/documentation mismatches ... WARNING
    ```
    ...
    Call sequence:
    6: stop(msg, call. = FALSE, domain = NA)
    5: value[[3L]](cond)
    4: tryCatchOne(expr, names, parentenv, handlers[[1L]])
    3: tryCatchList(expr, classes, parentenv, handlers)
    2: tryCatch({
           attr(package, "LibPath") <- which.lib.loc
           ns <- loadNamespace(package, lib.loc)
           env <- attachNamespace(ns, pos = pos, deps, exclude, include.only)
       }, error = function(e) {
           P <- if (!is.null(cc <- conditionCall(e))) 
               paste(" in", deparse(cc)[1L])
           else ""
           msg <- gettextf("package or namespace load failed for %s%s:\n %s", 
               sQuote(package), P, conditionMessage(e))
           if (logical.return) 
               message(paste("Error:", msg), domain = NA)
           else stop(msg, call. = FALSE, domain = NA)
       })
    1: library(package, lib.loc = lib.loc, character.only = TRUE, verbose = FALSE)
    Execution halted
    ```

*   checking dependencies in R code ... NOTE
    ```
    ...
    Call sequence:
    6: stop(msg, call. = FALSE, domain = NA)
    5: value[[3L]](cond)
    4: tryCatchOne(expr, names, parentenv, handlers[[1L]])
    3: tryCatchList(expr, classes, parentenv, handlers)
    2: tryCatch({
           attr(package, "LibPath") <- which.lib.loc
           ns <- loadNamespace(package, lib.loc)
           env <- attachNamespace(ns, pos = pos, deps, exclude, include.only)
       }, error = function(e) {
           P <- if (!is.null(cc <- conditionCall(e))) 
               paste(" in", deparse(cc)[1L])
           else ""
           msg <- gettextf("package or namespace load failed for %s%s:\n %s", 
               sQuote(package), P, conditionMessage(e))
           if (logical.return) 
               message(paste("Error:", msg), domain = NA)
           else stop(msg, call. = FALSE, domain = NA)
       })
    1: library(package, lib.loc = lib.loc, character.only = TRUE, verbose = FALSE)
    Execution halted
    ```

*   checking foreign function calls ... NOTE
    ```
    ...
    5: value[[3L]](cond)
    4: tryCatchOne(expr, names, parentenv, handlers[[1L]])
    3: tryCatchList(expr, classes, parentenv, handlers)
    2: tryCatch({
           attr(package, "LibPath") <- which.lib.loc
           ns <- loadNamespace(package, lib.loc)
           env <- attachNamespace(ns, pos = pos, deps, exclude, include.only)
       }, error = function(e) {
           P <- if (!is.null(cc <- conditionCall(e))) 
               paste(" in", deparse(cc)[1L])
           else ""
           msg <- gettextf("package or namespace load failed for %s%s:\n %s", 
               sQuote(package), P, conditionMessage(e))
           if (logical.return) 
               message(paste("Error:", msg), domain = NA)
           else stop(msg, call. = FALSE, domain = NA)
       })
    1: library(package, lib.loc = lib.loc, character.only = TRUE, verbose = FALSE)
    Execution halted
    See chapter ‘System and foreign language interfaces’ in the ‘Writing R
    Extensions’ manual.
    ```

*   checking R code for possible problems ... NOTE
    ```
    Error in setGeneric("bumphunter", function(object, ...) { : 
      could not find function "setGeneric"
    Error: unable to load R code in package ‘bumphunter’
    Execution halted
    ```

*   checking Rd \usage sections ... NOTE
    ```
    ...
    3: tryCatchList(expr, classes, parentenv, handlers)
    2: tryCatch({
           attr(package, "LibPath") <- which.lib.loc
           ns <- loadNamespace(package, lib.loc)
           env <- attachNamespace(ns, pos = pos, deps, exclude, include.only)
       }, error = function(e) {
           P <- if (!is.null(cc <- conditionCall(e))) 
               paste(" in", deparse(cc)[1L])
           else ""
           msg <- gettextf("package or namespace load failed for %s%s:\n %s", 
               sQuote(package), P, conditionMessage(e))
           if (logical.return) 
               message(paste("Error:", msg), domain = NA)
           else stop(msg, call. = FALSE, domain = NA)
       })
    1: library(package, lib.loc = lib.loc, character.only = TRUE, verbose = FALSE)
    Execution halted
    The \usage entries for S3 methods should use the \method markup and not
    their full name.
    See chapter ‘Writing R documentation files’ in the ‘Writing R
    Extensions’ manual.
    ```

# rangeMapper

<details>

* Version: 0.3-7
* Source code: https://github.com/cran/rangeMapper
* URL: https://github.com/valcu/rangeMapper
* Date/Publication: 2019-10-25 18:20:02 UTC
* Number of recursive dependencies: 88

Run `revdep_details(,"rangeMapper")` for more info

</details>

## In both

*   checking examples ... ERROR
    ```
    ...
                y@plotOrder = order(match(i, x@plotOrder))
            }
        }
        else y@bbox = x@bbox
        y
    }
    <bytecode: 0x55eca43c4ec0>
    <environment: namespace:sp>
    
    Signatures:
            x                          i         j          
    target  "SpatialPolygonsDataFrame" "missing" "character"
    defined "SpatialPolygonsDataFrame" "ANY"     "ANY"      
     --- function search by body ---
    S4 Method [:base defined in namespace methods with signature SpatialPolygonsDataFrame has this body.
    S4 Method [:base defined in namespace sp with signature SpatialPolygonsDataFrame has this body.
     ----------- END OF FAILURE REPORT -------------- 
    Error in is.numeric(i) && i < 0 : 
      'length(x) = 22 > 1' in coercion to 'logical(1)'
    Calls: processRanges -> processRanges -> .local -> [ -> [
    Execution halted
    ```

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
             "wrens", verbose = FALSE)[1:10, ] at testthat/test-4_save.R:3
      2: rgdal::readOGR(system.file(package = "rangeMapper", "extdata", "wrens", "vector_combined"), 
             "wrens", verbose = FALSE)[1:10, ]
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      [ OK: 14 | SKIPPED: 0 | WARNINGS: 0 | FAILED: 4 ]
      1. Error: Pipeline works forward only (@test-1_projectINI.R#76) 
      2. Error: (unknown) (@test-2_processRanges.R#5) 
      3. Error: (unknown) (@test-3_output.R#3) 
      4. Error: (unknown) (@test-4_save.R#3) 
      
      Error: testthat unit tests failed
      In addition: Warning message:
      call dbDisconnect() when finished working with a connection 
      Execution halted
    ```

# sperrorest

<details>

* Version: 2.1.5
* Source code: https://github.com/cran/sperrorest
* BugReports: https://github.com/pat-s/sperrorest/issues
* Date/Publication: 2018-03-27 12:20:30 UTC
* Number of recursive dependencies: 70

Run `revdep_details(,"sperrorest")` for more info

</details>

## In both

*   checking whether the package can be unloaded cleanly ... WARNING
    ```
    Error in setMethod("plot", signature(x = "performance", y = "missing"),  : 
      no existing definition for function ‘plot’
    Error: package or namespace load failed for ‘sperrorest’:
     unable to load R code in package ‘ROCR’
    Execution halted
    ```

*   checking whether the namespace can be loaded with stated dependencies ... WARNING
    ```
    Error in setMethod("plot", signature(x = "performance", y = "missing"),  : 
      no existing definition for function ‘plot’
    Error: unable to load R code in package ‘ROCR’
    Execution halted
    
    A namespace must be able to be loaded with just the base namespace
    loaded: otherwise if the namespace gets loaded by a saved object, the
    session will be unable to start.
    
    Probably some imports need to be declared in the NAMESPACE file.
    ```

*   checking dependencies in R code ... NOTE
    ```
    ...
    Call sequence:
    6: stop(msg, call. = FALSE, domain = NA)
    5: value[[3L]](cond)
    4: tryCatchOne(expr, names, parentenv, handlers[[1L]])
    3: tryCatchList(expr, classes, parentenv, handlers)
    2: tryCatch({
           attr(package, "LibPath") <- which.lib.loc
           ns <- loadNamespace(package, lib.loc)
           env <- attachNamespace(ns, pos = pos, deps, exclude, include.only)
       }, error = function(e) {
           P <- if (!is.null(cc <- conditionCall(e))) 
               paste(" in", deparse(cc)[1L])
           else ""
           msg <- gettextf("package or namespace load failed for %s%s:\n %s", 
               sQuote(package), P, conditionMessage(e))
           if (logical.return) 
               message(paste("Error:", msg), domain = NA)
           else stop(msg, call. = FALSE, domain = NA)
       })
    1: library(package, lib.loc = lib.loc, character.only = TRUE, verbose = FALSE)
    Execution halted
    ```

*   checking R code for possible problems ... NOTE
    ```
    Error in setMethod("plot", signature(x = "performance", y = "missing"),  : 
      no existing definition for function ‘plot’
    Error: unable to load R code in package ‘ROCR’
    Execution halted
    ```

