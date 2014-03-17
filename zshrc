# .zshrc
# zsh files are loaded in the following order:
# zshenv
# zprofile
# zshrc
# zlogin

# Options
autoload -U promptinit
promptinit

autoload -Uz compinit && compinit
autoload -Uz vcs_info
autoload -U colors && colors

# treat $PROMPT like a regular shell variable
setopt PROMPT_SUBST
setopt hist_ignore_all_dups
setopt inc_append_history
setopt beep

# Hidden files
alias show_hidden="defaults write com.apple.finder AppleShowAllFiles TRUE && killall Finder"
alias hide_hidden="defaults write com.apple.finder AppleShowAllFiles FALSE && killall Finder"
alias l='ls -lFha'

# Completion menu
zstyle ':completion:*' menu select=1

# Git prompt
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' stagedstr     '%B%F{green}$%f%b'
zstyle ':vcs_info:*' unstagedstr   '%B%F{yellow}%%%f%b'
zstyle ':vcs_info:*' formats       '%c%u%b%m '
zstyle ':vcs_info:*' actionformats '%c%u%b%m %B%s-%a%%b '
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-aheadbehind git-remotebranch

precmd () { vcs_info }

# Prompt
#PROMPT="%{$fg_bold[red]%}%m%{$reset_color%}:%?: » "
#PROMPT="%{$fg_bold[red]%}%m%{$reset_color%}:%?:%{$fg[cyan]%}%~%{$reset_color%}:» "
#PROMPT='%{$fg_bold[red]%}%m%{$reset_color%}:%?:%{$fg[cyan]%}%~%{$reset_color%}:${vcs_info_msg_0_} %{$reset_color%}» '
PROMPT='%{$fg_bold[red]%}%m%{$reset_color%}:%?:%{$fg[cyan]%}%~:${vcs_info_msg_0_} %{$reset_color%}» '
