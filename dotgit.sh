#!/usr/bin/env bash

[[ ! "${DOT_FILES}" ]] && echo "NOT setting dotGit aliases, since DOT_FILES not set." && return
[[ ! "${DOT_HOME}" ]] && echo "NOT setting dotGit aliases, since DOT_HOME not set." && return

alias .g='git --git-dir=${DOT_FILES} --work-tree=${DOT_HOME}'
alias .ga='.g add'
alias .gc='.g commit' 
alias .gco='.g checkout' 
alias .gd='.g diff'
alias .gss='.g status --short'
alias .gp='.g push'
alias .gl='.g pull'
alias .glo='.g log --oneline --decorate' 
alias .glg='.g log --stat' 
alias .glgp='.g log --stat --patch'

# shellcheck disable=SC2142,SC215
alias .ge='_dotgit_ge(){
  cd ${DOT_HOME}
  FILE=$( Q="$@"; .g ls-files --full-name |
    fzf --preview "bat -n --color=always {}" -q "${Q}")
  [[ "$FILE" ]] && $EDITOR "${FILE}"
  cd ${OLDPWD}
}; _dotgit_ge'

if [[ $(command -v fzf) ]]; then
  # shellcheck disable=SC2142
  alias .gg='_dotgit_gg(){
  cd ${DOT_HOME}
  .g grep --full-name --color=always -n "$@" |
    fzf -0 --ansi -d ":" --bind "enter:execute($EDITOR +{2} {1})" \
    --preview "bat -n -H {2} --color=always {1}" \
    --preview-window "right,60%,<60(down,75%),+{2}/2"
      cd ${OLDPWD}
    }; _dotgit_gg'
else
  alias .gg='.g grep'
fi

alias .ginit='git init --bare "${DOT_FILES}"; .g config --local status.showUntrackedFiles no'
[[ -n "$DOT_ORIGIN" ]] && alias .gclone='git clone --bare "${DOT_ORIGIN}" "${DOT_FILES}"; .g config --local status.showUntrackedFiles no'

# if lazygit or gitui are avaiable, we set up a .lazygit and .gitui
[[ $(command -v lazygit) ]] &&
  alias .lazygit='lazygit -g ${DOT_FILES}/.dotfiles/ -w ${DOT_HOME}'
[[ $(command -v gitui) ]] &&
  alias .gitui='gitui -d ${DOT_FILES}/.dotfiles/ -w ${DOT_HOME}'
