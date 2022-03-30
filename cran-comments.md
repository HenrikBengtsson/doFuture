# CRAN submission doFuture 0.12.1

on 2022-03-30

I've verified this submission have no negative impact on any of the 20 reverse package dependencies available on CRAN and Bioconductor.

Thank you


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version     | GitHub | R-hub    | mac/win-builder |
| ------------- | ------ | -------- | --------------- |
| 3.4.x         | L      |          |                 |
| 3.5.x         | L      |          |                 |
| 4.0.x         | L      | L        |                 |
| 4.1.x         | L M W  | L M M1 W | M1 W!           |
| devel         | L M W  | L        |    W!           |

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

  Build ID:   doFuture_0.12.1.tar.gz-2a7120eadb184eac91343260fc8c4f3a
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  10m 25.4s ago
  Build time: 5m 39.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1: OK

  Build ID:   doFuture_0.12.1.tar.gz-7669fa8df0f4445f8133bb52748378c3
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  10m 25.4s ago
  Build time: 4m 56.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1: OK

  Build ID:   doFuture_0.12.1.tar.gz-cdc736f7946b4eb7bf63e1b88e570b60
  Platform:   CentOS 8, stock R from EPEL
  Submitted:  10m 25.4s ago
  Build time: 4m 8.2s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1: WARNING

  Build ID:   doFuture_0.12.1.tar.gz-e6b16b96c6f54f7b9b93c83cc1e31389
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  10m 25.4s ago
  Build time: 2m 28.7s

❯ checking whether package ‘doFuture’ can be installed ... WARNING
  Found the following significant warnings:
  Warning: package 'foreach' was built under R version 4.1.3
  Warning: package 'future' was built under R version 4.1.3

0 errors ✔ | 1 warning ✖ | 0 notes ✔

── doFuture 0.12.1: OK

  Build ID:   doFuture_0.12.1.tar.gz-1f8a025b18bc4588935b42e30345fb33
  Platform:   Apple Silicon (M1), macOS 11.6 Big Sur, R-release
  Submitted:  10m 25.4s ago
  Build time: 2m 13.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 0.12.1: WARNING

  Build ID:   doFuture_0.12.1.tar.gz-e218d361d37a40f6a4184bdefa76bf87
  Platform:   Windows Server 2008 R2 SP1, R-release, 32/64 bit
  Submitted:  10m 25.4s ago
  Build time: 3m 51.6s

❯ checking whether package 'doFuture' can be installed ... WARNING
  Found the following significant warnings:
  Warning: package 'foreach' was built under R version 4.1.3
  Warning: package 'future' was built under R version 4.1.3
```
