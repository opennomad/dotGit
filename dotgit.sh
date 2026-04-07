#!/usr/bin/env bash

[[ ! "$DOT_REPO" ]] && echo "NOT setting dotgit aliases, since DOT_REPO not set." && return
[[ ! "$DOT_HOME" ]] && echo "NOT setting dotgit aliases, since DOT_HOME not set." && return

[[ -n "$DEBUG" ]] && echo loading dotgit aliases

[[ -z "$DOTGIT_MULTI_LIMIT" ]] && DOTGIT_MULTI_LIMIT=5
[[ -z "$DOTGIT_PREVIEW" ]] && DOTGIT_PREVIEW='bat -p --color=always'
[[ -z "$DOTGIT_OPEN_FMT" ]] && DOTGIT_OPEN_FMT='split' # or e.g. '+e {file}|{line}' for nvim

# the master alias
alias .git='git --git-dir=${DOT_REPO} --work-tree=${DOT_HOME}'
# the short one
alias .g='.git'

# and all the shortcuts
alias .ga='.git add'
alias .gc='.git commit'
alias .gco='.git checkout'
alias .gd='.git diff'
alias .gds='.git diff --stat'
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
alias .ginit='git init --bare "${DOT_REPO}"; .git config --local status.showUntrackedFiles no'
# only set up push and pull if DOT_ORIGIN is set
if [[ -n "$DOT_ORIGIN" ]]; then
  alias .gp='.git push'
  alias .gl='.git pull'
  alias .gclone='git clone --bare "${DOT_ORIGIN}" "${DOT_REPO}"; .git config --local status.showUntrackedFiles no'
else
  alias .gp='echo "error: must first configure DOT_ORIGIN"'
  alias .gl='echo "error: must first configure DOT_ORIGIN"'
  alias .gclone='echo "error: must first configure DOT_ORIGIN"'
fi
# if lazygit or gitui are available, we set up a .lazygit and .gitui
[[ $(command -v lazygit) ]] &&
  alias .lazygit='lazygit -g ${DOT_REPO}/ -w ${DOT_HOME}' &&
  alias .lg='.lazygit'
[[ $(command -v gitui) ]] &&
  alias .gitui='gitui -d ${DOT_REPO}/ -w ${DOT_HOME}'

# if fzf is installed we can have nice things
# https://github.com/junegunn/fzf
if [[ $(command -v fzf) ]]; then
  read -r -d '' FZF_HEADER <<EOF
[enter] open/edit   [ctrl-/] toggle preview   [ctrl-w] toggle wrap
EOF
  fzf_opts=(--multi="$DOTGIT_MULTI_LIMIT" --ansi -0
    --preview-window "right,60%,<60(down,75%),+{2}/2"
    --header "$FZF_HEADER"
    --bind 'ctrl-z:ignore'
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-w:toggle-preview-wrap'
  )
  _dotgit_ge() {
    local gitdir result
    local -a files
    gitdir=$(.git rev-parse --show-toplevel)
    result=$(cd "$gitdir" && .git ls-files --full-name |
      fzf "${fzf_opts[@]}" \
        --preview "$DOTGIT_PREVIEW {1}" \
        --bind "enter:accept-non-empty" \
        -q "${@:-}")
    [[ -z "$result" ]] && return
    while IFS= read -r line; do files+=("$line"); done <<<"$result"
    (cd "$gitdir" && "$EDITOR" "${files[@]}")
  }
  alias .ge='_dotgit_ge'

  _dotgit_gg() {
    local gitdir result clean fname lnum
    local -a editor_args
    gitdir=$(.git rev-parse --show-toplevel)
    result=$(cd "$gitdir" && .git grep --full-name --color=always -n "$@" |
      fzf "${fzf_opts[@]}" -d ":" \
        --preview "$DOTGIT_PREVIEW -H{2} {1}")
    [[ -z "$result" ]] && return
    while IFS= read -r line; do
      clean=$(printf '%s' "$line" | sed 's/\x1b\[[0-9;]*[A-Za-z]//g')
      [[ -z "$clean" ]] && continue
      fname="${clean%%:*}"
      lnum="${clean#*:}"
      lnum="${lnum%%:*}"
      if [[ "$DOTGIT_OPEN_FMT" == 'split' ]]; then
        editor_args+=("+$lnum" "$fname")
      else
        local arg="${DOTGIT_OPEN_FMT//\{file\}/$fname}"
        editor_args+=("${arg//\{line\}/$lnum}")
      fi
    done <<<"$result"
    [[ ${#editor_args[@]} -gt 0 ]] && (cd "$gitdir" && "$EDITOR" "${editor_args[@]}")
  }
  alias .gg='_dotgit_gg'
else
  # simplified grep but no "interactive file select"
  alias .gg='.git grep'
fi

[[ -n "$DEBUG" ]] && echo dotgit aliases loaded
# shellcheck source=/dev/null
[[ "$DOTGIT_ANYGIT" == 'yes' ]] &&
  sed '/alias \.g.*DOT_REPO/d; s/\.g/g/g; s/dotgit/anygit/g' <"${BASH_SOURCE[0]:-$0}" | source /dev/stdin
