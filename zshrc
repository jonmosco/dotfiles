# .zshrc
# zsh files are loaded in the following order:
# zshenv
# zprofile
# zshrc
# zlogin

export PATH="$HOME/bin:$(brew --prefix coreutils)/libexec/gnubin:/usr/local/bin:/usr/local/go/bin:/usr/local/sbin:/opt/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/opt/local/sbin:/usr/X11/bin:$HOME/bin/google-cloud-sdk/bin"
#export CLICOLOR=1
#export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
export GREP_COLORS='1;37;41'
export LESS='-R -i -g'
export RI='-f ansi'
export JAVA_HOME=$(/usr/libexec/java_home)
export EDITOR=vim
export GOROOT=/usr/local/go
export GOPATH=$HOME/code/go
export PATH=$PATH:$GOPATH/bin
export KUBECONFIG="$HOME/.kube/cluster-merge:$HOME/.kube/config-dev:$HOME/.kube/config-uat:$HOME/.kube/config-prod"

# History
HISTFILE=$HOME/.history
HISTSIZE=50000
SAVEHIST=50000

# Completion functions for commands are stored in files with names beginning
# with an underscore _, and these files should be placed in a directory
# listed in the $fpath variable. You can add a directory to $fpath by adding
# a line like this to your ~/.zshrc file
fpath=(~/.zsh/completion $fpath)

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

# General
alias ls='gls --color -F'
alias l='gls -lFha --color'
alias grep='grep --color'
alias rm='rm -i'
alias ..="cd .."

# Completion menu
zstyle ':completion:*' menu select=0
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;38;5;74m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[38;33;246m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[04;38;5;146m'

# Prompt
# source ~/.zsh/prompt/fox.zsh-theme
source ~/.zsh/prompt/steeef.zsh-theme

source ~/.zsh/zsh-git-prompt/zshrc.sh

# local configuration files
if [[ -d "$HOME/.zsh/" ]]; then
  for config_file in $HOME/.zsh/*.zsh; do
    source $config_file
  done
fi

# Load extra functions and helpers
# Local environment variables and settings are kept in .localrc
# These should not go in source control (public)
for files in ~/.{aliases,dockerfunctions,localrc,functions}; do
  if [[ -r "$files" ]] && [[ -f "$files" ]]; then
    source "$files"
  fi
done

# Kubernetes kubectl completion
if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

eval `gdircolors .dir_colors`

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
