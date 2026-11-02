CANDIDATES := $(wildcard .??*)
EXCLUSIONS := .DS_Store .git .gitmodules .config .claude .claude-private .claude-work
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))
CONFIGDIRS := $(wildcard ./.config/*)

.PHONY: all list deploy clean linkdropbox mise-install

all:

list: ## Show dot files in this repo
	@$(foreach val, $(DOTFILES), /bin/ls -dF $(val);)
	@$(foreach val, $(CONFIGDIRS), /bin/ls -dF $(val);)

deploy:
	@echo '==> Start to deploy dotfiles to home directory.'
	@echo ''
	@$(foreach val, $(DOTFILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@$(foreach val, $(CONFIGDIRS), ln -sfnv $(abspath $(val)) $(HOME)/.config/$(notdir $(val));)
	ln -sfnv $(abspath scripts) $(HOME)/scripts
	@mkdir -p $(HOME)/.claude
	@$(foreach val, $(wildcard .claude/* .claude/.*), \
		$(if $(filter-out . .., $(notdir $(val))), \
			ln -sfnv $(abspath $(val)) $(HOME)/.claude/$(notdir $(val));))

clean: ## Remove symlinks created by deploy (only those pointing into this repo)
	@echo '==> Start to remove symlinks created by deploy.'
	@$(foreach val, $(DOTFILES), \
		if [ "$$(readlink $(HOME)/$(val))" = "$(abspath $(val))" ]; then rm -v $(HOME)/$(val); fi;)
	@$(foreach val, $(CONFIGDIRS), \
		if [ "$$(readlink $(HOME)/.config/$(notdir $(val)))" = "$(abspath $(val))" ]; then rm -v $(HOME)/.config/$(notdir $(val)); fi;)
	@if [ "$$(readlink $(HOME)/scripts)" = "$(abspath scripts)" ]; then rm -v $(HOME)/scripts; fi
	@$(foreach val, $(wildcard .claude/* .claude/.*), \
		$(if $(filter-out . .., $(notdir $(val))), \
			if [ "$$(readlink $(HOME)/.claude/$(notdir $(val)))" = "$(abspath $(val))" ]; then rm -v $(HOME)/.claude/$(notdir $(val)); fi;))

linkdropbox:
	ln -sfn ~/Library/CloudStorage/Dropbox/vaults ~/vaults
	mkdir -p ~/.config
	ln -sfn ~/Library/CloudStorage/Dropbox/vimmemo ~/.config/vimmemo
	mkdir -p ~/.config/liary
	ln -sfn ~/Library/CloudStorage/Dropbox/liary/_post ~/.config/liary/_post

mise-install:
	export MISE_GITHUB_TOKEN=$$(gh auth token) && mise install
