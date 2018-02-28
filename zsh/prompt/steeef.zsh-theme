# prompt style and colors based on Steve Losh's Prose theme:
# http://github.com/sjl/oh-my-zsh/blob/master/themes/prose.zsh-theme

export VIRTUAL_ENV_DISABLE_PROMPT=1

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('%F{blue}`basename $VIRTUAL_ENV`%f') '
}
PR_GIT_UPDATE=1

setopt prompt_subst

autoload -U add-zsh-hook
autoload -Uz vcs_info

turquoise="%F{cyan}"
orange="%F{yellow}"
purple="%F{magenta}"
hotpink="%F{red}"
limegreen="%F{green}"

PR_RST="%f"
FMT_BRANCH="(%{$turquoise%}%b%u%c${PR_RST})"
FMT_ACTION="(%{$limegreen%}%a${PR_RST})"
FMT_UNSTAGED="%{$orange%}●"
FMT_STAGED="%{$limegreen%}●"


function steeef_preexec {
    case "$(history $HISTCMD)" in
        *git*)
            PR_GIT_UPDATE=1
            ;;
        *svn*)
            PR_GIT_UPDATE=1
            ;;
    esac
}
add-zsh-hook preexec steeef_preexec

function steeef_chpwd {
    PR_GIT_UPDATE=1
}
add-zsh-hook chpwd steeef_chpwd

function steeef_precmd {
    if [[ -n "$PR_GIT_UPDATE" ]] ; then
        # check for untracked files or updated submodules, since vcs_info doesn't
        if git ls-files --other --exclude-standard 2> /dev/null | grep -q "."; then
            PR_GIT_UPDATE=1
            FMT_BRANCH="(%{$turquoise%}%b%u%c%{$hotpink%}●${PR_RST})"
        else
            FMT_BRANCH="(%{$turquoise%}%b%u%c${PR_RST})"
        fi
        zstyle ':vcs_info:*:prompt:*' formats "${FMT_BRANCH} "

        vcs_info 'prompt'
        PR_GIT_UPDATE=
    fi
}
add-zsh-hook precmd steeef_precmd

if [[ -f ~/repos/kube-ps1/kube-ps1-devel/kube-ps1.sh ]]; then
  # export KUBE_PS1_SYMBOL_COLOR=""
  # export KUBE_PS1_CTX_COLOR="5"
  # export KUBE_PS1_NS_COLOR="magenta"
  # export KUBE_PS1_NS_COLOR="white"
  # export KUBE_PS1_SEPARATOR=' '
  # KUBE_PS1_SYMBOL_USE_IMG=true
  # export KUBE_PS1_PREFIX=''
  # export KUBE_PS1_SUFFIX=''
  # export KUBE_PS1_DIVIDER=''
  # export KUBE_PS1_BINARY=""
  # export KUBE_PS1_NS_ENABLE=false
  # export KUBE_PS1_BG_COLOR="87"
  # export KUBE_PS1_BG_COLOR="white"
  # export KUBE_PS1_BINARY="oc"
  # export KUBE_PS1_SYMBOL_USE_IMG=true

  # Develop branch
  export KUBE_PS1_CTX_COLOR="124"
  # export KUBE_PS1_CTX_COLOR="white"
  # export KUBE_PS1_NS_COLOR="green"
  source ~/repos/kube-ps1/kube-ps1-devel/kube-ps1.sh

  # Stable branch
  # source ~/repos/kube-ps1/kube-ps1-stable/kube-ps1/kube-ps1.sh
fi

CROSS="\u2718"
LIGHTNING="\u26a1"
GEAR="\u2699"

prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}$CROSS"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}$LIGHTNING"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}$GEAR "

  [[ -n "$symbols" ]] && prompt_segment $PRIMARY_FG default " $symbols "
}

CURRENT_BG='NONE'
PRIMARY_FG=black

# Characters
SEGMENT_SEPARATOR="\ue0b0"

prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  CURRENT_BG=$1
  [[ -n $3 ]] && print -n $3
}

PROMPT=$'
$(RETVAL=$? prompt_status)%F{166%}%n${PR_RST} $fg[white]%}at${PR_RST} %{$orange%}%m${PR_RST} $fg[white]%}in${PR_RST} %{$limegreen%}%~${PR_RST} $(kube_ps1) $(virtualenv_info)
$ '
