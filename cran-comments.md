# CRAN submission doFuture 1.0.0

on 2023-03-23

I've verified this submission has no negative impact on any of the 28
reverse package dependencies available on CRAN (n = 25) and
Bioconductor (n = 3).

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
| devel         |   M W  | L        | M1 W            |

*Legend: OS: L = Linux, M = macOS, M1 = macOS M1, W = Windows*


R-hub checks:

```r
res <- rhub::check(platforms = c(
  "debian-clang-devel", 
  "fedora-gcc-devel",
  "debian-gcc-patched", 
  "macos-highsierra-release-cran",
  "windows-x86_64-release"
))
print(res)
```

gives

```
── doFuture 1.0.0: OK

  Build ID:   doFuture_1.0.0.tar.gz-add7c87b36474032b5ee8037779b2528
  Platform:   Debian Linux, R-devel, clang, ISO-8859-15 locale
  Submitted:  34m 26.7s ago
  Build time: 29m 55.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 1.0.0: OK

  Build ID:   doFuture_1.0.0.tar.gz-b042f14934fa455c802e26f658d47ef8
  Platform:   Fedora Linux, R-devel, GCC
  Submitted:  34m 26.8s ago
  Build time: 19m 39.5s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 1.0.0: OK

  Build ID:   doFuture_1.0.0.tar.gz-643e2ee8ce954e27ba6b7458cb1d8fd7
  Platform:   Debian Linux, R-patched, GCC
  Submitted:  34m 26.8s ago
  Build time: 28m 37.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

── doFuture 1.0.0: WARNING

  Build ID:   doFuture_1.0.0.tar.gz-9f9e303dfde04c1f8aec8f15c286504d
  Platform:   macOS 10.13.6 High Sierra, R-release, CRAN's setup
  Submitted:  34m 26.8s ago
  Build time: 4m 33.8s

❯ checking whether package ‘doFuture’ can be installed ... WARNING
  Found the following significant warnings:
  Warning: package ‘foreach’ was built under R version 4.1.2
  Warning: package ‘future’ was built under R version 4.1.2
 
0 errors ✔ | 1 warning ✖ | 0 notes ✔

── doFuture 1.0.0: WARNING

  Build ID:   doFuture_1.0.0.tar.gz-c3471cb849c04f629c13a7207da4b191
  Platform:   Windows Server 2022, R-release, 32/64 bit
  Submitted:  34m 26.8s ago
  Build time: 4m 13.8s

❯ checking whether package 'doFuture' can be installed ... WARNING
  Found the following significant warnings:
  Warning: package 'foreach' was built under R version 4.2.3
  Warning: package 'future' was built under R version 4.2.3

0 errors ✔ | 1 warning ✖ | 0 notes ✔
```
