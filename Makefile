# forge-council Makefile

.PHONY: help install install-agents install-skills install-skills-claude install-skills-gemini install-skills-codex clean verify verify-skills verify-skills-claude verify-skills-gemini verify-skills-codex test lint check

# Variables
AGENT_SRC = agents
SKILL_SRC = skills
LIB_DIR = lib
CLAUDE_SKILLS_DST ?= $(HOME)/.claude/skills
GEMINI_SKILLS_DST ?= $(HOME)/.gemini/skills
CODEX_SKILLS_DST ?= $(HOME)/.codex/skills

help:
	@echo "forge-council management commands:"
	@echo "  make install               Install both agents and skills"
	@echo "  make install-agents        Install specialist agents to ~/.claude/agents/ and ~/.gemini/agents/"
	@echo "  make install-skills        Install skills for Claude, Gemini, and Codex"
	@echo "  make install-skills-claude Install skills to ~/.claude/skills/"
	@echo "  make install-skills-gemini Install skills to ~/.gemini/skills/ via gemini CLI"
	@echo "  make install-skills-codex  Install skills to ~/.codex/skills/ (includes generated specialist wrappers)"
	@echo "  make verify-skills         Verify skills for Claude, Gemini, and Codex"
	@echo "  make clean                 Remove previously installed agents"
	@echo "  make verify                Verify the installation"
	@echo "  make test                  Run tests"
	@echo "  make lint                  Shellcheck all scripts"
	@echo "  make check                 Verify module structure"

install: install-agents install-skills
	@echo "Installation complete. Restart your session or reload agents/skills."

install-agents:
	@bash $(LIB_DIR)/install-agents.sh $(AGENT_SRC)

install-skills: install-skills-claude install-skills-gemini install-skills-codex

install-skills-claude:
	@bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider claude --dst "$(CLAUDE_SKILLS_DST)"

install-skills-gemini:
	@bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider gemini --dst "$(GEMINI_SKILLS_DST)"

install-skills-codex:
	@bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider codex --dst "$(CODEX_SKILLS_DST)" --include-agent-wrappers --agents-dir "$(AGENT_SRC)"

clean:
	@bash $(LIB_DIR)/install-agents.sh $(AGENT_SRC) --clean

verify-skills: verify-skills-claude verify-skills-gemini verify-skills-codex

verify-skills-claude:
	@echo "Verifying Claude skills in $(CLAUDE_SKILLS_DST)..."
	@missing=0; \
	for s in Council Demo DeveloperCouncil ProductCouncil KnowledgeCouncil; do \
	  if test -f "$(CLAUDE_SKILLS_DST)/$$s/SKILL.md"; then \
	    echo "  ok $$s"; \
	  else \
	    echo "  missing $$s"; \
	    missing=1; \
	  fi; \
	done; \
	test $$missing -eq 0

verify-skills-gemini:
	@if command -v gemini >/dev/null 2>&1; then \
	  echo "Verifying Gemini skills via CLI..."; \
	  gemini skills list | grep -E "Council|Demo|DeveloperCouncil|ProductCouncil|KnowledgeCouncil"; \
	else \
	  echo "  skip gemini skill verification (gemini CLI not installed)"; \
	fi

verify-skills-codex:
	@echo "Verifying Codex skills in $(CODEX_SKILLS_DST)..."
	@missing=0; \
	for s in Council Demo DeveloperCouncil ProductCouncil KnowledgeCouncil Developer Database DevOps DocumentationWriter Tester SecurityArchitect Architect Designer ProductManager Analyst Opponent Researcher ForensicAgent; do \
	  if test -f "$(CODEX_SKILLS_DST)/$$s/SKILL.md"; then \
	    echo "  ok $$s"; \
	  else \
	    echo "  missing $$s"; \
	    missing=1; \
	  fi; \
	done; \
	test $$missing -eq 0

test:
	@echo "No tests defined"

lint:
	@if find . -name '*.sh' -not -path '*/target/*' | grep -q .; then \
	  find . -name '*.sh' -not -path '*/target/*' | xargs shellcheck -S warning 2>/dev/null || true; \
	fi

check:
	@test -f module.yaml && echo "  ok module.yaml" || echo "  MISSING module.yaml"
	@test -d hooks && echo "  ok hooks/" || echo "  MISSING hooks/"

verify: verify-skills
	@if [ -f "VERIFY.md" ]; then \
	  echo "Running verification checks (as defined in VERIFY.md)..."; \
	  ls ~/.claude/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher}.md; \
	else \
	  echo "VERIFY.md not found."; \
	fi
