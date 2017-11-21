Overview
========

Home for my (Jon) dotfiles and environment configuration

## Motivation

Consistency.

## Dependencies

The script dotlink.sh will now take arguments to set up the appropriate
environment based on what is needed.

Mac OSX:
- iTerm2
- Homebrew

## Installation

- Checkout the git repo
- NOTE: From the Advanced Bash Scripting guide:
  Caution: invoking a Bash script by sh scriptname turns off Bash-specific
  extensions, and the script may therefore fail to execute.
- Run dotlink.sh to download dependencies and set up links:

```
$ cd .dotfiles
$ chmod u+rx dotlink.sh
$ ./dotlink.sh -h
usage: dotlink.sh -[bmXh]
-b Base install
-m Mutt configuration
-X Xwindows configuration
-h print this message
```

Logout and log back in (or . .bashrc)

Enjoy (or criticize)
