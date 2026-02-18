# forge-council Makefile

.PHONY: help sync install install-agents install-skills install-skills-claude install-skills-gemini install-skills-codex clean verify verify-skills verify-skills-claude verify-skills-gemini verify-skills-codex test lint check

# Variables
AGENT_SRC = agents
SKILL_SRC = skills
LIB_DIR = lib
SCOPE ?= workspace
CLAUDE_SKILLS_DST ?= $(if $(filter workspace,$(SCOPE)),$(CURDIR)/.claude/skills,$(HOME)/.claude/skills)
GEMINI_SKILLS_DST ?= $(HOME)/.gemini/skills
CODEX_SKILLS_DST ?= $(if $(filter workspace,$(SCOPE)),$(CURDIR)/.codex/skills,$(HOME)/.codex/skills)

help:
	@echo "forge-council management commands:"
	@echo "  make install               Install both agents and skills (SCOPE=workspace|user|all, default: workspace)"
	@echo "  make sync                  Sync council rosters from defaults.yaml to skills/"
	@echo "  make install-agents        Install specialist agents (workspace: ./.claude + ./.gemini + ./.codex, user: ~/.claude + ~/.gemini + ~/.codex)"
	@echo "  make install-skills        Install skills for Claude, Gemini, and Codex"
	@echo "  make install-skills-claude Install skills via SCOPE (workspace/user/all)"
	@echo "  make install-skills-gemini Install skills via gemini CLI (uses SCOPE)"
	@echo "  make install-skills-codex  Install native council skills via SCOPE (workspace/user/all)"
	@echo "  make verify-skills         Verify skills for Claude, Gemini, and Codex"
	@echo "  make clean                 Remove previously installed agents"
	@echo "  make verify                Verify the installation"
	@echo "  make test                  Run tests"
	@echo "  make lint                  Shellcheck all scripts"
	@echo "  make check                 Verify module structure"

ensure-lib:
	@if [ ! -f "$(LIB_DIR)/install-agents.sh" ]; then \
		echo "Initializing submodules..."; \
		git submodule update --init --recursive; \
	fi

sync: ensure-lib
	@bash $(LIB_DIR)/sync-rosters.sh defaults.yaml

install: sync install-agents install-skills
	@echo "Installation complete. Restart your session or reload agents/skills."

install-agents: ensure-lib
	@bash $(LIB_DIR)/install-agents.sh $(AGENT_SRC) --scope "$(SCOPE)"

install-skills: install-skills-claude install-skills-gemini install-skills-codex

install-skills-claude: ensure-lib
	@if [ "$(SCOPE)" = "all" ]; then \
	  bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(CURDIR)/.claude/skills"; \
	  bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(HOME)/.claude/skills"; \
	elif [ "$(SCOPE)" = "workspace" ]; then \
	  bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(CURDIR)/.claude/skills"; \
	elif [ "$(SCOPE)" = "user" ]; then \
	  bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(HOME)/.claude/skills"; \
	else \
	  echo "Error: Invalid SCOPE '$(SCOPE)'. Use workspace, user, or all."; \
	  exit 1; \
	fi

install-skills-gemini: ensure-lib
	@bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider gemini --scope "$(SCOPE)"

install-skills-codex: ensure-lib
	@if [ "$(SCOPE)" = "all" ]; then \
	  bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(CURDIR)/.codex/skills"; \
	  bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(HOME)/.codex/skills"; \
	elif [ "$(SCOPE)" = "workspace" ]; then \
	  bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(CURDIR)/.codex/skills"; \
	elif [ "$(SCOPE)" = "user" ]; then \
	  bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(HOME)/.codex/skills"; \
	else \
	  echo "Error: Invalid SCOPE '$(SCOPE)'. Use workspace, user, or all."; \
	  exit 1; \
	fi

clean: ensure-lib
	@bash $(LIB_DIR)/install-agents.sh $(AGENT_SRC) --clean

verify-skills: verify-skills-claude verify-skills-gemini verify-skills-codex

verify-skills-claude:
	@missing=0; \
	if [ "$(SCOPE)" = "all" ]; then \
	  for dst in "$(CURDIR)/.claude/skills" "$(HOME)/.claude/skills"; do \
	    echo "Verifying Claude skills in $$dst..."; \
	    for s in Council Demo DeveloperCouncil ProductCouncil KnowledgeCouncil; do \
	      if test -f "$$dst/$$s/SKILL.md"; then \
	        echo "  ok $$s"; \
	      else \
	        echo "  missing $$s"; \
	        missing=1; \
	      fi; \
	    done; \
	  done; \
	else \
	  echo "Verifying Claude skills in $(CLAUDE_SKILLS_DST)..."; \
	  for s in Council Demo DeveloperCouncil ProductCouncil KnowledgeCouncil; do \
	    if test -f "$(CLAUDE_SKILLS_DST)/$$s/SKILL.md"; then \
	      echo "  ok $$s"; \
	    else \
	      echo "  missing $$s"; \
	      missing=1; \
	    fi; \
	  done; \
	fi; \
	test $$missing -eq 0

verify-skills-gemini:
	@if command -v gemini >/dev/null 2>&1; then \
	  echo "Verifying Gemini skills via CLI..."; \
	  out_file=$$(mktemp); \
	  if gemini skills list > "$$out_file" 2>&1; then \
	    grep -E "Council|Demo|DeveloperCouncil|ProductCouncil|KnowledgeCouncil" "$$out_file"; \
	  else \
	    if [ "$${GEMINI_VERIFY_STRICT:-0}" = "1" ]; then \
	      cat "$$out_file"; \
	      rm -f "$$out_file"; \
	      exit 1; \
	    fi; \
	    echo "  skip gemini skill verification (non-interactive or unauthenticated)"; \
	  fi; \
	  rm -f "$$out_file"; \
	else \
	  echo "  skip gemini skill verification (gemini CLI not installed)"; \
	fi

verify-skills-codex:
	@missing=0; \
	if [ "$(SCOPE)" = "all" ]; then \
	  for dst in "$(CURDIR)/.codex/skills" "$(HOME)/.codex/skills"; do \
	    echo "Verifying Codex skills in $$dst..."; \
	    for s in Council Demo DeveloperCouncil ProductCouncil KnowledgeCouncil; do \
	      if test -f "$$dst/$$s/SKILL.md"; then \
	        echo "  ok $$s"; \
	      else \
	        echo "  missing $$s"; \
	        missing=1; \
	      fi; \
	    done; \
	  done; \
	else \
	  echo "Verifying Codex skills in $(CODEX_SKILLS_DST)..."; \
	  for s in Council Demo DeveloperCouncil ProductCouncil KnowledgeCouncil; do \
	    if test -f "$(CODEX_SKILLS_DST)/$$s/SKILL.md"; then \
	      echo "  ok $$s"; \
	    else \
	      echo "  missing $$s"; \
	      missing=1; \
	    fi; \
	  done; \
	fi; \
	test $$missing -eq 0


test:
	@echo "No tests defined"

lint:
	@if find . -name '*.sh' -not -path '*/target/*' | grep -q .; then \
	  if ! command -v shellcheck >/dev/null 2>&1; then \
	    echo "shellcheck not installed (install with: brew install shellcheck)"; \
	    exit 1; \
	  fi; \
	  find . -name '*.sh' -not -path '*/target/*' -print0 | xargs -0 shellcheck -S warning; \
	fi

check:
	@test -f module.yaml && echo "  ok module.yaml" || echo "  MISSING module.yaml"

verify: verify-skills
	@if [ -f "VERIFY.md" ]; then \
	  echo "Running verification checks (as defined in VERIFY.md)..."; \
	  if [ "$(SCOPE)" = "workspace" ]; then \
	    echo "Checking workspace Gemini agents..."; \
	    ls .gemini/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md; \
	    echo "Checking workspace Codex agents..."; \
	    ls .codex/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md; \
	  elif [ "$(SCOPE)" = "user" ]; then \
	    echo "Checking user Claude agents..."; \
	    ls $(HOME)/.claude/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md; \
	    echo "Checking user Gemini agents..."; \
	    ls $(HOME)/.gemini/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md; \
	    echo "Checking user Codex agents..."; \
	    ls $(HOME)/.codex/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md; \
	  elif [ "$(SCOPE)" = "all" ]; then \
	    echo "Checking workspace Gemini agents..."; \
	    ls .gemini/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md; \
	    echo "Checking workspace Codex agents..."; \
	    ls .codex/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md; \
	    echo "Checking user Claude agents..."; \
	    ls $(HOME)/.claude/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md; \
	    echo "Checking user Gemini agents..."; \
	    ls $(HOME)/.gemini/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md; \
	    echo "Checking user Codex agents..."; \
	    ls $(HOME)/.codex/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher,ForensicAgent}.md; \
	  else \
	    echo "Invalid SCOPE: $(SCOPE)"; \
	    exit 1; \
	  fi; \
	else \
	  echo "VERIFY.md not found."; \
	fi
