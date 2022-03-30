## Shut down any stray PSOCK cluster futures
adHocStopPlanCluster()

## Restore original state
options(oopts)
future::plan(oplan)
foreach::registerDoSEQ()
rm(list = c(setdiff(ls(), ovars)))

print(sessionInfo())

