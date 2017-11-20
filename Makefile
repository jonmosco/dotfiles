# Makefile for setting up dotfiles and misc
# workstation settings

DOTFILES = zshrc vimrc gitconfig gitignore_global \
					 bashrc bash_profile

.PHONY: clean

links:
	for files in $(DOTFILES); do \
		ln -sf $(HOME)/.dotfiles/.$$file $(HOME)/.$$file; \
	done

	#ln -vsf ${PWD}/zshrc ${HOME}/.zshrc
	#ln -vsf ${PWD}/vimrc ${HOME}/.vimrc
	#ln -vsf ${PWD}/zsh ${HOME}/zsh
	#ln -vsf ${PWD}/gitignore_global ${HOME}/.gitignore_global
	#ln -vsf ${PWD}/gitconfig ${HOME}/.gitconfig

vim:
	mkdir -p $(HOME)/.vim/bundle
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# Run this only when on MacOS
#brew:
#	brew install shellcheck

shell:
	git clone https://github.com/olivierverdier/zsh-git-prompt.git ${HOME}/.zsh/zsh-git-prompt
