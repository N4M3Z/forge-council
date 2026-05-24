# forge-council

FORGE ?= forge

.PHONY: help install validate release clean

help:
	@echo "  make install    deploy and activate git hooks"
	@echo "  make validate   validate module structure and code"
	@echo "  make release    build release tarball (no forge CLI needed to install)"
	@echo "  make clean      remove build artifacts"

install:
	@command -v $(FORGE) >/dev/null 2>&1 \
	    || { echo "forge not found — ask an AI assistant to execute INSTALL.md"; exit 1; }
	git config core.hooksPath .githooks
	$(FORGE) install --target ~

validate:
	@bash .githooks/pre-commit

clean:
	rm -rf build/
