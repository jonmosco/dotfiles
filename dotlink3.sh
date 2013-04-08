#!/bin/sh
# $Id: dotlink3.sh 48 2013-01-08 20:14:17Z jmosco $
#
# Create symlinks to dotfiles in .dotfiles repository
# Create .backups directory for Vim backups
#
# - check if file already exists, exit if so
# - create sym link for each file 
# - ask if email will be read on this box

DOTFILES="bashrc
bash_profile
inputrc
git-prompt.sh
git-completion.bash
screenrc
vimrc
Xresources"
MUTTDIR=~/.mutt

for dotfiles in $DOTFILES
do
        if [ -L ~/.$dotfiles ]; then
                echo "Sym link for $dotfiles already exists."
        else
                ln -s ~/.dotfiles/$dotfiles ~/.$dotfiles
                echo "$dotfiles symlink created."
        fi
done

# Vim backup directory
if [ -d ~/.backups ]; then
        echo "backups directory already exists."
else
        mkdir ~/.backups
        echo "Vim backup directory created."
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
