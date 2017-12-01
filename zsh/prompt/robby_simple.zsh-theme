# Robby Russel prompt.  Modified to use for minimal prompt and solarized
# dark colors
PR_RST="%f"
local ret_status="%(?:%F{166%}➜${PR_RST} :%{$fg_no_bold[red]%}➜${PR_RST} )"
PROMPT='${ret_status} %{$fg[cyan]%}%c%{$reset_color%} $(git_super_status) '
