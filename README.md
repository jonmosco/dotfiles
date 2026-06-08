Overview
========

Home for my (Jon) dotfiles and environment configuration

## Motivation

Consistency.

## Dependencies

Common:
* [GNU Stow](https://www.gnu.org/software/stow/)
* [Ghostty](https://ghostty.org/)

macOS:
* Homebrew
* iTerm2

Linux:
* Sway

## Installation

Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/<user>/dotfiles.git ~/.dotfiles
```

If already cloned without submodules:

```bash
git submodule update --init --recursive
```

### Stow

[GNU Stow](https://www.gnu.org/software/stow/) manages symlinks from the dotfiles repo into `$HOME`. Each top-level directory is a stow package that mirrors the target directory structure.

Symlink all packages:

```bash
cd ~/.dotfiles
stow --verbose --target=$HOME */
```

Symlink a specific package:

```bash
stow --verbose --target=$HOME bash
```

Remove all symlinks:

```bash
stow --verbose --target=$HOME --delete */
```

Re-stow (remove then re-symlink, useful after reorganizing):

```bash
stow --verbose --target=$HOME --restow */
```

### Makefile

The Makefile wraps common setup tasks:

```bash
make          # stow all packages + vim/shell setup
make stow     # symlink all packages
make unstow   # remove all symlinks
make vim      # set up Vim/Vundle
make shell    # clone shell dependencies (kube-ps1, zsh-git-prompt)
```

## Submodules

* [tpm](https://github.com/tmux-plugins/tpm) — Tmux Plugin Manager (`tmux/.config/tmux/plugins/tpm`)

Enjoy (or criticize) !
