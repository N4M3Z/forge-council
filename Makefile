FORGE ?= forge

.PHONY: help install validate release clean

help:
	@echo "  make install    deploy content and install the git hooks"
	@echo "  make validate   run all checks (commit + pre-push stages)"
	@echo "  make release    build release tarball"
	@echo "  make clean      remove build artifacts"

install:
	@command -v $(FORGE) >/dev/null 2>&1 \
	    || { echo "forge not found — ask an AI assistant to execute INSTALL.md"; exit 1; }
	git config core.hooksPath .githooks
	chmod +x .githooks/* 2>/dev/null || true
	$(FORGE) install --target ~

validate:
	@bash .githooks/pre-commit
	@bash .githooks/pre-push

release:
	$(FORGE) release

clean:
	rm -rf build/
