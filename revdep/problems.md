# envi

<details>

* Version: 0.1.17
* GitHub: https://github.com/lance-waller-lab/envi
* Source code: https://github.com/cran/envi
* Date/Publication: 2023-02-02 00:40:02 UTC
* Number of recursive dependencies: 153

Run `revdep_details(, "envi")` for more info

</details>

## In both

*   checking whether package ‘envi’ can be installed ... WARNING
    ```
    Found the following significant warnings:
      Warning: no DISPLAY variable so Tk is not available
    See ‘/c4/home/henrik/repositories/doFuture/revdep/checks/envi/new/envi.Rcheck/00install.out’ for details.
    ```

# hwep

<details>

* Version: 2.0.1
* GitHub: https://github.com/dcgerard/hwep
* Source code: https://github.com/cran/hwep
* Date/Publication: 2023-03-15 16:40:05 UTC
* Number of recursive dependencies: 110

Run `revdep_details(, "hwep")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 69.0Mb
      sub-directories of 1Mb or more:
        libs  68.5Mb
    ```

*   checking for GNU extensions in Makefiles ... NOTE
    ```
    GNU make is a SystemRequirements.
    ```

# ISAnalytics

<details>

* Version: 1.8.1
* GitHub: https://github.com/calabrialab/ISAnalytics
* Source code: https://github.com/cran/ISAnalytics
* Date/Publication: 2022-12-01
* Number of recursive dependencies: 171

Run `revdep_details(, "ISAnalytics")` for more info

</details>

## In both

*   checking examples ... ERROR
    ```
    Running examples in ‘ISAnalytics-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: import_Vispa2_stats
    > ### Title: Import Vispa2 stats given the aligned association file.
    > ### Aliases: import_Vispa2_stats
    > 
    > ### ** Examples
    > 
    > fs_path <- generate_default_folder_structure(type = "correct")
    ...
      2. │ ├─ISAnalytics:::.manage_association_file(...)
      3. │ │ └─ISAnalytics:::.check_file_system_alignment(...)
      4. │ │   └─proj_fold_col %in% colnames(df)
      5. │ └─dplyr::if_else(...)
      6. │   └─dplyr:::vec_case_when(...)
      7. │     └─vctrs::list_check_all_vectors(values, arg = values_arg, call = call)
      8. └─vctrs:::stop_scalar_type(`<fn>`(NULL), "false", `<env>`)
      9.   └─vctrs:::stop_vctrs(...)
     10.     └─rlang::abort(message, class = c(class, "vctrs_error"), ..., call = call)
    Execution halted
    ```

*   checking tests ...
    ```
      Running ‘testthat.R’
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Complete output:
      > library(testthat)
      > library(ISAnalytics)
      Loading required package: magrittr
      
      Attaching package: 'magrittr'
      
    ...
       13. │                       ├─ISAnalytics:::.manage_association_file(...)
       14. │                       │ └─ISAnalytics:::.check_file_system_alignment(...)
       15. │                       │   └─proj_fold_col %in% colnames(df)
       16. │                       └─dplyr::if_else(...)
       17. │                         └─dplyr:::vec_case_when(...)
       18. │                           └─vctrs::list_check_all_vectors(values, arg = values_arg, call = call)
       19. └─vctrs:::stop_scalar_type(`<fn>`(NULL), "false", `<env>`)
       20.   └─vctrs:::stop_vctrs(...)
       21.     └─rlang::abort(message, class = c(class, "vctrs_error"), ..., call = call)
      Execution halted
    ```

*   checking re-building of vignette outputs ... ERROR
    ```
    Error(s) in re-building vignettes:
      ...
    --- re-building ‘ISAnalytics.Rmd’ using rmarkdown
    --- finished re-building ‘ISAnalytics.Rmd’
    
    --- re-building ‘sharing_analyses.Rmd’ using rmarkdown
    --- finished re-building ‘sharing_analyses.Rmd’
    
    --- re-building ‘workflow_start.Rmd’ using rmarkdown
    Quitting from lines 466-470 (workflow_start.Rmd) 
    Error: processing vignette 'workflow_start.Rmd' failed with diagnostics:
    `false` must be a vector, not `NULL`.
    --- failed re-building ‘workflow_start.Rmd’
    
    SUMMARY: processing the following file failed:
      ‘workflow_start.Rmd’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

*   checking installed package size ... NOTE
    ```
      installed size is  7.9Mb
      sub-directories of 1Mb or more:
        data   1.4Mb
        doc    4.4Mb
    ```

*   checking R code for possible problems ... NOTE
    ```
    .sh_row_permut: no visible global function definition for ‘.’
    .sharing_multdf_mult_key: no visible binding for global variable ‘.’
    .sharing_multdf_single_key: no visible binding for global variable ‘.’
    .sharing_singledf_mult_key: no visible binding for global variable ‘.’
    .sharing_singledf_single_key: no visible binding for global variable
      ‘.’
    cumulative_is: no visible binding for global variable ‘is’
    gene_frequency_fisher: no visible binding for global variable ‘.’
    Undefined global functions or variables:
      . is
    Consider adding
      importFrom("methods", "is")
    to your NAMESPACE file (and ensure that your DESCRIPTION Imports field
    contains 'methods').
    ```

# momentuHMM

<details>

* Version: 1.5.5
* GitHub: https://github.com/bmcclintock/momentuHMM
* Source code: https://github.com/cran/momentuHMM
* Date/Publication: 2022-10-18 20:52:35 UTC
* Number of recursive dependencies: 142

Run `revdep_details(, "momentuHMM")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 10.1Mb
      sub-directories of 1Mb or more:
        R      1.2Mb
        doc    1.7Mb
        libs   6.6Mb
    ```

# mslp

<details>

* Version: 1.0.1
* GitHub: NA
* Source code: https://github.com/cran/mslp
* Date/Publication: 2022-11-20
* Number of recursive dependencies: 88

Run `revdep_details(, "mslp")` for more info

</details>

## In both

*   checking re-building of vignette outputs ... ERROR
    ```
    Error(s) in re-building vignettes:
      ...
    --- re-building ‘mslp.Rmd’ using rmarkdown
    Error: processing vignette 'mslp.Rmd' failed with diagnostics:
    there is no package called ‘BiocStyle’
    --- failed re-building ‘mslp.Rmd’
    
    SUMMARY: processing the following file failed:
      ‘mslp.Rmd’
    
    Error: Vignette re-building failed.
    Execution halted
    ```

# oncomsm

<details>

* Version: 0.1.3
* GitHub: https://github.com/Boehringer-Ingelheim/oncomsm
* Source code: https://github.com/cran/oncomsm
* Date/Publication: 2023-03-11 10:20:02 UTC
* Number of recursive dependencies: 123

Run `revdep_details(, "oncomsm")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 55.7Mb
      sub-directories of 1Mb or more:
        doc    1.0Mb
        libs  53.6Mb
    ```

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘rstantools’
      All declared Imports should be used.
    ```

*   checking for GNU extensions in Makefiles ... NOTE
    ```
    GNU make is a SystemRequirements.
    ```

# projpred

<details>

* Version: 2.4.0
* GitHub: https://github.com/stan-dev/projpred
* Source code: https://github.com/cran/projpred
* Date/Publication: 2023-02-12 13:30:02 UTC
* Number of recursive dependencies: 149

Run `revdep_details(, "projpred")` for more info

</details>

## In both

*   checking package dependencies ... NOTE
    ```
    Package suggested but not available for checking: ‘cmdstanr’
    ```

# sparrpowR

<details>

* Version: 0.2.7
* GitHub: https://github.com/machiela-lab/sparrpowR
* Source code: https://github.com/cran/sparrpowR
* Date/Publication: 2023-02-02 01:00:02 UTC
* Number of recursive dependencies: 133

Run `revdep_details(, "sparrpowR")` for more info

</details>

## In both

*   checking whether package ‘sparrpowR’ can be installed ... WARNING
    ```
    Found the following significant warnings:
      Warning: no DISPLAY variable so Tk is not available
    See ‘/c4/home/henrik/repositories/doFuture/revdep/checks/sparrpowR/new/sparrpowR.Rcheck/00install.out’ for details.
    ```

# sphunif

<details>

* Version: 1.0.1
* GitHub: https://github.com/egarpor/sphunif
* Source code: https://github.com/cran/sphunif
* Date/Publication: 2021-09-02 07:40:02 UTC
* Number of recursive dependencies: 74

Run `revdep_details(, "sphunif")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 24.1Mb
      sub-directories of 1Mb or more:
        libs  23.3Mb
    ```

*   checking data for non-ASCII characters ... NOTE
    ```
      Note: found 189 marked UTF-8 strings
    ```

# sRACIPE

<details>

* Version: 1.14.0
* GitHub: https://github.com/vivekkohar/sRACIPE
* Source code: https://github.com/cran/sRACIPE
* Date/Publication: 2022-11-01
* Number of recursive dependencies: 99

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

# ssdtools

<details>

* Version: 1.0.2
* GitHub: https://github.com/bcgov/ssdtools
* Source code: https://github.com/cran/ssdtools
* Date/Publication: 2022-05-14 23:50:02 UTC
* Number of recursive dependencies: 147

Run `revdep_details(, "ssdtools")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is 23.0Mb
      sub-directories of 1Mb or more:
        doc    1.2Mb
        libs  20.6Mb
    ```

# updog

<details>

* Version: 2.1.3
* GitHub: https://github.com/dcgerard/updog
* Source code: https://github.com/cran/updog
* Date/Publication: 2022-10-18 08:00:02 UTC
* Number of recursive dependencies: 146

Run `revdep_details(, "updog")` for more info

</details>

## In both

*   checking installed package size ... NOTE
    ```
      installed size is  7.8Mb
      sub-directories of 1Mb or more:
        libs   7.1Mb
    ```

# vmeasur

<details>

* Version: 0.1.4
* GitHub: NA
* Source code: https://github.com/cran/vmeasur
* Date/Publication: 2021-11-11 19:00:02 UTC
* Number of recursive dependencies: 117

Run `revdep_details(, "vmeasur")` for more info

</details>

## In both

*   checking whether package ‘vmeasur’ can be installed ... WARNING
    ```
    Found the following significant warnings:
      Warning: no DISPLAY variable so Tk is not available
    See ‘/c4/home/henrik/repositories/doFuture/revdep/checks/vmeasur/new/vmeasur.Rcheck/00install.out’ for details.
    ```

