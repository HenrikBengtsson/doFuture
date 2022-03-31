## Help shut down any stray PSOCK cluster futures
future::plan("sequential")

## Restore original state
options(oopts)
future::plan(oplan)
foreach::registerDoSEQ()

cons1 <- showConnections(all = FALSE)
diff <- all.equal(cons1, cons0)
if (!isTRUE(diff)) {
  cat("Connections before:\n")
  print(cons0)
  cat("Connections after:\n")
  print(cons1)
  cat("Difference:\n")
  print(diff)
  stop("[INTERNAL ERROR] Detected stray connections after finishing test")
}

rm(list = c(setdiff(ls(), ovars)))

print(sessionInfo())

