# CRAN submission doFuture 0.12.1

on 2022-03-30

I've verified this submission have no negative impact on any of the 20 reverse package dependencies available on CRAN and Bioconductor.

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version     | GitHub | R-hub    | mac/win-builder |
| ------------- | ------ | -------- | --------------- |
| 3.4.x         | L      |          |                 |
| 3.6.x         | L      |          |                 |
| 4.0.x         | L M W  | L        |                 |
| 4.1.x         | L M W  | L M M1 W | M1 W            |
| devel         |   M W  | L        |    W            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platform = c(
  "debian-clang-devel", "debian-gcc-patched", "linux-x86_64-centos-epel",
  "macos-highsierra-release-cran", "macos-m1-bigsur-release",
  "windows-x86_64-release"))
print(res)
```

gives

```
── doFuture 0.12.1: OK

  Build ID:   doFuture_0.12.1.tar.gz-a52026c4f5cd4fa8ab54b76673d00a45
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  7m 40.9s ago
  Build time: 5m 27.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1: OK

  Build ID:   doFuture_0.12.1.tar.gz-37ebcc48c08e418380e59f7f4cc42117
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  7m 40.9s ago
  Build time: 4m 39.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1: OK

  Build ID:   doFuture_0.12.1.tar.gz-c5c0c6428afa4defad9eb5a201750530
  Platform:   CentOS 8, stock R from EPEL
  Submitted:  7m 40.9s ago
  Build time: 3m 59.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1: WARNING

  Build ID:   doFuture_0.12.1.tar.gz-b39d28581da94b72ad89740ba51397b5
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  7m 40.9s ago
  Build time: 2m 33.1s

❯ checking whether package ‘doFuture’ can be installed ... WARNING
  Found the following significant warnings:
  Warning: package 'foreach' was built under R version 4.1.3
  Warning: package 'future' was built under R version 4.1.3

0 errors ✔ | 1 warning ✖ | 0 notes ✔

── doFuture 0.12.1: OK

  Build ID:   doFuture_0.12.1.tar.gz-b7e4ed47e59d4cbbb21f6b523597f693
  Platform:   Apple Silicon (M1), macOS 11.6 Big Sur, R-release
  Submitted:  7m 40.9s ago
  Build time: 2m 12.8s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1: WARNING

  Build ID:   doFuture_0.12.1.tar.gz-d37b3e0ba91b466e92b4360059c5054d
  Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
  Submitted:  7m 40.9s ago
  Build time: 3m 43.8s

❯ checking whether package 'doFuture' can be installed ... WARNING
  Found the following significant warnings:
  Warning: package 'foreach' was built under R version 4.1.3
  Warning: package 'future' was built under R version 4.1.3
```
