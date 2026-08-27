.PHONY: help verify package diagnostics uninstall

help:
	@printf '%s\n' 'Targets:' '  verify       Run repository self-check' '  package      Create release ZIP + SHA256' '  diagnostics  Collect local diagnostics' '  uninstall    Remove installed VAMPIRE prefix'

verify:
	./scripts/repo_self_check.sh

package:
	./scripts/package_release.sh

diagnostics:
	./scripts/collect_diagnostics.sh

uninstall:
	./scripts/uninstall.sh
