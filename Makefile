# Makefile for setting up dotfiles and misc
# workstation settings

DOTFILES = zshrc vimrc gitconfig gitignore_global \
	bashrc bash_profile functions dockerfunctions

UNAME := $(shell uname)

.PHONY: clean links vim

all: links vim

links:
	for file in $(DOTFILES); do \
		ln -sf $(HOME)/.dotfiles/$$file $(HOME)/$(addprefix .,$$file); \
	done

vim:
	mkdir -p $(HOME)/.backups
	mkdir -p $(HOME)/.vim/bundle
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Run this only when on MacOS
ifeq ($(UNAME), Darwin)
brew:
	brew install shellcheck
endif

shell:
	git clone https://github.com/olivierverdier/zsh-git-prompt.git ${HOME}/.zsh/zsh-git-prompt
