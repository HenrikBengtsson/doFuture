## Help shut down any stray PSOCK cluster futures
future::plan("sequential")

## Restore original state
options(oopts)
future::plan(oplan)
foreach::registerDoSEQ()
rm(list = c(setdiff(ls(), ovars)))

cons1 <- showConnections(all = FALSE)
diff <- all.equal(cons1, cons0)
if (!isTRUE(diff)) {
  print(diff)
  stop("[INTERNAL ERROR] Detected stray connections after finishing test")
}

print(sessionInfo())

