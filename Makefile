# Makefile for setting up dotfiles and misc
# workstation settings

links:
	ln -vsf ${PWD}/zshrc ${HOME}/.zshrc
	ln -vsf ${PWD}/vimrc ${HOME}/.vimrc
	ln -vsf ${PWD}/zsh ${HOME}/zsh
	ln -vsf ${PWD}/gitignore_global ${HOME}/.gitignore_global
	ln -vsf ${PWD}/gitconfig ${HOME}/.gitconfig

vim:
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

brew:
	brew install shellcheck

shell:
	git clone https://github.com/olivierverdier/zsh-git-prompt.git ${HOME}/.zsh/zsh-git-prompt
