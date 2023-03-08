\donttest{
plan(multisession)  # parallelize futures on the local machine

y <- foreach(x = 1:10, .combine = rbind) %dofuture% {
  y <- sqrt(x)
  data.frame(x = x, y = y, pid = Sys.getpid())
}
print(y)


## Random number generation
y <- foreach(i = 1:3, .combine = rbind, .options.future = list(seed = TRUE)) %dofuture% {
  data.frame(i = i, random = runif(n = 1L)) 
}
print(y)

## Random number generation with the foreach() %:% nested operator
y <- foreach(i = 1:3, .combine = rbind) %:% foreach(j = 3:5, .combine = rbind, .options.future = list(seed = TRUE)) %dofuture% {
  data.frame(i = i, j = j, random = runif(n = 1L)) 
}
print(y)

## Random number generation with the nested foreach() calls
y <- foreach(i = 1:3, .combine = rbind, .options.future = list(seed = TRUE)) %dofuture% {
  foreach(j = 3:5, .combine = rbind, .options.future = list(seed = TRUE)) %dofuture% {
    data.frame(i = i, j = j, random = runif(n = 1L)) 
  }
}
print(y)

}

\dontshow{
## R CMD check: make sure any open connections are closed afterward
if (!inherits(plan(), "sequential")) plan(sequential)
}
