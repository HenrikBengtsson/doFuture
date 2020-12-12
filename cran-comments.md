# CRAN submission doFuture 0.11.0

on 2020-12-11

I've verified this submission have no negative impact on any of the 13 reverse package dependencies available on CRAN and Bioconductor.

Thank you


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version | GitHub Actions | Travis | AppVeyor  | R-hub    | win-builder |
| --------- | -------------- | ------ | --------- | -------- | ----------- |
| 3.3.x     | L              |        |           |          |             |
| 3.4.x     | L              |        |           |          |             |
| 3.5.x     | L              |        |           |          |             |
| 3.6.x     | L              | L M    |           |          |             |
| 4.0.x     | L M            | L      |           |        S | W           |
| devel     |   M W          | L      | W (32&64) |          | W           |

*Legend: OS: L = Linux S = Solaris M = macOS W = Windows*
