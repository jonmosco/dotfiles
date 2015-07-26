# .zshrc
# zsh files are loaded in the following order:
# zshenv
# zprofile
# zshrc
# zlogin

export PATH="$PATH:$HOME/bin:/opt/local/bin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/opt/local/sbin:/usr/X11/bin"
export CLICOLOR=1
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
export GREP_COLORS='1;37;41'
export LESS='-R -i -g'
export RI='-f ansi'
export JAVA_HOME=$(/usr/libexec/java_home)
export EDITOR=vim
export GOROOT=/usr/local/go

# History
HISTFILE=$HOME/.history
HISTSIZE=10000
SAVEHIST=10000

fpath=(~/.zsh/Completion $fpath)

# Options
autoload -U promptinit
promptinit

autoload -Uz compinit && compinit
autoload -Uz vcs_info
autoload -U colors && colors

# treat $PROMPT like a regular shell variable
setopt PROMPT_SUBST
setopt hist_ignore_all_dups
setopt appendhistory
setopt inc_append_history
setopt beep
setopt IGNORE_EOF
bindkey -e

# Hidden files
alias show_hidden="defaults write com.apple.finder AppleShowAllFiles TRUE && killall Finder"
alias hide_hidden="defaults write com.apple.finder AppleShowAllFiles FALSE && killall Finder"

# General
alias l='ls -lFha'
alias grep='grep --color'
alias rm='rm -i'
alias vf='vagrant up --provider=vmware_fusion'
alias vd='vagrant destroy --force'
alias vs='vagrant status'
alias vu='vagrant up'
alias ls='ls -p'
alias myip="ifconfig | perl -nle '/inet ([^ ]+)/ and print $1'"
alias ..="cd .."
alias mod='mkdir -p {files,manifests,templates,lib}'
alias bexec='bundle exec'
alias cf='chef generate'

# Completion menu
zstyle ':completion:*' menu select=0
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'

# Git prompt
source ~/.zsh/zsh-vcs-prompt/zshrc.sh
ZSH_VCS_PROMPT_ENABLE_CACHING='true'
ZSH_VCS_PROMPT_HIDE_COUNT='true'

# AWS Credentials
if [[ -r ~/.aws ]]; then
  source ~/.aws
fi

PROMPT='%{$fg[cyan]%}┌[%{$fg_bold[white]%}%n%{$reset_color%}%{$fg[cyan]%}@%{$fg_bold[white]%}%M%{$reset_color%}%{$fg[cyan]%}]%{$fg[white]%}-%{$fg[cyan]%}(%{$fg_bold[red]%}%~%{$reset_color%}%{$fg[cyan]%})%{$reset_color%}$(vcs_super_info)%{$reset_color%}
%{$fg[cyan]%}└> % %{$reset_color%}'

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;38;5;74m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[38;33;246m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[04;38;5;146m'

# Include local directories
if [[ -r ~/.zsh/misc/ ]]; then
  source ~/.zsh/misc/*
fi
