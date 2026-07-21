#!/usr/bin/env bash

[[ ! "$DOT_REPO" ]] && echo "NOT setting dotgit aliases, since DOT_REPO not set." && return
[[ ! "$DOT_HOME" ]] && echo "NOT setting dotgit aliases, since DOT_HOME not set." && return

[[ -n "$DEBUG" ]] && echo loading dotgit functions

[[ -z "$DOTGIT_MULTI_LIMIT" ]] && DOTGIT_MULTI_LIMIT=5
[[ -z "$DOTGIT_PREVIEW" ]] && DOTGIT_PREVIEW='bat -p --color=always'
[[ -z "$DOTGIT_OPEN_FMT" ]] && DOTGIT_OPEN_FMT='split'

# Internal: run git with dotfiles repo paths.
# Isolated on purpose — the anygit sed removes this function
# and rewrites all call sites to use bare `git`.
_dotgit_git() {
  git --git-dir="${DOT_REPO}" --work-tree="${DOT_HOME}" "$@"
}

# user-facing commands
.git() { _dotgit_git "$@"; }
.g() { _dotgit_git "$@"; }

.ga()   { _dotgit_git add "$@"; }
.gc()   { _dotgit_git commit "$@"; }
.gco()  { _dotgit_git checkout "$@"; }
.gd()   { _dotgit_git diff "$@"; }
.gds()  { _dotgit_git diff --stat "$@"; }
.gss()  { _dotgit_git status --short "$@"; }
.glo()  { _dotgit_git log --oneline --decorate "$@"; }
.glg()  { _dotgit_git log --stat "$@"; }
.glgp() { _dotgit_git log --stat --patch "$@"; }
.gbl()  { _dotgit_git blame -w "$@"; }
.gb()   { _dotgit_git branch "$@"; }
.gba()  { _dotgit_git branch --all "$@"; }
.gbd()  { _dotgit_git branch --delete "$@"; }
.gbD()  { _dotgit_git branch --delete --force "$@"; }
.gm()   { _dotgit_git merge "$@"; }
.gma()  { _dotgit_git merge --abort "$@"; }
.gmc()  { _dotgit_git merge --continue "$@"; }
.gcm()  { _dotgit_git commit --message "$@"; }
.gcp()  { _dotgit_git cherry-pick "$@"; }
.gcpa() { _dotgit_git cherry-pick --abort "$@"; }
.gcpc() { _dotgit_git cherry-pick --continue "$@"; }
.gclean() { _dotgit_git clean --interactive -d "$@"; }

# push / pull — guard on DOT_ORIGIN
if [[ -n "$DOT_ORIGIN" ]]; then
  .gp()  { _dotgit_git push "$@"; }
  .gl()  { _dotgit_git pull "$@"; }
  .gclone() {
    git clone --bare "${DOT_ORIGIN}" "${DOT_REPO}" &&
    _dotgit_git config --local status.showUntrackedFiles no
  }
else
  .gp()  { echo "error: must first configure DOT_ORIGIN"; }
  .gl()  { echo "error: must first configure DOT_ORIGIN"; }
  .gclone() { echo "error: must first configure DOT_ORIGIN"; }
fi

# .gc! — ! not valid in function names, so alias it
.gcam() { _dotgit_git commit --verbose --amend "$@"; }
alias .gc!='.gcam'

# setup
.ginit() {
  git init --bare "${DOT_REPO}" &&
  _dotgit_git config --local status.showUntrackedFiles no
}

# GUI front-ends
if [[ $(command -v lazygit) ]]; then
  .lazygit() { lazygit -g "${DOT_REPO}/" -w "${DOT_HOME}"; }
  .lg() { .lazygit "$@"; }
fi
[[ $(command -v gitui) ]] &&
  .gitui() { gitui -d "${DOT_REPO}/" -w "${DOT_HOME}"; }

# interactive commands (fzf)
if [[ $(command -v fzf) ]]; then
  fzf_opts=(--multi="$DOTGIT_MULTI_LIMIT" --ansi -0
    --preview-window "right,60%,<60(down,75%),+{2}/2"
    --header '[enter] open/edit   [ctrl-/] toggle preview   [ctrl-w] toggle wrap'
    --bind 'ctrl-z:ignore'
    --bind 'ctrl-/:toggle-preview'
    --bind 'ctrl-w:toggle-preview-wrap'
  )

  .ge() {
    local gitdir result
    local -a files
    gitdir=$(_dotgit_git rev-parse --show-toplevel) || return
    result=$(cd "$gitdir" >/dev/null 2>&1 && _dotgit_git ls-files --full-name |
      fzf "${fzf_opts[@]}" \
        --preview "$DOTGIT_PREVIEW {1}" \
        --bind "enter:accept-non-empty" \
        -q "${*:-}")
    [[ -z "$result" ]] && return
    while IFS= read -r line; do files+=("$line"); done <<<"$result"
    (cd "$gitdir" && "$EDITOR" "${files[@]}")
  }

  .gg() {
    local gitdir result clean fname lnum
    local -a editor_args
    gitdir=$(_dotgit_git rev-parse --show-toplevel) || return
    result=$(cd "$gitdir" && _dotgit_git grep --full-name --color=always -n "$@" |
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
else
  .gg() { _dotgit_git grep "$@"; }
fi

[[ -n "$DEBUG" ]] && echo dotgit functions loaded

# ANYGIT mode: source a transformed copy with unprefixed names
if [[ "$DOTGIT_ANYGIT" == 'yes' ]] && [[ -z "$_DOTGIT_ANYGIT_SOURCED" ]]; then
  export _DOTGIT_ANYGIT_SOURCED=1
  # shellcheck source=/dev/null
  source <(
    sed -e '/^_dotgit_git/,/^}/d' \
        -e '/^\.git()/d' \
        -e '/^# ========== tab completion ==========$/,$d' \
        -e 's/\b_dotgit_git\b/git/g' \
        -e 's/\.g/g/g' \
        -e 's/\bdotgit\b/anygit/g' \
        "${BASH_SOURCE[0]:-$0}"
  )
fi

# ========== tab completion ==========

_dotgit_complete() {
  local cmd="${COMP_WORDS[0]}"
  local cur="${COMP_WORDS[COMP_CWORD]}"

  # Map dotgit function to the equivalent git subcommand + flags
  # so we can delegate to git's own completion via _git().
  _dotgit_delegate() {
    local -a orig=("${COMP_WORDS[@]}")
    local orig_idx=$COMP_CWORD
    COMP_WORDS=(git "$@" "${orig[@]:1}")
    COMP_CWORD=$((orig_idx + $#))
    _git 2>/dev/null
    COMP_WORDS=("${orig[@]}")
    COMP_CWORD=$orig_idx
  }

  case "$cmd" in
    .git|.g)              _dotgit_delegate ;;
    .ga)
      local gitdir line
      gitdir=$(_dotgit_git rev-parse --show-toplevel 2>/dev/null) || return
      while IFS= read -r line; do
        [[ -z "$cur" || "$line" == "$cur"* ]] && COMPREPLY+=("$line")
      done < <(cd "$gitdir" >/dev/null 2>&1 && { _dotgit_git ls-files --full-name; _dotgit_git ls-files --others --exclude-standard --directory; } 2>/dev/null)
      ;;
    .gc)                  _dotgit_delegate commit ;;
    .gco)                 _dotgit_delegate checkout ;;
    .gd)                  _dotgit_delegate diff ;;
    .gds)                 _dotgit_delegate diff --stat ;;
    .gss)                 _dotgit_delegate status --short ;;
    .glo)                 _dotgit_delegate log --oneline --decorate ;;
    .glg)                 _dotgit_delegate log --stat ;;
    .glgp)                _dotgit_delegate log --stat --patch ;;
    .gbl)                 _dotgit_delegate blame -w ;;
    .gb)                  _dotgit_delegate branch ;;
    .gba)                 _dotgit_delegate branch --all ;;
    .gbd)                 _dotgit_delegate branch --delete ;;
    .gbD)                 _dotgit_delegate branch --delete --force ;;
    .gm)                  _dotgit_delegate merge ;;
    .gma)                 _dotgit_delegate merge --abort ;;
    .gmc)                 _dotgit_delegate merge --continue ;;
    .gcm)                 _dotgit_delegate commit --message ;;
    .gcp)                 _dotgit_delegate cherry-pick ;;
    .gcpa)                _dotgit_delegate cherry-pick --abort ;;
    .gcpc)                _dotgit_delegate cherry-pick --continue ;;
    .gclean)              _dotgit_delegate clean --interactive -d ;;
    .gp)                  _dotgit_delegate push ;;
    .gl)                  _dotgit_delegate pull ;;
    .gcam|'.gc!')         _dotgit_delegate commit --verbose --amend ;;
    .ge)
      local gitdir line
      gitdir=$(_dotgit_git rev-parse --show-toplevel 2>/dev/null) || return
      while IFS= read -r line; do
        [[ -z "$cur" || "$line" == "$cur"* ]] && COMPREPLY+=("$line")
      done < <(cd "$gitdir" >/dev/null 2>&1 && _dotgit_git ls-files --full-name 2>/dev/null)
      ;;
    .gg)
      _dotgit_delegate grep ;;
  esac
}

if [[ -n "$BASH_VERSION" ]] && [[ -t 0 ]]; then
  for _dotgit_cmd in .git .g .ga .gc .gco .gd .gds .gss .glo .glg .glgp \
                     .gbl .gb .gba .gbd .gbD .gm .gma .gmc .gcm .gcp \
                     .gcpa .gcpc .gclean .gp .gl .ginit .gclone .gcam \
                     .ge .gg .lazygit .lg .gitui; do
    complete -o bashdefault -o default -F _dotgit_complete "$_dotgit_cmd" 2>/dev/null || true
  done
  unset _dotgit_cmd
fi

if [[ -n "$ZSH_VERSION" ]] && [[ -o interactive ]]; then
  # shellcheck disable=SC1087,SC1090,SC2034,SC2296
  _dotgit_zsh_complete() {
    local cmd="${words[1]}"
    _dotgit_zsh_delegate() {
      local -a orig_words=("${words[@]}")
      local orig_cword=$CURRENT
      local service=git
      words=(git "$@" "${orig_words[@]:1}")
      (( CURRENT = CURRENT + $# ))
      _git 2>/dev/null
      words=("${orig_words[@]}")
      CURRENT=$orig_cword
    }
    case "$cmd" in
      .git|.g)              _dotgit_zsh_delegate ;;
      .ga)
        local gitdir line
        gitdir=$(_dotgit_git rev-parse --show-toplevel 2>/dev/null) || return 1
        local -a files
        while IFS= read -r line; do
          [[ -z "$PREFIX" || "$line" == "$PREFIX"* ]] && files+=("$line")
      done < <(cd "$gitdir" >/dev/null 2>&1 && { _dotgit_git ls-files --full-name; _dotgit_git ls-files --others --exclude-standard --directory; } 2>/dev/null)
        _describe -t files 'file' files
        ;;
      .gc)                  _dotgit_zsh_delegate commit ;;
      .gco)                 _dotgit_zsh_delegate checkout ;;
      .gd)                  _dotgit_zsh_delegate diff ;;
      .gds)                 _dotgit_zsh_delegate diff --stat ;;
      .gss)                 _dotgit_zsh_delegate status --short ;;
      .glo)                 _dotgit_zsh_delegate log --oneline --decorate ;;
      .glg)                 _dotgit_zsh_delegate log --stat ;;
      .glgp)                _dotgit_zsh_delegate log --stat --patch ;;
      .gbl)                 _dotgit_zsh_delegate blame -w ;;
      .gb)                  _dotgit_zsh_delegate branch ;;
      .gba)                 _dotgit_zsh_delegate branch --all ;;
      .gbd)                 _dotgit_zsh_delegate branch --delete ;;
      .gbD)                 _dotgit_zsh_delegate branch --delete --force ;;
      .gm)                  _dotgit_zsh_delegate merge ;;
      .gma)                 _dotgit_zsh_delegate merge --abort ;;
      .gmc)                 _dotgit_zsh_delegate merge --continue ;;
      .gcm)                 _dotgit_zsh_delegate commit --message ;;
      .gcp)                 _dotgit_zsh_delegate cherry-pick ;;
      .gcpa)                _dotgit_zsh_delegate cherry-pick --abort ;;
      .gcpc)                _dotgit_zsh_delegate cherry-pick --continue ;;
      .gclean)              _dotgit_zsh_delegate clean --interactive -d ;;
      .gp)                  _dotgit_zsh_delegate push ;;
      .gl)                  _dotgit_zsh_delegate pull ;;
      .gcam|'.gc!')         _dotgit_zsh_delegate commit --verbose --amend ;;
      .ge)
        local gitdir line
        gitdir=$(_dotgit_git rev-parse --show-toplevel 2>/dev/null) || return 1
        local -a files
        while IFS= read -r line; do
          [[ -z "$PREFIX" || "$line" == "$PREFIX"* ]] && files+=("$line")
        done < <(cd "$gitdir" >/dev/null 2>&1 && _dotgit_git ls-files --full-name 2>/dev/null)
        _describe -t files 'file' files
        ;;
      .gg)
        _dotgit_zsh_delegate grep ;;
    esac
  }

  for _dotgit_cmd in .git .g .ga .gc .gco .gd .gds .gss .glo .glg .glgp \
                     .gbl .gb .gba .gbd .gbD .gm .gma .gmc .gcm .gcp \
                     .gcpa .gcpc .gclean .gp .gl .ginit .gclone .gcam \
                     '.gc!' .ge .gg .lazygit .lg .gitui; do
    compdef _dotgit_zsh_complete "$_dotgit_cmd" 2>/dev/null || true
  done
  unset _dotgit_cmd
fi
