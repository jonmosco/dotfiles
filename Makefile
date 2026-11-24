# Makefile for setting up dotfiles and misc workstation settings

UNAME := $(shell uname)
XDG_CONFIG_HOME ?= $(HOME)/.config

# Active packages stowed on Linux. Desktop WM configs (sway, i3, alacritty, wofi)
# live under legacy/ and are not deployed.
STOW_PACKAGES = bash git tmux nvim bin systemd gnupg ghostty chrome chatgpt hyprland quickshell autostart uwsm

# Only stow what this checkout actually has. The agents package is gitignored
# (local AI instruction files) and others may be uncommitted, and stow aborts
# with "does not contain package" on a missing directory, which would break
# `make stow` on a fresh clone.
PRESENT_PACKAGES = $(foreach p,$(STOW_PACKAGES),$(if $(wildcard $(p)),$(p),))
ABSENT_PACKAGES = $(filter-out $(PRESENT_PACKAGES),$(STOW_PACKAGES))

.PHONY: clean vim shell agents stow unstow linux check links restow-desktop

all: stow vim shell agents
clean: unstow

vim:
	mkdir -p $(HOME)/.backups
	mkdir -p $(HOME)/.vim/bundle
	test -d $(HOME)/.vim/bundle/Vundle.vim/.git || git clone --depth=1 https://github.com/VundleVim/Vundle.vim.git $(HOME)/.vim/bundle/Vundle.vim

# Run this only when on MacOS
ifeq ($(UNAME), Darwin)
brew:
	brew install shellcheck
endif

# TODO: use git submodules here
shell:
	mkdir -p $(HOME)/.third_party
	test -d ${HOME}/.third_party/zsh-git-prompt/.git || git clone --depth=1 https://github.com/olivierverdier/zsh-git-prompt.git ${HOME}/.third_party/zsh-git-prompt
	test -d ${HOME}/.third_party/kube-ps1/.git || git clone --depth=1 https://github.com/jonmosco/kube-ps1.git ${HOME}/.third_party/kube-ps1
	test -d ${HOME}/.bash-git-prompt/.git || git clone --depth=1 https://github.com/magicmonty/bash-git-prompt.git ${HOME}/.bash-git-prompt

agents:
	mkdir -p $(HOME)/.gemini/config/plugins $(HOME)/.agents/skills
	test -d $(HOME)/.gemini/config/plugins/egm/.git || git clone --depth=1 https://github.com/google/elephant-goldfish-model.git $(HOME)/.gemini/config/plugins/egm

stow: links restow-desktop
	@test -z "$(ABSENT_PACKAGES)" || echo "absent from this checkout - skipping: $(ABSENT_PACKAGES)"
	stow --verbose --target=$$HOME --restow $(PRESENT_PACKAGES)
	@if [ -d agents ]; then stow --no-folding --verbose --target=$$HOME --restow agents; \
	else echo "agents: not in this checkout, skipping"; fi

unstow:
	stow --verbose --target=$$HOME --delete $(PRESENT_PACKAGES)
	@if [ -d agents ]; then stow --no-folding --verbose --target=$$HOME --delete agents; \
	else echo "agents: not in this checkout, skipping"; fi

linux: stow

check: links
	@test -z "$(ABSENT_PACKAGES)" || echo "absent from this checkout - skipping: $(ABSENT_PACKAGES)"
	stow --verbose --simulate --target=$$HOME --restow $(PRESENT_PACKAGES)
	@if [ -d agents ]; then stow --no-folding --verbose --simulate --target=$$HOME --restow agents; \
	else echo "agents: not in this checkout, skipping"; fi

# Remove manual absolute symlinks that block stow, then restow desktop configs
restow-desktop:
	rm -f $(HOME)/.config/hypr/hypridle.conf $(HOME)/.config/hypr/hyprlock.conf $(HOME)/.config/hypr/hyprpaper.conf
	rm -f $(HOME)/.config/quickshell
	stow --verbose --target=$$HOME --restow hyprland quickshell

links:
	mkdir -p $(HOME)/.gemini/config $(HOME)/.agents/skills
	ln -sf $(CURDIR)/dircolors $(HOME)/.dircolors
	ln -sf $(CURDIR)/.path $(HOME)/.path
	ln -sf $(CURDIR)/exports $(HOME)/.exports
	ln -sf $(CURDIR)/aliases $(HOME)/.aliases
	ln -sf $(CURDIR)/bash/bash_git_prompt $(HOME)/.bash_git_prompt
