# Fig pre block. Keep at the top of this file.
. "$HOME/.fig/shell/bash_profile.pre.bash"
#!/bin/bash

if [[ -r "${HOME}/.bashrc" ]]; then
    source "${HOME}/.bashrc"
fi

# Fig post block. Keep at the bottom of this file.
. "$HOME/.fig/shell/bash_profile.post.bash"
