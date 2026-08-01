# Makefile for setting up dotfiles and misc workstation settings

UNAME := $(shell uname)
XDG_CONFIG_HOME ?= $(HOME)/.config
LINUX_PACKAGES = bash git tmux nvim bin sway waybar systemd alacritty gnupg

.PHONY: clean vim shell stow unstow linux check links

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

# GNU Stow
stow:
	stow --verbose --target=$$HOME --restow */

unstow:
	stow --verbose --target=$$HOME --delete */

linux: links
	stow --verbose --target=$$HOME --restow $(LINUX_PACKAGES)

check:
	stow --verbose --simulate --target=$$HOME --restow $(LINUX_PACKAGES)

links:
	ln -sf $(CURDIR)/dircolors $(HOME)/.dircolors
	ln -sf $(CURDIR)/.path $(HOME)/.path
	ln -sf $(CURDIR)/exports $(HOME)/.exports
