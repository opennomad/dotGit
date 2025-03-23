#!/usr/bin/env bash

[[ ! "${DOT_FILES}" ]] && echo "NOT setting dotGit aliases, since DOT_FILES not set." && return
[[ ! "${DOT_HOME}" ]] && echo "NOT setting dotGit aliases, since DOT_HOME not set." && return

# the master alias
alias .git='git --git-dir=${DOT_FILES} --work-tree=${DOT_HOME}'
# and all the shortcuts
alias .g='.git'
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

# if fzf is installed we can have nice things
# https://github.com/junegunn/fzf
if [[ $(command -v fzf) ]]; then
  fzf_opts=(--preview "bat -n --color=always {}"
    --multi --ansi -0 
    --preview-window "right,60%,<60(down,75%),+{2}/2"
    --bind 'ctrl-z:ignore'
  )
  _dotgit_ge() {
    files=$(cd "$DOT_HOME" && .g ls-files --full-name |
      fzf "${fzf_opts[@]}" \
      --preview "bat --color=always {1}" \
      --bind "enter:accept-non-empty" \
      -q "${@:-}" | paste -sd' ')
    [[ -n "$files" ]] && sh -c "cd $DOT_HOME && $EDITOR $files"
  }
  alias .ge='_dotgit_ge'
 
  _dotgit_gg() {
    files=$(cd "$DOT_HOME" && .g grep --full-name --color=always -n "$@" |
      fzf "${fzf_opts[@]}" -d ":" \
        --preview "bat --color=always -H{2} {1}" \
        --accept-nth "-c 'e {1}|{2}'" | paste -sd' ')
    [[ -n "$files" ]] && sh -c "cd $DOT_HOME && $EDITOR $files"
  }
  # shellcheck disable=SC2154
  alias .gg='_dotgit_gg' # | read -r f; echo $f'
else
  # simplified grep but no "interactive file select"
  alias .gg='.g grep'
fi

alias .ginit='git init --bare "${DOT_FILES}"; .g config --local status.showUntrackedFiles no'
[[ -n "$DOT_ORIGIN" ]] && alias .gclone='git clone --bare "${DOT_ORIGIN}" "${DOT_FILES}"; .g config --local status.showUntrackedFiles no'

# if lazygit or gitui are avaiable, we set up a .lazygit and .gitui
[[ $(command -v lazygit) ]] &&
  alias .lazygit='lazygit -g ${DOT_FILES}/.dotfiles/ -w ${DOT_HOME}'
[[ $(command -v gitui) ]] &&
  alias .gitui='gitui -d ${DOT_FILES}/.dotfiles/ -w ${DOT_HOME}'
