# CRAN submission doFuture 1.0.1

on 2023-12-19

I've verified this submission has no negative impact on any of the 31
reverse package dependencies available on CRAN (n = 28) and
Bioconductor (n = 3).

Thanks in advance


## Notes not sent to CRAN

### R CMD check validation

The package has been verified using `R CMD check --as-cran` on:

| R version     | GitHub | R-hub | mac/win-builder |
| ------------- | ------ | ----- | --------------- |
| 3.6.x         | L      |       |                 |
| 4.1.x         | L      |       |                 |
| 4.2.x         | L M W  |       |                 |
| 4.3.x         | L M W  | L   W | M1 w            |
| devel         |   M W  | L   W |    w            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platforms = c(
  "debian-clang-devel", 
  "fedora-gcc-devel",
  "debian-gcc-patched", 
  "windows-x86_64-release",
  "windows-x86_64-devel"
))
print(res)
```

gives

```
── doFuture 1.0.1: OK

  Build ID:   doFuture_1.0.1.tar.gz-d2d1c0e8e92f4336897ad9ecfaea5898
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  3h 22m 50.1s ago
  Build time: 43m 23.9s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 1.0.1: OK

  Build ID:   doFuture_1.0.1.tar.gz-0faa99fcb4d3451899de07650b564871
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  3h 22m 50.1s ago
  Build time: 27m 51.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 1.0.1: OK

  Build ID:   doFuture_1.0.1.tar.gz-3248c60109994678b5ded376a7a6110e
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  3h 22m 50.1s ago
  Build time: 40m 30.1s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 1.0.1: OK

  Build ID:   doFuture_1.0.1.tar.gz-6d21ce57affe4093bf8fd2279a274aa5
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  3h 22m 50.1s ago
  Build time: 6m 59.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 1.0.1: OK

  Build ID:   doFuture_1.0.1.tar.gz-694e54c649bc4622aac18ad3fb720bc2
  Platform:   Windows Server 2022, R-devel, 64 bit
  Submitted:  3h 22m 50.1s ago
  Build time: 6m 3.1s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```
