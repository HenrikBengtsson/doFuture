include .make/Makefile

vignettes/future-1-overview.md.rsp: inst/vignettes-static/future-1-overview.md.rsp.rsp
	$(CD) $(@D); \
	$(R_SCRIPT) -e "R.rsp::rfile" ../$< --postprocess=FALSE

vigs: vignettes/future-1-overview.md.rsp

spelling:
	$(R_SCRIPT) -e "spelling::spell_check_package()"
	$(R_SCRIPT) -e "spelling::spell_check_files(c('NEWS', dir('vignettes', pattern='[.]rsp', full.names=TRUE)), ignore=readLines('inst/WORDLIST', warn=FALSE))"
