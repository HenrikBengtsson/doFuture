# CLVTools

<details>

* Version: 0.7.0
* GitHub: https://github.com/bachmannpatrick/CLVTools
* Source code: https://github.com/cran/CLVTools
* Date/Publication: 2020-08-26 20:10:02 UTC
* Number of recursive dependencies: 86

Run `revdep_details(, "CLVTools")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 12.6Mb
      sub-directories of 1Mb or more:
        libs  11.4Mb
    ```

# methyvim

<details>

* Version: 1.11.0
* GitHub: https://github.com/nhejazi/methyvim
* Source code: https://github.com/cran/methyvim
* Date/Publication: 2020-04-27
* Number of recursive dependencies: 211

Run `revdep_details(, "methyvim")` for more info

</details>

## In both

*   checking tests ...
    ```
    ...
      ── ERROR (test-methyvim.R:22:1): (code run outside of `test_that()`) ───────────
      Error: 'names' attribute [8] must be the same length as the vector [1]
      Backtrace:
          █
       1. ├─base::suppressWarnings(...) test-methyvim.R:22:0
       2. │ └─base::withCallingHandlers(...)
       3. └─methyvim::methyvim(...)
       4.   ├─base::`colnames<-`(...)
       5.   └─base::`colnames<-`(...)
      
      ── Warning (test-set_parallel.R:9:3): registers BiocParallel::DoparParam by defa
      Strategy 'multiprocess' is deprecated in future (>= 1.20.0). Instead, explicitly specify either 'multisession' or 'multicore'. In the current R session, 'multiprocess' equals 'multicore'.
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      Warning (test-cluster_sites.R:4:1): (code run outside of `test_that()`)
      ERROR (test-methyvim.R:22:1): (code run outside of `test_that()`)
      Warning (test-set_parallel.R:9:3): registers BiocParallel::DoparParam by default for parallel=TRUE
      
      [ FAIL 1 | WARN 2 | SKIP 0 | PASS 34 ]
      Error: Test failures
      Execution halted
    ```

*   checking Rd cross-references ... NOTE
    ```
    Package unavailable to check Rd xrefs: ‘tmle.npvi’
    ```

# sigminer

<details>

* Version: 1.1.0
* GitHub: https://github.com/ShixiangWang/sigminer
* Source code: https://github.com/cran/sigminer
* Date/Publication: 2020-11-11 07:40:06 UTC
* Number of recursive dependencies: 197

Run `revdep_details(, "sigminer")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  6.8Mb
      sub-directories of 1Mb or more:
        extdata   3.9Mb
    ```

# sRACIPE

<details>

* Version: 1.6.0
* GitHub: https://github.com/vivekkohar/sRACIPE
* Source code: https://github.com/cran/sRACIPE
* Date/Publication: 2020-10-27
* Number of recursive dependencies: 106

Run `revdep_details(, "sRACIPE")` for more info

</details>

## In both

*   checking R code for possible problems ... NOTE
    ```
    sracipeSimulate: no visible global function definition for
      ‘registerDoFuture’
    sracipeSimulate: no visible global function definition for ‘plan’
    sracipeSimulate: no visible global function definition for ‘%dopar%’
    sracipeSimulate: no visible global function definition for ‘foreach’
    sracipeSimulate: no visible binding for global variable
      ‘configurationTmp’
    sracipeSimulate: no visible binding for global variable ‘outFileGETmp’
    sracipeSimulate: no visible binding for global variable
      ‘outFileParamsTmp’
    sracipeSimulate: no visible binding for global variable ‘outFileICTmp’
    Undefined global functions or variables:
      %dopar% configurationTmp foreach outFileGETmp outFileICTmp
      outFileParamsTmp plan registerDoFuture
    ```

