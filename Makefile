# forge-council Makefile

AGENTS   = SoftwareDeveloper DatabaseEngineer DevOpsEngineer DocumentationWriter QaTester SecurityArchitect SystemArchitect UxDesigner ProductManager DataAnalyst TheOpponent WebResearcher ForensicAgent
SKILLS   = DebateCouncil Demo DeveloperCouncil ProductCouncil KnowledgeCouncil
AGENT_SRC = agents
SKILL_SRC = skills
LIB_DIR  = $(or $(FORGE_LIB),lib)

# Fallbacks when common.mk is not yet available (uninitialized submodule)
INSTALL_AGENTS  ?= $(LIB_DIR)/bin/install-agents
INSTALL_SKILLS  ?= $(LIB_DIR)/bin/install-skills
VALIDATE_MODULE ?= $(LIB_DIR)/bin/validate-module

.PHONY: help install install-teams-config clean verify test lint check init

help:
	@echo "forge-council management commands:"
	@echo "  make install                Install agents + skills for all providers (SCOPE=workspace|user|all, default: workspace)"
	@echo "  make install-agents         Install specialist agents"
	@echo "  make install-skills         Install skills for Claude, Gemini, Codex, and OpenCode"
	@echo "  make verify                 Verify the full installation (agents + skills)"
	@echo "  make clean                  Remove previously installed agents"
	@echo "  make test                   Run module validation"
	@echo "  make lint                   Shellcheck all scripts"
	@echo "  make check                  Verify module structure"

init:
	@if [ ! -f $(LIB_DIR)/Cargo.toml ]; then \
	  echo "Initializing forge-lib submodule..."; \
	  git submodule update --init $(LIB_DIR); \
	fi

ifneq ($(wildcard $(LIB_DIR)/mk/common.mk),)
  include $(LIB_DIR)/mk/common.mk
  include $(LIB_DIR)/mk/skills/install.mk
  include $(LIB_DIR)/mk/skills/verify.mk
  include $(LIB_DIR)/mk/agents/install.mk
  include $(LIB_DIR)/mk/agents/verify.mk
endif

install: install-agents install-skills install-teams-config
	@echo "Installation complete. Restart your session or reload agents/skills."

# Module-specific: inject @AgentTeams.md into council skills
install-teams-config: install-skills-claude
	@teams=$$(awk '/^teams:/ { sub("^teams: *",""); gsub(/[[:space:]]+/, ""); print; exit }' \
	  $$(if [ -f config.yaml ]; then echo config.yaml; else echo defaults.yaml; fi)); \
	teams=$${teams:-disabled}; \
	if [ "$$teams" = "enabled" ]; then \
	  if [ "$(SCOPE)" = "all" ]; then \
	    dsts="$(CURDIR)/.claude/skills $(HOME)/.claude/skills"; \
	  elif [ "$(SCOPE)" = "workspace" ]; then \
	    dsts="$(CURDIR)/.claude/skills"; \
	  elif [ "$(SCOPE)" = "user" ]; then \
	    dsts="$(HOME)/.claude/skills"; \
	  else \
	    echo "Error: Invalid SCOPE '$(SCOPE)'. Use workspace, user, or all."; \
	    exit 1; \
	  fi; \
	  for dst in $$dsts; do \
	    for skill in DebateCouncil DeveloperCouncil ProductCouncil KnowledgeCouncil; do \
	      sf="$$dst/$$skill/SKILL.md"; \
	      if [ -f "$$sf" ]; then \
	        if ! grep -q '@AgentTeams.md' "$$sf"; then \
	          awk 'BEGIN{n=0} /^---$$/{n++; print; if(n==2){print ""; print "@AgentTeams.md"} next} {print}' "$$sf" > "$$sf.tmp" && \
	          command mv "$$sf.tmp" "$$sf"; \
	        fi; \
	        echo "  $$skill: @AgentTeams.md"; \
	      fi; \
	    done; \
	  done; \
	else \
	  echo "  teams=disabled (no @AgentTeams.md injection)"; \
	fi

clean: clean-agents

verify: verify-skills verify-agents

test: $(VALIDATE_MODULE)
	@$(VALIDATE_MODULE) $(CURDIR)

lint:
	@if find . -name '*.sh' -not -path '*/target/*' -not -path '*/lib/*' | grep -q .; then \
	  if ! command -v shellcheck >/dev/null 2>&1; then \
	    echo "shellcheck not installed (install with: brew install shellcheck)"; \
	    exit 1; \
	  fi; \
	  find . -name '*.sh' -not -path '*/target/*' -not -path '*/lib/*' -print0 | xargs -0 shellcheck -S warning; \
	fi

check:
	@test -f module.yaml && echo "  ok module.yaml" || echo "  MISSING module.yaml"
	@test -x "$(INSTALL_AGENTS)" && echo "  ok install-agents" || echo "  MISSING install-agents (run: make -C $(LIB_DIR) build)"
	@test -x "$(INSTALL_SKILLS)" && echo "  ok install-skills" || echo "  MISSING install-skills (run: make -C $(LIB_DIR) build)"
	@test -x "$(VALIDATE_MODULE)" && echo "  ok validate-module" || echo "  MISSING validate-module (run: make -C $(LIB_DIR) build)"
