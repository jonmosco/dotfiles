# .zshrc
# zsh files are loaded in the following order:
# zshenv
# zprofile
# zshrc
# zlogin

export PATH=$HOME/bin:/opt/local/bin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/opt/local/sbin:/usr/X11/bin:$PATH
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
export CLICOLOR=1
export LSCOLORS=gxfxbEaEBxxEhEhBaDaCaD

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
alias vf='vagrant up --provider=vmware_fusion'
alias vd='vagrant destroy --force'

# Completion menu
zstyle ':completion:*' menu select=0
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'

# Git prompt
#zstyle ':vcs_info:*' actionformats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
#zstyle ':vcs_info:*' formats '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
#zstyle ':vcs_info:*' actionformats "%{$fg[blue]%}%b%{$reset_color%} (%{$fg[red]%}%a%{$reset_color%}) %m%u%c%{$reset_color%}%{$fg[grey]%}%{$reset_color%}"
#zstyle ':vcs_info:git*' formats "%{$fg[blue]%}%b%{$reset_color%}%m%u%c%{$reset_color%}%{$fg[grey]%}%{$reset_color%} "
#zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
#zstyle ':vcs_info:*' stagedstr "%{$fg[green]%}+%{$reset_color%}"
#zstyle ':vcs_info:*' unstagedstr "%{$fg[red]%}+%{$reset_color%}"
#zstyle ':vcs_info:*' check-for-changes true
#zstyle ':vcs_info:*' enable git
#precmd () { vcs_info }

source ~/.zsh/zsh-vcs-prompt/zshrc.sh
ZSH_VCS_PROMPT_ENABLE_CACHING='true'
ZSH_VCS_PROMPT_HIDE_COUNT='true'
#source ~/.git-prompt.sh
#GIT_PS1_SHOWDIRTYSTATE=

# Prompt
#PROMPT="%{$fg_bold[red]%}%m%{$reset_color%}:%?: » "

#PROMPT='%{$fg_bold[red]%}%m%{$reset_color%}:%?:%{$fg[cyan]%}%~%{$reset_color%}: ${vcs_info_msg_0_}% %{$reset_color%}» '
#PROMPT='%{$fg_bold[red]%}%m%{$reset_color%}:%?:%{$fg[cyan]%}%~%{$reset_color%}: ${vcs_info_msg_0_}% %{$reset_color%}» '
PROMPT='%{$fg_bold[red]%}%m%{$reset_color%}:%?:%{$fg[cyan]%}%~%{$reset_color%}: $(vcs_super_info)% %{$reset_color%}» '
#PROMPT='%{$fg_bold[red]%}%m%{$reset_color%}:%?:%{$fg[cyan]%}%~%{$reset_color%}:$(__git_ps1 " [%s]") %{$reset_color%}» '

#PROMPT='%{$fg_bold[red]%}%m%{$reset_color%}:%?:%{$reset_color%}%{$fg[cyan]%}%~%{$reset_color%}:%{vcs_info_msg_0_} » '


# Puppet Environment
export ENVPUPPET_BASEDIR=~/REPOS/
alias puppet='~/REPOS/puppet/ext/envpuppet puppet'
alias facter='~/REPOS/puppet/ext/envpuppet facter'
