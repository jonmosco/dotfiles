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

autoload -U colors && colors
autoload -U vcs_info

# trea $PROMPT like a regular shell variable
setopt PROMPT_SUBST
setopt hist_ignore_all_dups
setopt inc_append_history
setopt beep

# Hidden files
alias show_hidden="defaults write com.apple.finder AppleShowAllFiles TRUE && killall Finder"
alias hide_hidden="defaults write com.apple.finder AppleShowAllFiles FALSE && killall Finder"
alias l='ls -lFha'

# Prompt
#PROMPT="%{$fg_bold[red]%}%m%{$reset_color%}:%?: » "
PROMPT="%{$fg_bold[red]%}%m%{$reset_color%}:%?:%{$fg[cyan]%}%~%{$reset_color%}:» "
