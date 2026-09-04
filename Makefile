# Makefile for setting up dotfiles and misc workstation settings

UNAME := $(shell uname)
XDG_CONFIG_HOME ?= $(HOME)/.config

# Active packages stowed on Linux. Desktop WM configs (sway, i3, alacritty, wofi)
# live under legacy/ and are not deployed.
STOW_PACKAGES = bash git tmux nvim bin systemd gnupg ghostty hyprland quickshell

.PHONY: clean vim shell stow unstow linux check links restow-desktop

all: stow vim shell
clean: unstow

vim:
	mkdir -p $(HOME)/.backups
	mkdir -p $(HOME)/.vim/bundle
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Run this only when on MacOS
ifeq ($(UNAME), Darwin)
brew:
	brew install shellcheck
endif

# TODO: use git submodules here
shell:
	mkdir -p $(HOME)/.third_party
	git clone https://github.com/olivierverdier/zsh-git-prompt.git ${HOME}/.third_party/zsh-git-prompt
	git clone https://github.com/jonmosco/kube-ps1.git ${HOME}/.third_party/kube-ps1

stow: links restow-desktop
	stow --verbose --target=$$HOME --restow $(STOW_PACKAGES)

unstow:
	stow --verbose --target=$$HOME --delete $(STOW_PACKAGES)

linux: stow

check: links
	stow --verbose --simulate --target=$$HOME --restow $(STOW_PACKAGES)

# Remove manual absolute symlinks that block stow, then restow desktop configs
restow-desktop:
	rm -f $(HOME)/.config/hypr/hypridle.conf $(HOME)/.config/hypr/hyprlock.conf $(HOME)/.config/hypr/hyprpaper.conf
	rm -f $(HOME)/.config/quickshell
	stow --verbose --target=$$HOME --restow hyprland quickshell

links:
	ln -sf $(CURDIR)/dircolors $(HOME)/.dircolors
	ln -sf $(CURDIR)/.path $(HOME)/.path
	ln -sf $(CURDIR)/exports $(HOME)/.exports
	ln -sf $(CURDIR)/aliases $(HOME)/.aliases
