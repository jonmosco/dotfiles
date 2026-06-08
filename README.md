Overview
========

Home for my (Jon) dotfiles and environment configuration

## Motivation

Consistency.

## Dependencies

Mac OSX:
* iTerm2
* Homebrew
* Stow

Linux:
* Alacritty
* i3/Sway
* Stow

## Installation

Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/<user>/dotfiles.git ~/.dotfiles
```

If already cloned without submodules:

```bash
git submodule update --init --recursive
```

Run the Makefile. The default target will provide all the necessary components:

```bash
make
```

Logout and log back in (or `. ~/.bashrc`)

## Submodules

* [tpm](https://github.com/tmux-plugins/tpm) — Tmux Plugin Manager (`tmux/.config/tmux/plugins/tpm`)

Enjoy (or criticize) !
