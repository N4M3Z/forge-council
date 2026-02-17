# forge-council Makefile

.PHONY: help install install-agents install-skills clean verify

# Variables
AGENT_SRC = agents
SKILL_SRC = skills
LIB_DIR = lib

help:
	@echo "forge-council management commands:"
	@echo "  make install         Install both agents and skills"
	@echo "  make install-agents  Install specialist agents to ~/.claude/agents/"
	@echo "  make install-skills  Install skills to ~/.gemini/skills/"
	@echo "  make clean           Remove previously installed agents"
	@echo "  make verify          Verify the installation"

install: install-agents install-skills
	@echo "Installation complete. Restart your session or reload agents/skills."

install-agents:
	@bash $(LIB_DIR)/install-agents.sh $(AGENT_SRC)

install-skills:
	@bash $(LIB_DIR)/install-skills.sh $(SKILL_SRC)

clean:
	@bash $(LIB_DIR)/install-agents.sh $(AGENT_SRC) --clean

verify:
	@if [ -f "VERIFY.md" ]; then 
		echo "Running verification checks (as defined in VERIFY.md)..."; 
		ls ~/.claude/agents/{Developer,Database,DevOps,DocumentationWriter,Tester,SecurityArchitect,Architect,Designer,ProductManager,Analyst,Opponent,Researcher}.md; 
		gemini skills list | grep -E "Council|Demo|DeveloperCouncil|ProductCouncil"; 
	else 
		echo "VERIFY.md not found."; 
	fi
