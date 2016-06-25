## Restore original state
options(oopts)
future::plan(oplan)
foreach::registerDoSEQ()
rm(list=c(setdiff(ls(), ovars)))
