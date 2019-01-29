# General settings
set -o noclobber

shopt -s cmdhist
shopt -s checkhash
shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell
shopt -s login_shell
shopt -s extglob

export EDITOR=vim
export HISTCONTROL=ignoreboth
export HISTFILESIZE=150000
export HISTSIZE=150000
export HISTTIMEFORMAT="%D %I:%M "
export PAGER=less
export LESS='-R -i -g'
export GREP_COLORS='1;37;41'
export MAIL=$HOME/.mail
export XAUTHORITY=~/.Xauthority

# alias definitions
alias l='ls -lFha'
alias lt='ls -ltr'
alias h='history'
alias ..='cd ..'
alias grep='grep --color'
alias rmi='rm -i'
alias tree='tree -C'

# Set OS specific settings
OSTYPE=$(uname)

case $OSTYPE in
  Darwin)
    export PATH="${HOME}/bin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/X11/bin:$PATH"
    export CLICOLOR=1
    export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
    ;;
  Linux)
    export PATH="${HOME}/bin:/sbin:/usr/local/bin::/usr/bin:/usr/sbin:bin:/usr/local/sbin:$PATH"
    #export LS_OPTIONS='--color=auto'
    ;;
  *BSD)
    if [ -e /usr/local/bin/colors ]; then
      export LSCOLORS=GxFxCxDxBxDxDxxbadacad
      alias ls='colorls -FG'
    fi
    ;;
esac

# Load extra functions and helpers
# Local environment variables and settings are kept in .localrc
# These should not go in source control (public)
for files in ~/.{bash_prompt,aliases,dockerfunctions,localrc,functions}; do
  if [[ -r "$files" ]] && [[ -f "$files" ]]; then
    # shellcheck disable=SC1090
    source "$files"
  fi
done

if [[ -r ~/.dircolors ]]; then
  eval `dircolors ~/.dircolors`
  # eval "$(dircolors ~/.dircolors)"
  alias ls='ls -F --color=auto'
fi

# Confirm we want to exit when in a container to avoid loosing all the work
# we might have done
if [ -f /.dockerenv ]; then
  set -o ignoreeof
fi

# shellcheck disable=SC1090
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# kubectl completion
if command -v kubectl >/dev/null; then
  source <(kubectl completion bash)
fi

# Color man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;38;5;74m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[38;5;246m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[04;38;5;146m'
