#!/bin/bash
#
# dotlink4.sh: The fourth version of my profile setup script.
# Updates: Complete rewrite to be more specific on the function
# of the system we are installing on
# 
# Provides usage statement
# Choose what portions of profile to set
# Set the PATH based on OS
#
# TODO:
# - if .bashrc and .bash_profile are NOT symbolic links, remove them 
#   and link to ours

# Our profile configuration
DOTFILES="bashrc
bash_profile
inputrc
git-prompt.sh
git-completion.bash
screenrc
vimrc"

# OS
OSTYPE=`uname`

_usage () {
	echo "usage: $0 -[bmXh]"
	echo "-b Base install"
	echo "-m Mutt configuration"
	echo "-X Xwindows configuration"
	echo "-h print this message"
	exit 1
}

# Determine the location of our programs
_ostype () {
	case $OSTYPE in
		Darwin) 
			PATH=/bin:/usr/local/bin:/opt/local/bin:/usr/bin:/usr/X11/bin
			GIT=`command -v git`
			WGET=`command -v wget`
			CURL=`command -v curl`
			# Test
			echo "Mac OSX"
			;;
		Linux)
			PATH=/bin:/usr/bin:/usr/local/bin:/usr/bin:/usr/X11/bin
			GIT=`command -v git`
			WGET=`command -v wget`
			CURL=`command -v curl`
			# Test
			echo "Linux"
			;;
	esac
}

# Base profile: vim and bash
_base () {
	# Set OS specific setting
	_ostype
	for dotfiles in $DOTFILES
	do
	        if [ -L ~/.$dotfiles ]; then
	                echo "Sym link for $dotfiles already exists."
	        else
	                ln -s ~/.dotfiles/$dotfiles ~/.$dotfiles
	                echo "$dotfiles symlink created."
	        fi
	done
	# Test
	echo "base profile"

	# Vim setup
	# backup directory
	if [ -d ~/.backups ]; then
	        echo "backups directory already exists."
	else
	        mkdir ~/.backups
	        echo "Vim backup directory created."
	fi
	# vim plugins
	if [ -d ~/.vim/bundle ]; then
		echo "bundle dir already exists."
	else
		mkdir -p ~/.vim/autoload ~/.vim/bundle
		cd ~/.vim/bundle
		echo "Vim autoload and bundle directory created.  Proceding to checkout plugins..."
		$GIT clone https://github.com/scrooloose/nerdtree.git
		$GIT clone git://github.com/godlygeek/tabular.git
		$GIT clone https://github.com/scrooloose/syntastic.git
		$GIT clone git://github.com/altercation/vim-colors-solarized.git
	if [ -n "$CURL" ]; then
		PATHOGEN="$CURL -Sso"
	elif [ -n "$WGET" ]; then
		PATHOGEN="$WGET -O"
	else
		echo "pathogen.vim will not be installed.  Please browse to 
			https://github.com/tpope/vim-pathogen and follow the installation 
			instructions."
	fi
	       	$PATHOGEN ~/.vim/autoload/pathogen.vim \
	       		https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
	fi
}

# Mutt settings
_mutt () {
	if [ -d ~/.mutt ]; then
	        echo "mutt directory already exists."
	else
	        mkdir ~/.mutt
	        echo "mutt directory created."
	fi
	if [ -L ~/.muttrc ]; then
		echo "Sym link for muttrc already exists."
	else
		ln -s ~/.dotfiles/muttrc ~/.muttrc
		echo "muttrc symlink created"
	fi
	# Test
	echo "Mutt"
}

# XWindows Settings
_xwindows () {
	_ostype
	if [ -L ~/.Xresources ]; then
		echo "Sym link for Xresources already exists."
	else
		ln -s ~/.dotfiles/Xresources ~/.Xresources
		echo "Xresources symlink created....Merging Xresources"
		xrdb -merge ~/.Xresourses
	fi
}

if [ $# -ne 1 ]; then
	_usage
fi

# What version of our profile to install
while getopts bmXh opt; do
	case $opt in
		b)
			_base;;
		m) 
			_base
			_mutt;;
		X)
			_base
			_xwindows;;
		h)
			_usage 
	esac
done