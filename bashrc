# General settings
set -o noclobber

shopt -s cmdhist
shopt -s checkhash
shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell
shopt -s login_shell
shopt -s extglob

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
    export PATH="${HOME}/bin:/usr/local/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/X11/bin:$PATH"
    if [ -d  /usr/local/opt/coreutils ]; then
        PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    else
        export CLICOLOR=1
        export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
    fi
    ;;
  Linux)
    export PATH="${HOME}/bin:${HOME}/.local/bin:/bin:/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/usr/local/sbin:$PATH"
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
for files in ~/.{bash_prompt,aliases,dockerfunctions,exports,path,functions}; do
  if [[ -r "$files" ]] && [[ -f "$files" ]]; then
    # shellcheck disable=SC1090
    source "$files"
  fi
done

# Fix to test for gls on MacOS
# - Check $PATH
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

# fzf
if [ -x "$(command -v fzf)" ]; then
  source /usr/share/fzf/shell/key-bindings.bash
fi

# source kubectl bash completion
if hash kubectl 2>/dev/null; then
  # shellcheck source=/dev/null
  source <(kubectl completion bash)
fi

# gh completions
if hash gh 2>/dev/null; then
  eval "$(gh completion -s bash)"
fi

# source oc bash completion
if hash oc 2>/dev/null; then
  # shellcheck source=/dev/null
  source <(oc completion bash)
fi

export LESS="-r"
# Color man pages
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;38;5;74m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[38;5;246m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[04;38;5;146m'

if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    source $HOME/.bash-git-prompt/gitprompt.sh
fi
