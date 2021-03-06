#!/usr/bin/env bash
#
# dotlink4.sh: The fourth version of my profile setup script.
# Updates: Complete rewrite to be more specific on the function
# of the system we are installing on
#
# FEATURES:
# - Provides usage statement
# - Choose what portions of profile to set
# - Set the PATH based on OS
#
# TODO:
# - if .bashrc and .bash_profile are NOT symbolic links, remove them
#   and link to .dotfiles/ bash configuration [DONE 6/11/13]
# - Add argument (-U) that will cleanup already installed profile, updating
#   the plugins?
# - For skeleton files, only remote if files are not symbolic links since we
#   are creating them
# - Add Vim as an option since we are now using a plugin manager and no longer
#   need individual git repos
#
# Caveats:
# -On some default Linux installs, profiles are set up for new users
#  out of /etc/skel.  We don't want this.

# Profile configuration files
DOTFILES="bashrc
bash_profile
inputrc
gitconfig
git-prompt.sh
git-completion.bash
screenrc
tmux.conf
vimrc
zshrc"

# Possible skeleton files
SKEL="bashrc
bash_profile"

# OS
OSTYPE=$( uname )

# Usage
_usage () {
  echo "usage: $0 -[bsmXh]"
  echo "-b Base install"
  echo "-s <shell>"
  echo "-m Mutt configuration"
  echo "-X Xwindows configuration"
  echo "-h print this message"
  exit 1
}

if [ $# -eq 0 ]; then
  _usage
fi

# Determine the location of our programs
_ostype () {
  case $OSTYPE in
    Darwin)
    PATH=/bin:/usr/local/bin:/opt/local/bin:/usr/bin:/usr/X11/bin
    GIT=$(command -v git)
    WGET=$(command -v wget)
    CURL=$(command -v curl)
    ;;
    Linux)
    PATH=/bin:/usr/bin:/usr/local/bin:/usr/bin:/usr/X11/bin
    GIT=$(command -v git)
    WGET=$(command -v wget)
    CURL=$(command -v curl)
    ;;
  esac
}

# Base profile: vim and bash
_base () {
  # Set OS specific setting
  _ostype

  # remove /etc/skel files if they exist
  for skel in $SKEL
  do
    if [ ! -L "$HOME/.$skel" ]; then
      echo "Skeleton files exist..removing.."
      rm "$HOME/.$skel"
      echo "Zapped skeleton files"
    fi
  done

  for dotfiles in $DOTFILES
  do
    if [ -L "$HOME/.$dotfiles" ]; then
      echo "Sym link for $dotfiles already exists."
    else
      ln -s "$HOME/.dotfiles/$dotfiles $HOME/.$dotfiles"
      echo "$dotfiles symlink created."
    fi
  done

  # Vim setup

  # backup directory
  if [ -d "$HOME/.backups" ]; then
    echo "backups directory already exists."
  else
    mkdir "$HOME/.backups"
    echo "Vim backup directory created."
  fi

  # vim plugins
  if [ -d "$HOME/.vim/bundle" ]; then
    echo "bundle dir already exists."
  else
    mkdir -p "$HOME/.vim/autoload $HOME/.vim/bundle"
    cd "$HOME/.vim/bundle" || exit
    echo "Vim autoload and bundle directory created.  Proceding to checkout plugins..."
    $GIT clone https://github.com/scrooloose/nerdtree.git
    $GIT clone git://github.com/godlygeek/tabular.git
    $GIT clone https://github.com/scrooloose/syntastic.git
    $GIT clone git://github.com/altercation/vim-colors-solarized.git
    $GIT clone https://github.com/rodjek/vim-puppet.git puppet
    $GIT clone https://github.com/bling/vim-airline.git
    $GIT clone https://github.com/kien/ctrlp.vim.git

    if [ -n "$CURL" ]; then
      PATHOGEN="$CURL -Sso"
    elif [ -n "$WGET" ]; then
      PATHOGEN="$WGET -O"
    else
      echo "pathogen.vim will not be installed.  Please browse to
      https://github.com/tpope/vim-pathogen and follow the installation
      instructions."
    fi

    "$PATHOGEN $HOME/.vim/autoload/pathogen.vim \
    https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim"

  fi
}

_shell() {
  if [[ "$USER_SHELL" =~ zsh ]]; then
    ln -s "$HOME/.dotfiles/zshrc $HOME/.zshrc"
  fi
}

# Mutt settings
_mutt () {
  if [ -d "$HOME/.mutt" ]; then
    echo "mutt directory already exists."
  else
    mkdir "$HOME/.mutt"
    echo "mutt directory created."
  fi
  if [ -L "$HOME/.muttrc" ]; then
    echo "Sym link for muttrc already exists."
  else
    ln -s "$HOME/.dotfiles/muttrc $HOME/.muttrc"
    echo "muttrc symlink created"
  fi
  # Test
  echo "Mutt"
}

# XWindows Settings
_xwindows () {
  _ostype
  if [ -L "$HOME/.Xresources" ]; then
    echo "Sym link for Xresources already exists."
  else
    ln -s "$HOME/.dotfiles/Xresources $HOME/.Xresources"
    echo "Xresources symlink created....Merging Xresources"
    xrdb -merge "$HOME/.Xresourses"
    echo "XWindows settings initialized"
  fi
}

# What version of our profile to install
while getopts "b:s:mXh" opt; do
  case $opt in
    b)
    _base;;
    s)
    USER_SHELL=${OPTARG}
    _shell;;
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

shift $((OPTIND - 1))
