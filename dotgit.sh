#!/usr/bin/env bash

[[ ! "$DOT_FILES" ]] && echo "NOT setting dotgit aliases, since DOT_FILES not set." && return
[[ ! "$DOT_HOME" ]] && echo "NOT setting dotgit aliases, since DOT_HOME not set." && return

[[ -n "$DEBUG" ]] && echo loading dotgit aliases

[[ -z "$DOTGIT_MULTI_LIMIT" ]] && DOTGIT_MULTI_LIMIT=2
[[ -z "$DOTGIT_MULTI_ACCEPT" ]] && DOTGIT_MULTI_ACCEPT='{1}'
[[ -z "$DOTGIT_PREVIEW" ]] && DOTGIT_PREVIEW='bat -p --color=always'

# the master alias
alias .git='git --git-dir=${DOT_FILES} --work-tree=${DOT_HOME}'
# the short one
alias .g='.git'

# and all the shortcuts
alias .ga='.git add'
alias .gc='.git commit' 
alias .gco='.git checkout' 
alias .gd='.git diff'
alias .gss='.git status --short'
alias .glo='.git log --oneline --decorate' 
alias .glg='.git log --stat' 
alias .glgp='.git log --stat --patch'
alias .gbl='.git blame -w'
alias .gb='.git branch'
alias .gba='.git branch --all'
alias .gbd='.git branch --delete'
alias .gbD='.git branch --delete --force'
alias .gm='.git merge'
alias .gma='.git merge --abort'
alias .gmc='.git merge --continue'
alias .gc!='.git commit --verbose --amend'
alias .gcm='.git commit --message'
alias .gcp='.git cherry-pick'
alias .gcpa='.git cherry-pick --abort'
alias .gcpc='.git cherry-pick --continue'
alias .gclean='.git clean --interactive -d'
alias .ginit='git init --bare "${DOT_FILES}"; .git config --local status.showUntrackedFiles no'
# only set up push and pull if DOT_ORIGIN is set
if [[ -n "$DOT_ORIGIN" ]]; then
  alias .gp='.git push'
  alias .gl='.git pull'
  alias .gclone='git clone --bare "${DOT_ORIGIN}" "${DOT_FILES}"; .git config --local status.showUntrackedFiles no'
else
  alias .gp='echo "error: must first configure DOT_HOME"'
  alias .gl='echo "error: must first configure DOT_HOME"'
  alias .gclone='echo "error: must first configure DOT_HOME"'
fi
# if lazygit or gitui are avaiable, we set up a .lazygit and .gitui
[[ $(command -v lazygit) ]] &&
  alias .lazygit='lazygit -g ${DOT_FILES}/ -w ${DOT_HOME}'
[[ $(command -v gitui) ]] &&
  alias .gitui='gitui -d ${DOT_FILES}/ -w ${DOT_HOME}'

# if fzf is installed we can have nice things
# https://github.com/junegunn/fzf
read -r -d '' FZF_HEADER<<EOF
[enter] open/edit   [ctrl-/] toggle preview   [ctrl-w] toggle wrap
EOF

if [[ $(command -v fzf) ]]; then
  fzf_opts=(--multi="$DOTGIT_MULTI_LIMIT" --ansi -0 
    --preview-window "right,60%,<60(down,75%),+{2}/2"
    --header "$FZF_HEADER"
    --bind 'ctrl-z:ignore'
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-w:toggle-preview-wrap'
  )
  _dotgit_ge() {
    local gitdir
    local files
    gitdir=$(.git rev-parse --show-toplevel)
    files=$(cd "$gitdir" && .git ls-files --full-name |
      fzf "${fzf_opts[@]}" \
        --preview "$DOTGIT_PREVIEW {1}" \
        --bind "enter:accept-non-empty" \
        -q "${@:-}" | paste -sd' ')
    [[ -n "$files" ]] && sh -c "cd \"$gitdir\" && \"$EDITOR\" $files"
  }
  alias .ge='_dotgit_ge'
 
  _dotgit_gg() {
    local gitdir
    local files
    gitdir=$(.git rev-parse --show-toplevel)
    files=$(cd "$gitdir" && .git grep --full-name --color=always -n "$@" |
      fzf "${fzf_opts[@]}" -d ":" \
        --preview "$DOTGIT_PREVIEW -H{2} {1}" \
        --accept-nth "$DOTGIT_MULTI_ACCEPT" | paste -sd' ')
    [[ -n "$files" ]] && sh -c "cd \"$gitdir\" && \"$EDITOR\" $files"
  }
  alias .gg='_dotgit_gg'
else
  # simplified grep but no "interactive file select"
  alias .gg='.git grep'
fi

[[ -n "$DEBUG" ]] && echo dotgit aliases loaded

# and to make general aliases availalbe, we source this file again, but set
# the aliases by removing the leading `.` and changing all instances of the
# string 'dotgit' to 'anygit'
# shellcheck source=/dev/null
# the line above makes the source below not complain
[[ "$DOTGIT_ANYGIT" == 'yes' ]] && \
  sed '/alias \.g.*DOT_FILES/d; s/\.g/g/g; s/dotgit/anygit/g' < "$0" | source /dev/stdin  
