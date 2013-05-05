#!/bin/sh
# $Id: dotlink3.sh 48 2013-01-08 20:14:17Z jmosco $
#
# Create symlinks to dotfiles in .dotfiles repository
# Create .backups directory for Vim backups
#
# - check if file already exists, exit if so
# - create sym link for each file 
# - checkout vim plugins with git
# - ask if email will be read on this box
#
# TODO

DOTFILES="bashrc
bash_profile
inputrc
git-prompt.sh
git-completion.bash
screenrc
vimrc
Xresources"
MUTTDIR=~/.mutt

# See what version of git to use since distros like to ship
# ancient software :)
if [ -e /usr/local/bin/git ]; then
	GIT=/usr/local/bin/git
else
	GIT=`which git`
fi

for dotfiles in $DOTFILES
do
        if [ -L ~/.$dotfiles ]; then
                echo "Sym link for $dotfiles already exists."
        else
                ln -s ~/.dotfiles/$dotfiles ~/.$dotfiles
                echo "$dotfiles symlink created."
        fi
done

# Xrdb
if [ -L ~/.Xresources]; then
	echo "Merging Xresources"
	xrdb -merge ~/.Xresourses
fi

# Vim backup directory
if [ -d ~/.backups ]; then
        echo "backups directory already exists."
else
        mkdir ~/.backups
        echo "Vim backup directory created."
fi

# Checkout Vim plugins
# Pathogen, Solarized, Syntastix and Tabular
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
        curl -Sso ~/.vim/autoload/pathogen.vim \
        https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
fi

# Mutt anyone?
# TODO:
# Fix conditional to only search for dir if mutt is 
# going to be used [ DONE 12/22/12 ]

echo Mutt?
read MUTT

if [[ $MUTT = "yes" && -d $MUTTDIR ]]; then
        echo "Mutt configuration already in place."
        exit 0
elif [[ $MUTT = "yes" && ! -d $MUTTDIR ]]; then
        ln -s ~/.dotfiles/mutt ~/.mutt
        echo "mutt configuration in place and ready!"
fi
