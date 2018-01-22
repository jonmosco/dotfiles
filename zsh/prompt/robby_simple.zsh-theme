# Robby Russel prompt.  Modified to use for minimal prompt and solarized
# dark colors
if [[ -f ~/repos/kube-ps1/kube-ps1.sh ]]; then
  # KUBE_PS1_PREFIX='{'
  # export KUBE_PS1_PREFIX=''
  # export KUBE_PS1_SEPARATOR=''
  # export KUBE_PS1_SYMBOL_USE_IMG=true
  export KUBE_PS1_NS_ENABLE=false
  source ~/repos/kube-ps1/kube-ps1.sh
fi

PR_RST="%f"
local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT='${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(kube_ps1) '
