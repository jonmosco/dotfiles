###############################################################################
# 
# Total rewrite of bashrc
# 
# OS Loop will be handled by a case statement instead of a series of if 
# statements
#
# TODO:
# - Needs testing on the following platforms:
#   * BSD and Solaris
# - Better way to notice what host we are on, perhaps a different color?
#
###############################################################################

# Add functions for common tasks

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

export LANG=en_US.UTF-8
export EDITOR=vim
export HISTCONTROL=ignoreboth
export HISTFILESIZE=8192
export HISTTIMEFORMAT="%D %I:%M "
export PAGER=less
export LESS='-R -i -g'
export GREP_COLORS='1;37;41'
export MAIL=$HOME/.mail

# alias definitions
alias l='ls -lFha'
alias lt='ls -ltr'
#alias p='ps -ef'
alias h='history'
alias ..='cd ..'
alias grep='grep --color'
alias rm='rm -i'
alias gp='git push'
alias vd='vagrant destroy --force'
alias vu='vagrant up'

# Set OS specific settings
OSTYPE=$( uname )

case $OSTYPE in 
	Darwin)
		export PATH=$HOME/bin:/opt/local/bin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/opt/local/sbin:/usr/X11/bin
        	export CLICOLOR=1
        	#export LSCOLORS=GxFxCxDxBxDxDxxbadacad
		# Solarized colors
		export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD
		# Thank you http://www.johnnypez.com/design-development/unable-to-find-a-java_home-at-on-mac-osx/
		export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java

        	#alias ls='ls --color=always -F'
        	alias la='ls -ltr'
		alias p='ps aux'
		alias reggie='mount -t nfs 172.16.2.2:/Uploads ~/mnt'
        	alias ostest='echo Darwin settings applied!'

		# Check if we are using Boxen
		if [ -d /opt/boxen ]; then
			source /opt/boxen/env.sh
		fi

		# Homebrew
		if [ -f $(brew --prefix)/etc/bash_completion ]; then
			. $(brew --prefix)/etc/bash_completion
		fi

		# AWS Credentials
		if [ -f ~/.aws ]; then
			source $HOME/.aws
		fi
	;;
	Linux)
        	export PATH=/bin:/sbin:/usr/local/bin::/usr/bin:/usr/sbin:bin:/usr/local/sbin
        	export LS_OPTIONS='--color=auto'
        	export LSCOLORS=GxFxCxDxbxDxDxxbadacad
        	alias ls='ls -F --color'
		alias p='ps -ef'
        	alias ostest='echo Linux settings applied!'
	;;
	*BSD)
		if [ -e /usr/local/bin/colors ]; then
        		export LSCOLORS=GxFxCxDxBxDxDxxbadacad
        		alias ls='colorls -FG'
        		alias ostest='echo BSD settings applied!'
		fi
	;;
esac

# Primary prompt with Git prompt
if [[ -L ~/.git-prompt.sh && -L ~/.git-completion.bash ]]; then
	source ~/.git-prompt.sh && source ~/.git-completion.bash
	PS1='\[\e[0;34m\][\T]\[\e[0;33m\][\u@\h \[\e[0;36m\]\w \[\e[0;35m\]$(__git_ps1) \[\e[0;33m\]]\$ \[\e[0m\]'
else
	# Prompt without git
	PS1='\[\e[1;33m\][\T]\[\e[32m\][\u@\h \[\e[1;36m\]\w \[\e[1;33m\]]\$ \[\e[0m\]'
fi

# Secondary prompt
PS2='> '

# color manpages
# Needs some work
man() {
    env LESS_TERMCAP_mb=$(printf "\e[1;31m") \
	LESS_TERMCAP_md=$(printf "\e[1;31m") \
	LESS_TERMCAP_me=$(printf "\e[0m") \
	LESS_TERMCAP_se=$(printf "\e[0m") \
	LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
	LESS_TERMCAP_ue=$(printf "\e[0m") \
	LESS_TERMCAP_us=$(printf "\e[1;32m") \
	man "$@"
}
