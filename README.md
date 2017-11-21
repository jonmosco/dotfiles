Overview
========

Home for my (Jon) dotfiles and environment configuration

## Motivation

Consistency.

## Dependencies

The script dotlink4.sh will now take arguments to set up the appropriate
environment based on what is needed.

Linux:
- Bash
- XTerm
- Mutt (Provided you will want to use mutt as your MUA)
- Git

Mac OSX:
- iTerm2
- Homebrew (for updated programs)

Vim Plugins:
- NERDtree: <https://github.com/scrooloose/nerdtree>
- Solarized <Theme: https://github.com/altercation/solarized>
- Syntastic: <https://github.com/scrooloose/syntastic>
- Tabular: <https://github.com/godlygeek/tabular>
- vim-puppet: <https://github.com/rodjek/vim-puppet>
- Powerline: <https://github.com/Lokaltog/powerline> *

All dependencies are fulfilled by dotlink4.sh

## Installation

- Checkout the git repo: $ git clone https://github.com/jonmosco/dotfiles.git .dotfiles
- NOTE: From the Advanced Bash Scripting guide:
  Caution: invoking a Bash script by sh scriptname turns off Bash-specific
  extensions, and the script may therefore fail to execute.
- Run dotlink4.sh to download dependencies and set up links:

        $ cd .dotfiles
        $ chmod u+rx dotlink4.sh
        $ ./dotlink4.sh -h
        usage: dotlink4.sh -[bmXh]
        -b Base install
        -m Mutt configuration
        -X Xwindows configuration
        -h print this message

- Pick the correct option based on profile needs
- Logout and log back in (or . .bashrc)
- Enjoy (or criticize)
