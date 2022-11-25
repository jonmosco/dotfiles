# .zshrc
zmodload zsh/zprof

# source /opt/homebrew/share/antigen/antigen.zsh

export PATH="$HOME/bin:/opt/homebrew/bin:/usr/local/bin:/usr/local/go/bin:/usr/local/sbin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/X11/bin:$HOME/bin/google-cloud-sdk/bin"
export GREP_COLORS='1;37;41'
export LESS='-R -i -g'
export RI='-f ansi'
export EDITOR=vim
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
# source ~/.zsh/prompt/robby_simple.zsh-theme
# source ~/.zsh/prompt/simple-test.zsh-prompt
source ~/.zsh/prompt/steeef.zsh-theme

# if [ -d "${HOME}/.plugins" ]; then
#   for file in "${HOME}/.plugins/zsh-git-prompt/zshrc.sh"; do
#     if [[ -r "$file" ]] && [[ -f "$file" ]]; then
#       source $file
#       # RPROMPT='$(git_super_status)'
#     fi
#   done
# fi
# # source $HOME/.plugins/git-prompt.sh
# # source $HOME/.plugins/git.zsh
# source $HOME/.plugins/git/git-prompt.sh

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
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

PATH="/Users/jmosco/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/jmosco/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/jmosco/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/jmosco/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/jmosco/perl5"; export PERL_MM_OPT;
