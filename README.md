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
* Hyprland
* Quickshell
* Ghostty

Legacy desktop configs (sway, i3, alacritty, wofi) are in `legacy/` and are not deployed by default.

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

Symlink all active packages:

```bash
cd ~/.dotfiles
make stow
```

Symlink a specific package:

```bash
stow --verbose --target=$HOME bash
```

Remove all active symlinks:

```bash
make unstow
```

Re-stow (useful after reorganizing):

```bash
make stow
```

### Makefile

The Makefile wraps common setup tasks:

```bash
make          # stow active packages + vim/shell setup
make stow     # symlink active packages (see STOW_PACKAGES in Makefile)
make unstow   # remove active symlinks
make check    # dry-run stow
make vim      # set up Vim/Vundle
make shell    # clone shell dependencies (kube-ps1, zsh-git-prompt)
```

## Submodules

* [tpm](https://github.com/tmux-plugins/tpm) — Tmux Plugin Manager (`tmux/.config/tmux/plugins/tpm`)

Enjoy (or criticize) !
