CANDIDATES := $(wildcard .??*)
EXCLUSIONS := .DS_Store .git .gitmodules .config .claude .claude-private .claude-work
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))
CONFIGDIRS := $(wildcard ./.config/*)

.PHONY: all list deploy linkdropbox mise-install

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

linkdropbox:
	ln -sfn ~/Library/CloudStorage/Dropbox/vaults ~/vaults
	mkdir -p ~/.config
	ln -sfn ~/Library/CloudStorage/Dropbox/vimmemo ~/.config/vimmemo
	mkdir -p ~/.config/liary
	ln -sfn ~/Library/CloudStorage/Dropbox/liary/_post ~/.config/liary/_post

mise-install:
	export MISE_GITHUB_TOKEN=$$(gh auth token) && mise install
