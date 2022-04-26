# CRAN submission doFuture 0.12.2

on 2022-04-25

I've verified this submission has no negative impact on any of the 23 reverse package dependencies available on CRAN and Bioconductor.

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version     | GitHub | R-hub    | mac/win-builder |
| ------------- | ------ | -------- | --------------- |
| 3.4.x         | L      |          |                 |
| 4.0.x         | L      |          |                 |
| 4.1.x         | L M W  |          |                 |
| 4.2.x         | L M W  | L M M1 W | M1 W            |
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
── doFuture 0.12.1-9000: OK

  Build ID:   doFuture_0.12.1-9000.tar.gz-302d64436d2d4e14a7d39df20d9e1c0d
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  6m 28s ago
  Build time: 5m 24.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1-9000: OK

  Build ID:   doFuture_0.12.1-9000.tar.gz-7bc324ae9aac47f9afa0a623c48de998
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  6m 28s ago
  Build time: 4m 39.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1-9000: OK

  Build ID:   doFuture_0.12.1-9000.tar.gz-97d60d93d28e44e3a6a7b50c327e2d52
  Platform:   CentOS 8, stock R from EPEL
  Submitted:  6m 28s ago
  Build time: 3m 49.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1-9000: WARNING

  Build ID:   doFuture_0.12.1-9000.tar.gz-39ae1203542f427fb72fcc7c48ca3d9a
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  6m 28s ago
  Build time: 2m 27.9s

❯ checking whether package ‘doFuture’ can be installed ... WARNING
  Found the following significant warnings:
  Warning: package 'foreach' was built under R version 4.1.3
  See 'C:/Users/USERgWxYhQuaeJ/doFuture.Rcheck/00install.out' for details.

0 errors ✔ | 1 warning ✖ | 0 notes ✔

── doFuture 0.12.1-9000: OK

  Build ID:   doFuture_0.12.1-9000.tar.gz-746098d9a1d342048a7a097fecab8af1
  Platform:   Apple Silicon (M1), macOS 11.6 Big Sur, R-release
  Submitted:  6m 28s ago
  Build time: 1m 27.7s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1-9000: WARNING

  Build ID:   doFuture_0.12.1-9000.tar.gz-4ffbb71b8d864e12998bf98a4c049b9a
  Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
  Submitted:  6m 28.1s ago
  Build time: 3m 49.3s

❯ checking whether package 'doFuture' can be installed ... WARNING
  Found the following significant warnings:
  Warning: package 'foreach' was built under R version 4.1.3
  See 'C:/Users/USERgWxYhQuaeJ/doFuture.Rcheck/00install.out' for details.

0 errors ✔ | 1 warning ✖ | 0 notes ✔
```
