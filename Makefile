# forge-council Makefile

.PHONY: help install install-agents install-skills install-skills-claude install-skills-gemini install-skills-codex install-skills-opencode install-codex-agent-config install-teams-config clean verify verify-skills verify-skills-claude verify-skills-gemini verify-skills-codex verify-skills-opencode verify-agents verify-codex-agent-config test lint check lib-init

# Variables
AGENTS = SoftwareDeveloper DatabaseEngineer DevOpsEngineer DocumentationWriter QaTester SecurityArchitect SystemArchitect UxDesigner ProductManager DataAnalyst TheOpponent WebResearcher ForensicAgent
SKILLS = DebateCouncil Demo DeveloperCouncil ProductCouncil KnowledgeCouncil
AGENT_SRC = agents
SKILL_SRC = skills
LIB_DIR = $(or $(FORGE_LIB),lib)
SCOPE ?= workspace
CLAUDE_SKILLS_DST ?= $(if $(filter workspace,$(SCOPE)),$(CURDIR)/.claude/skills,$(HOME)/.claude/skills)
CODEX_SKILLS_DST ?= $(if $(filter workspace,$(SCOPE)),$(CURDIR)/.codex/skills,$(HOME)/.codex/skills)
OPENCODE_SKILLS_DST ?= $(if $(filter workspace,$(SCOPE)),$(CURDIR)/.opencode/skills,$(HOME)/.opencode/skills)

# Rust binaries from forge-lib submodule
INSTALL_AGENTS := $(LIB_DIR)/bin/install-agents
INSTALL_SKILLS := $(LIB_DIR)/bin/install-skills
VALIDATE_MODULE := $(LIB_DIR)/bin/validate-module
INSTALL_CODEX_AGENT_CONFIG := $(LIB_DIR)/bin/install-codex-agent-config

help:
	@echo "forge-council management commands:"
	@echo "  make install                Install agents + skills for all providers (SCOPE=workspace|user|all, default: workspace)"
	@echo "  make install-agents         Install specialist agents"
	@echo "  make install-codex-agent-config Codex compatibility post-processing (generates role TOML/config block)"
	@echo "  make install-skills         Install skills for Claude, Gemini, Codex, and OpenCode"
	@echo "  make install-skills-claude  Install skills via SCOPE (workspace/user/all)"
	@echo "  make install-skills-gemini  Install skills via gemini CLI (uses SCOPE)"
	@echo "  make install-skills-codex   Install skills via SCOPE (workspace/user/all)"
	@echo "  make install-skills-opencode Install skills with kebab-case names via SCOPE"
	@echo "  make verify                 Verify the full installation (agents + skills)"
	@echo "  make verify-skills          Verify skills for all providers"
	@echo "  make verify-agents          Verify agents for Claude, Gemini, and Codex"
	@echo "  make clean                  Remove previously installed agents"
	@echo "  make test                   Run module validation"
	@echo "  make lint                   Shellcheck all scripts"
	@echo "  make check                  Verify module structure"

# Ensure forge-lib submodule is initialized
lib-init:
	@if [ ! -f $(LIB_DIR)/Cargo.toml ]; then \
	  echo "Initializing forge-lib submodule..."; \
	  git submodule update --init $(LIB_DIR); \
	fi

# Ensure forge-lib binaries are built before install targets
$(INSTALL_AGENTS) $(INSTALL_SKILLS) $(VALIDATE_MODULE) $(INSTALL_CODEX_AGENT_CONFIG): lib-init
	@$(MAKE) -C $(LIB_DIR) build

install: install-agents install-codex-agent-config install-skills install-teams-config
	@echo "Installation complete. Restart your session or reload agents/skills."

install-agents: $(INSTALL_AGENTS)
	@$(INSTALL_AGENTS) $(AGENT_SRC) --scope "$(SCOPE)"

install-codex-agent-config: $(INSTALL_CODEX_AGENT_CONFIG)
	@ \
	if [ "$(SCOPE)" = "all" ]; then \
	  codex_roots="$(CURDIR)/.codex $(HOME)/.codex"; \
	elif [ "$(SCOPE)" = "workspace" ]; then \
	  codex_roots="$(CURDIR)/.codex"; \
	elif [ "$(SCOPE)" = "user" ]; then \
	  codex_roots="$(HOME)/.codex"; \
	else \
	  echo "Error: Invalid SCOPE '$(SCOPE)'. Use workspace, user, or all."; \
	  exit 1; \
	fi; \
	for codex_root in $$codex_roots; do \
	  $(INSTALL_CODEX_AGENT_CONFIG) "$$codex_root" --module-root "$(CURDIR)"; \
	done

install-skills: install-skills-claude install-skills-gemini install-skills-codex install-skills-opencode

install-skills-claude: $(INSTALL_SKILLS)
	@if [ "$(SCOPE)" = "all" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(CURDIR)/.claude/skills"; \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(HOME)/.claude/skills"; \
	elif [ "$(SCOPE)" = "workspace" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(CURDIR)/.claude/skills"; \
	elif [ "$(SCOPE)" = "user" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider claude --scope "$(SCOPE)" --dst "$(HOME)/.claude/skills"; \
	else \
	  echo "Error: Invalid SCOPE '$(SCOPE)'. Use workspace, user, or all."; \
	  exit 1; \
	fi

install-skills-gemini: $(INSTALL_SKILLS)
	@if command -v gemini >/dev/null 2>&1; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider gemini --scope "$(SCOPE)"; \
	else \
	  echo "  skip gemini skill install (gemini CLI not installed)"; \
	fi

install-skills-codex: $(INSTALL_SKILLS)
	@if [ "$(SCOPE)" = "all" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(CURDIR)/.codex/skills"; \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(HOME)/.codex/skills"; \
	elif [ "$(SCOPE)" = "workspace" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(CURDIR)/.codex/skills"; \
	elif [ "$(SCOPE)" = "user" ]; then \
	  $(INSTALL_SKILLS) $(SKILL_SRC) --provider codex --scope "$(SCOPE)" --dst "$(HOME)/.codex/skills"; \
	else \
	  echo "Error: Invalid SCOPE '$(SCOPE)'. Use workspace, user, or all."; \
	  exit 1; \
	fi

install-skills-opencode:
	@if [ "$(SCOPE)" = "all" ]; then \
	  dsts="$(CURDIR)/.opencode/skills $(HOME)/.opencode/skills"; \
	elif [ "$(SCOPE)" = "workspace" ]; then \
	  dsts="$(CURDIR)/.opencode/skills"; \
	elif [ "$(SCOPE)" = "user" ]; then \
	  dsts="$(HOME)/.opencode/skills"; \
	else \
	  echo "Error: Invalid SCOPE '$(SCOPE)'. Use workspace, user, or all."; \
	  exit 1; \
	fi; \
	for dst in $$dsts; do \
	  mkdir -p "$$dst"; \
	  for skill_dir in $(SKILL_SRC)/*/; do \
	    skill=$$(basename "$$skill_dir"); \
	    kebab=$$(echo "$$skill" | sed 's/\([A-Z]\)/-\1/g' | sed 's/^-//' | tr '[:upper:]' '[:lower:]'); \
	    mkdir -p "$$dst/$$kebab"; \
	    command cp "$$skill_dir"SKILL.md "$$dst/$$kebab/SKILL.md" 2>/dev/null || true; \
	    command cp "$$skill_dir"SKILL.yaml "$$dst/$$kebab/SKILL.yaml" 2>/dev/null || true; \
	  done; \
	  echo "  installed $$(ls -d "$$dst"/*/ 2>/dev/null | wc -l | tr -d ' ') skills to $$dst"; \
	done

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

clean: $(INSTALL_AGENTS)
	@$(INSTALL_AGENTS) $(AGENT_SRC) --clean

verify: verify-skills verify-agents verify-codex-agent-config

verify-skills: verify-skills-claude verify-skills-gemini verify-skills-codex verify-skills-opencode

verify-skills-claude:
	@missing=0; \
	if [ "$(SCOPE)" = "all" ]; then \
	  for dst in "$(CURDIR)/.claude/skills" "$(HOME)/.claude/skills"; do \
	    echo "Verifying Claude skills in $$dst..."; \
	    for s in $(SKILLS); do \
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
	  for s in $(SKILLS); do \
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
	    grep -E "Council|Demo|DeveloperCouncil|ProductCouncil|KnowledgeCouncil" "$$out_file" || true; \
	  else \
	    if [ "$${GEMINI_VERIFY_STRICT:-0}" = "1" ]; then \
	      cat "$$out_file"; \
	      command rm -f "$$out_file"; \
	      exit 1; \
	    fi; \
	    echo "  skip gemini skill verification (non-interactive or unauthenticated)"; \
	  fi; \
	  command rm -f "$$out_file"; \
	else \
	  echo "  skip gemini skill verification (gemini CLI not installed)"; \
	fi

verify-skills-codex:
	@missing=0; \
	if [ "$(SCOPE)" = "all" ]; then \
	  for dst in "$(CURDIR)/.codex/skills" "$(HOME)/.codex/skills"; do \
	    echo "Verifying Codex skills in $$dst..."; \
	    for s in $(SKILLS); do \
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
	  for s in $(SKILLS); do \
	    if test -f "$(CODEX_SKILLS_DST)/$$s/SKILL.md"; then \
	      echo "  ok $$s"; \
	    else \
	      echo "  missing $$s"; \
	      missing=1; \
	    fi; \
	  done; \
	fi; \
	test $$missing -eq 0

verify-skills-opencode:
	@missing=0; \
	echo "Verifying OpenCode skills in $(OPENCODE_SKILLS_DST)..."; \
	for s in debate-council demo developer-council product-council knowledge-council; do \
	  if test -f "$(OPENCODE_SKILLS_DST)/$$s/SKILL.md"; then \
	    echo "  ok $$s"; \
	  else \
	    echo "  missing $$s"; \
	    missing=1; \
	  fi; \
	done; \
	test $$missing -eq 0

verify-agents:
	@missing=0; \
	for provider in claude gemini codex; do \
	  if [ "$(SCOPE)" = "all" ]; then \
	    dirs="$(CURDIR)/.$$provider/agents $(HOME)/.$$provider/agents"; \
	  elif [ "$(SCOPE)" = "workspace" ]; then \
	    dirs="$(CURDIR)/.$$provider/agents"; \
	  elif [ "$(SCOPE)" = "user" ]; then \
	    dirs="$(HOME)/.$$provider/agents"; \
	  else \
	    echo "Invalid SCOPE: $(SCOPE)"; exit 1; \
	  fi; \
	  for dst in $$dirs; do \
	    echo "Verifying $$provider agents in $$dst..."; \
	    for a in $(AGENTS); do \
	      if test -f "$$dst/$$a.md"; then \
	        echo "  ok $$a"; \
	      else \
	        echo "  missing $$a"; \
	        missing=1; \
	      fi; \
	    done; \
	  done; \
	done; \
	if [ $$missing -ne 0 ]; then \
	  echo "Run 'make install' to deploy agents."; \
	fi; \
	test $$missing -eq 0

verify-codex-agent-config:
	@missing=0; \
	if [ "$(SCOPE)" = "all" ]; then \
	  dirs="$(CURDIR)/.codex/agents $(HOME)/.codex/agents"; \
	elif [ "$(SCOPE)" = "workspace" ]; then \
	  dirs="$(CURDIR)/.codex/agents"; \
	elif [ "$(SCOPE)" = "user" ]; then \
	  dirs="$(HOME)/.codex/agents"; \
	else \
	  echo "Invalid SCOPE: $(SCOPE)"; exit 1; \
	fi; \
	for dir in $$dirs; do \
	  echo "Verifying Codex role config in $$dir..."; \
	  cfg="$$(dirname "$$dir")/config.toml"; \
	  if [ -f "$$cfg" ] && grep -q "BEGIN forge-council agents" "$$cfg"; then \
	    echo "  ok codex config marker"; \
	  else \
	    echo "  missing codex config marker in $$cfg"; \
	    missing=1; \
	  fi; \
	  for a in $(AGENTS); do \
	    if [ -f "$$dir/$$a.toml" ] && grep -q "prompt_file = \"$$a.md\"" "$$dir/$$a.toml"; then \
	      echo "  ok $$a role config"; \
	    else \
	      echo "  missing $$a role config"; \
	      missing=1; \
	    fi; \
	  done; \
	done; \
	test $$missing -eq 0

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
	@test -x "$(INSTALL_CODEX_AGENT_CONFIG)" && echo "  ok install-codex-agent-config" || echo "  MISSING install-codex-agent-config (run: make -C $(LIB_DIR) build)"
