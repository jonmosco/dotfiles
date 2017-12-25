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

# alias definitions
alias l='ls -lFha'
alias lt='ls -ltr'
alias h='history'
alias ..='cd ..'
alias grep='grep --color'
alias rmi='rm -i'
alias tree='tree -C'

# Set OS specific settings
OSTYPE=$( uname )

case $OSTYPE in
  Darwin)
    export PATH=$HOME/bin:/opt/local/bin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/opt/local/sbin:/usr/X11/bin:$PATH
    export CLICOLOR=1
    export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
    ;;
  Linux)
    export PATH=/bin:/sbin:/usr/local/bin::/usr/bin:/usr/sbin:bin:/usr/local/sbin
    export LS_OPTIONS='--color=auto'
    export LSCOLORS=GxFxCxDxbxDxDxxbadacad
    alias ls='ls -F --color'
    alias p='ps -ef'
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
for files in ~/.{aliases,dockerfunctions,localrc,functions}; do
  if [[ -r "$files" ]] && [[ -f "$files" ]]; then
    # shellcheck disable=SC1090
    source "$files"
  fi
done

_exitstatus ()
{


  EXITSTATUS="$?"

  orange=$(tput setaf 166);
  green=$(tput setaf 64);


  if [ "${EXITSTATUS}" -ne 0 ]; then
    PS1="\[\e[37;41m\]\[${EXITSTATUS}]\[\e[0;33m\] \[${orange}\]\u\[\e[1;37m\]@\[\e[0;33m\]\h\[\e[0;38m\]\e[1;37m\]:\[${green}\]\w\[\e[0;38m\]\e[1;37m\]:\[\e[0;38m\]$ "
  else
    PS1='\[${orange}\]\u\[\e[1;37m\]@\[\e[0;33m\]\h\[\e[0;38m\]\e[1;37m\]:\[${green}\]\w\[\e[0;38m\]\e[1;37m\]:\[\e[0;38m\] $(kube_ps1) $ '
  fi
  export PS1

  # Secondary prompt
  PS2='> '
}

orange=$(tput setaf 166);
reset_color=$(tput sgr0)
# cyan=$(tput setaf 6)
white=$(tput setaf 15)
yellow=$(tput setaf 136)
green=$(tput setaf 64);

# shellcheck disable=SC1090
source ~/repos/kube-ps1/kube-ps1.sh

PS1='\[${orange}\u\]' # username
PS1+='\[${white}@\]' # @
PS1+='\[${yellow}\h\]' # hostname
if [ -f /.dockerenv ]; then
  # Unicode Moby
  PS1+=' 🐳  '
fi
PS1+='\[${white}:\]'
PS1+='\[${green}\w\]'
PS1+='\[${white}:\]'
PS1+='\[ $(kube_ps1)\]' # kube-ps1 prompt
PS1+='\[${reset_color}\]'
PS1+='$ '
export PS1

# PROMPT_COMMAND=_exitstatus

# shellcheck disable=SC1090
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
