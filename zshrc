# Fig pre block. Keep at the top of this file.
. "$HOME/.fig/shell/zshrc.pre.zsh"
# .zshrc
zmodload zsh/zprof

# source /opt/homebrew/share/antigen/antigen.zsh

export PATH="$HOME/bin:/opt/homebrew/bin:/usr/local/bin:/usr/local/go/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/X11/bin:$HOME/bin/google-cloud-sdk/bin"
export GREP_COLORS='1;37;41'
export LESS='-R -i -g'
export RI='-f ansi'
export EDITOR=vim
# export GOROOT=/usr/local/go
# export GOROOT=/opt/homebrew/bin/go
export GOPATH=$HOME/code/go
export PATH=$PATH:$GOPATH/bin
export LC_ALL="en_US.UTF-8"
export LC_CTYPE=en_US.UTF-8

if [ -d  /usr/local/opt/coreutils ]; then
  PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
fi

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
autoload -Uz compinit && compinit
autoload -Uz vcs_info
autoload -U colors && colors

# treat $PROMPT like a regular shell variable
setopt PROMPT_SUBST
setopt hist_ignore_all_dups
setopt appendhistory
setopt inc_append_history
setopt beep
setopt interactivecomments
bindkey -e
unsetopt prompt_cr prompt_sp

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
# KUBE_PS1_SYMBOL_USE_IMG=true
# KUBE_PS1_BG_COLOR=15
# source ~/.zsh/prompt/robby_simple.zsh-theme
# source ~/.zsh/prompt/simple-test.zsh-prompt
# KUBE_PS1_NS_COLOR=""
# KUBE_PS1_SYMBOL_ENABLE=false
# KUBE_PS1_SEPARATOR='!'
# KUBE_PS1_PREFIX=''
# KUBE_PS1_SUFFIX=''
# KUBE_PS1_NS_ENABLE=false
# KUBE_PS1_BINARY=tt
KUBE_PS1_SYMBOL_PADDING=false
source ~/projects/kube-ps1/test/kube-ps1-test.sh
# source ~/.zsh/prompt/agnoster.zsh
source ~/.zsh/prompt/steeef.zsh-theme
# KUBE_PS1_SEPARATOR='!'

if [ -d "${HOME}/.plugins" ]; then
  for file in "${HOME}/.plugins/zsh-git-prompt/zshrc.sh"; do
    if [[ -r "$file" ]] && [[ -f "$file" ]]; then
      source $file
      # RPROMPT='$(git_super_status)'
    fi
  done
fi
# source $HOME/.plugins/git-prompt.sh
# source $HOME/.plugins/git.zsh
source $HOME/.plugins/git/git-prompt.sh

# Load extra functions and helpers
# Local environment variables and settings are kept in .localrc
# These should not go in source control (public)
for files in ~/.{aliases,dockerfunctions,exports,localrc,functions}; do
  if [[ -r "$files" ]] && [[ -f "$files" ]]; then
    source "$files"
  fi
done

# Kubernetes kubectl completion
if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

# color ls
if [[ -e "${HOME}/.dir_colors" ]] && [[ -x /usr/local/bin/gls ]]; then
  eval `gdircolors ~/.dir_colors`
  alias ls='gls --color -F'
  alias l='gls -lFha --color'
else
  export CLICOLOR=1
  export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
  alias l='ls -lFha'
fi

if [[ -d "${HOME}/.rbenv" ]]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/jmosco/Downloads/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/jmosco/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/jmosco/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/jmosco/Downloads/google-cloud-sdk/completion.zsh.inc'; fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# antigen use oh-my-zsh
# antigen bundle arialdomartini/oh-my-git
# antigen theme arialdomartini/oh-my-git-themes oppa-lana-style

# Fig post block. Keep at the bottom of this file.
#

# Fig post block. Keep at the bottom of this file.
. "$HOME/.fig/shell/zshrc.post.zsh"
