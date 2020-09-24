# biotmle

<details>

* Version: 1.12.0
* GitHub: https://github.com/nhejazi/biotmle
* Source code: https://github.com/cran/biotmle
* Date/Publication: 2020-04-27
* Number of recursive dependencies: 157

Run `revdep_details(, "biotmle")` for more info

</details>

## In both

*   checking re-building of vignette outputs ... WARNING
    ```
    Error(s) in re-building vignettes:
      ...
    --- re-building ‘exposureBiomarkers.Rmd’ using rmarkdown
    Warning in grDevices::png(f) :
      unable to open connection to X11 display ''
    Quitting from lines 41-48 (exposureBiomarkers.Rmd) 
    Error: processing vignette 'exposureBiomarkers.Rmd' failed with diagnostics:
    argument is of length zero
    --- failed re-building ‘exposureBiomarkers.Rmd’
    
    SUMMARY: processing the following file failed:
      ‘exposureBiomarkers.Rmd’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

# CLVTools

<details>

* Version: 0.7.0
* GitHub: https://github.com/bachmannpatrick/CLVTools
* Source code: https://github.com/cran/CLVTools
* Date/Publication: 2020-08-26 20:10:02 UTC
* Number of recursive dependencies: 82

Run `revdep_details(, "CLVTools")` for more info

</details>

## In both

*   checking re-building of vignette outputs ... WARNING
    ```
    Error(s) in re-building vignettes:
      ...
    --- re-building ‘CLVTools.Rmd’ using rmarkdown
    Warning in grDevices::png(f) :
      unable to open connection to X11 display ''
    Warning in system2(..., stdout = if (use_file_stdout()) f1 else FALSE, stderr = f2) :
      error in running command
    ! sh: xelatex: command not found
    
    Error: processing vignette 'CLVTools.Rmd' failed with diagnostics:
    LaTeX failed to compile /home/henrik/c4/repositories/doFuture/revdep/checks/CLVTools/new/CLVTools.Rcheck/vign_test/CLVTools/vignettes/CLVTools.tex. See https://yihui.org/tinytex/r/#debugging for debugging tips. See CLVTools.log for more info.
    --- failed re-building ‘CLVTools.Rmd’
    
    SUMMARY: processing the following file failed:
      ‘CLVTools.Rmd’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

*   checking installed package size ... NOTE
    ```
      installed size is 12.6Mb
      sub-directories of 1Mb or more:
        libs  11.4Mb
    ```

# JointAI

<details>

* Version: 1.0.0
* GitHub: https://github.com/nerler/JointAI
* Source code: https://github.com/cran/JointAI
* Date/Publication: 2020-08-31 06:40:09 UTC
* Number of recursive dependencies: 131

Run `revdep_details(, "JointAI")` for more info

</details>

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘mathjaxr’
      All declared Imports should be used.
    ```

# methyvim

<details>

* Version: 1.10.0
* GitHub: https://github.com/nhejazi/methyvim
* Source code: https://github.com/cran/methyvim
* Date/Publication: 2020-04-27
* Number of recursive dependencies: 203

Run `revdep_details(, "methyvim")` for more info

</details>

## In both

*   checking tests ...
    ```
    ...
      > library(testthat)
      > library(methyvim)
      Setting options('download.file.method.GEOquery'='auto')
      Setting options('GEOquery.inmemory.gpl'=FALSE)
      methyvim v1.10.0: Targeted, Robust, and Model-free Differential Methylation Analysis
      > 
      > set.seed(43719)
      > test_check("methyvim")
      ── 1. Error: (unknown) (@test-methyvim.R#22)  ──────────────────────────────────
      'names' attribute [8] must be the same length as the vector [1]
      Backtrace:
       1. base::suppressWarnings(...)
       3. methyvim::methyvim(...)
       5. base::`colnames<-`(...)
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      [ OK: 34 | SKIPPED: 0 | WARNINGS: 0 | FAILED: 1 ]
      1. Error: (unknown) (@test-methyvim.R#22) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

*   checking re-building of vignette outputs ... WARNING
    ```
    Error(s) in re-building vignettes:
      ...
    --- re-building ‘using_methyvim.Rmd’ using rmarkdown
    Warning in grDevices::png(f) :
      unable to open connection to X11 display ''
    Quitting from lines 165-168 (using_methyvim.Rmd) 
    Error: processing vignette 'using_methyvim.Rmd' failed with diagnostics:
    argument is of length zero
    --- failed re-building ‘using_methyvim.Rmd’
    
    SUMMARY: processing the following file failed:
      ‘using_methyvim.Rmd’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

*   checking Rd cross-references ... NOTE
    ```
    Package unavailable to check Rd xrefs: ‘tmle.npvi’
    ```

# sigminer

<details>

* Version: 1.0.16
* GitHub: https://github.com/ShixiangWang/sigminer
* Source code: https://github.com/cran/sigminer
* Date/Publication: 2020-09-12 14:30:02 UTC
* Number of recursive dependencies: 191

Run `revdep_details(, "sigminer")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  6.4Mb
      sub-directories of 1Mb or more:
        extdata   3.5Mb
    ```

# sRACIPE

<details>

* Version: 1.4.0
* GitHub: https://github.com/vivekkohar/sRACIPE
* Source code: https://github.com/cran/sRACIPE
* Date/Publication: 2020-04-27
* Number of recursive dependencies: 101

Run `revdep_details(, "sRACIPE")` for more info

</details>

## In both

*   checking re-building of vignette outputs ... WARNING
    ```
    Error(s) in re-building vignettes:
      ...
    --- re-building ‘sRACIPE.Rmd’ using rmarkdown
    Warning in grDevices::png(f) :
      unable to open connection to X11 display ''
    Quitting from lines 18-19 (sRACIPE.Rmd) 
    Error: processing vignette 'sRACIPE.Rmd' failed with diagnostics:
    argument is of length zero
    --- failed re-building ‘sRACIPE.Rmd’
    
    SUMMARY: processing the following file failed:
      ‘sRACIPE.Rmd’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

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

