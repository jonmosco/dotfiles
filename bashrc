# $Id: bashrc 54 2013-04-07 01:27:49Z jmosco $

# Very early bashrc.  Much more to come.
#
# TODO: 
# - SVN commit [DONE 1/3/12]
# - loop for different OSs and their handeling
#   of colors [DONE 1/5/12, 12/18/12]
# - Better terminal detection [DONE 1/5/12]
# - Prompt coloring with varible definitions 
# - SVN Id tags [DONE 1/5/12]
# - Change OS detection to a more specific Case statement

# General settings
set -o noclobber
set -o ignoreeof

# options that control the shell behavior
# don't overwrite the history file, add to it.
shopt -s cmdhist
shopt -s checkhash
shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell
shopt -s login_shell

# I put the ANSI colors in here as comments so I dont have to look them
# up everytime I want to make a change.
# Black            \e[0;30m
# Blue             \e[0;34m
# Green            \e[0;32m
# Cyan             \e[0;36m
# Red              \e[0;31m
# Purple           \e[0;35m
# Brown            \e[0;33m
# Gray             \e[0;37m
# Dark Gray        \e[1;30m
# Light Blue       \e[1;34m
# Light Green      \e[1;32m
# Light Cyan       \e[1;36m
# Light Red        \e[1;31m
# Light Purple     \e[1;35m
# Yellow           \e[1;33m
# White            \e[1;37m

#export LS_OPTIONS='--color=auto'
export LANG=en_US.UTF-8
export EDITOR=vim
export HISTCONTROL=ignoreboth
export HISTFILESIZE=2048
export HISTTIMEFORMAT="%D %I:%M "
export PAGER=less
export LESS='-R -i -g'
export GREP_COLORS='1;37;41'
export MAIL=$HOME/.mail

# alias definitions
alias l='ls -lFha'
alias lt='ls -ltr'
alias p='ps -ef'
alias h='history'
alias ..='cd ..'
alias grep='grep --color'
alias Xdefaults='xrdb -merge ~/.Xdefaults'
alias rm='rm -i'

# Linux
if [ "`uname`" = "Linux" ]; then
        export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
        export LS_OPTIONS='--color=auto'
        export LSCOLORS=GxFxCxDxbxDxDxxbadacad
        alias ls='ls -F --color'
        alias ostest='echo Linux settings applied!'
fi

# Mac OS
if [ "`uname`" = "Darwin" ]; then
	export PATH=$HOME/bin:/opt/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/opt/local/sbin:/usr/X11/bin
        export CLICOLOR=1
        #export LSCOLORS=GxFxCxDxBxDxDxxbadacad
	# Solarized colors
	export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
        #alias ls='ls --color=always -F'
        alias la='ls -ltr'
        alias ostest='echo Darwin settings applied!'
fi

# {Net,Free,Open}BSD
if [[ $( uname ) = *BSD && -e /usr/local/bin/colorls ]]; then
        export LSCOLORS=GxFxCxDxBxDxDxxbadacad
        alias ls='colorls -FG'
        alias ostest='echo BSD settings applied!'
fi

# Dircolors on Debian
if [ -f ~/.dircolors ]; then
        eval `dircolors -b ~/.dircolors`
        alias test2='echo dir color applied'
fi

# Git prompt
if [ -f ~/.git-prompt.sh ]; then
	source ~/.git-prompt.sh
	PS1='\[\e[0;34m\][\T]\[\e[0;32m\][\u@\h \[\e[0;33m\]\w \[\e[0;35m\]$(__git_ps1) \[\e[0;32m\]]\$ \[\e[0m\]'
else
	# Prompt without git
	PS1='\[\e[1;33m\][\T]\[\e[32m\][\u@\h \[\e[1;36m\]\w \[\e[1;33m\]]\$ \[\e[0m\]'
fi

# Regular Prompt
#PS1='\[\e[1;33m\][\T]\[\e[32m\][\u@\h \[\e[1;36m\]\w \[\e[1;33m\]]\$ \[\e[0m\]'

# Below is good
#PS1='\[\e[00;33m\][\T]\[\e[32m\][\u@\h \[\e[00;34m\]\w $(__git_ps1)\[\e[00;32m\]]\$ \[\e[0m\]'

# Git branch support
# New (and good!)
#PS1='\[\e[0;34m\][\T]\[\e[0;32m\][\u@\h \[\e[0;33m\]\w \[\e[0;35m\]$(__git_ps1) \[\e[0;32m\]]\$ \[\e[0m\]'

PS2='> '

# Nagios configuration check alias
if [ "`hostname`" = "beam.forkedprocess.net" ]; then
        alias ncheck='/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg'
fi
