# dotGit ::: 🪄 dotfiles +  🧸 bare git repo + 🐚 shell aliases

There are a lot of ways to manage your dotfiles. dotGit implements an idea that has been floating around on the internet for a while: a bare git repo for storing your dotfiles. A quick search finds [this post](https://news.ycombinator.com/item?id=11070797), but there may be older sources. dotGit combines this with some convenient shell aliases, a couple of functions, and FZF's matching magic to track your dotfiles files with ease.

dotGit has modest aims:
- 🏡 keep configuration files where tools expect them in `$HOME`
- 🐚 stay as light and close to git and the shell as possible
- 🚀 reduce friction and make configuration changes quick and convenient


## TL;DR

```bash
# 1. in your .zshrc or .bashrc:
export DOT_REPO="${HOME}/.dotfiles"
export DOT_HOME="${HOME}"
export DOT_ORIGIN="git@github.com:user/dotfiles.git"  # optional
source /path/to/dotgit.sh

# 2. initialize a new repo, or clone an existing one
.ginit        # new repo
.gclone       # clone from DOT_ORIGIN

# 3. daily use
.ge zshrc     # fuzzy-find and edit files matching "zshrc"
.gg PATH      # grep across dotfiles, jump to result
.gss          # status
.ga .zshrc    # stage a file
.gc -m 'msg'  # commit
.gp           # push
```

## usage

Most of dotGit is just some aliases that point to the `--git-dir` and `--work-tree`.

The real daily winners for me are the "edit" (`.ge`) and "grep" (`.gg`) aliases. They get me to where I need to be fast.

### a normal workflow for making configuration changes 

1. `.gl` - pull changes from origin
2. make some changes. Try:
    - `.ge zshrc` - presents all files with `zshrc` in the name
    - `.gg PATH` - runs `git grep` across your dotfiles and presents the results
3. `.gc -m 'commit comment' .zshrc` - will commit the changes
4. `.gp` - pushes the changes to the origin

### a list of all aliases defined


| alias | action | note |
| --- | --- | --- |
| .git | `git --git-dir=${DOT_REPO} --work-tree=${DOT_HOME}` | |
| .g | `.git` | |
| .ga | `.git add` | |
| .gc | `.git commit`  | |
| .gco | `.git checkout`  | |
| .gd | `.git diff` | |
| .gds | `.git diff --stat` | |
| .ge | calls the `_dotgit_ge` helper function | the dotGit edit feature [^fzf] |
| .gg | calls the `_dotgit_gg` helper function (falls back to `.git grep` without fzf) | grep your dotfiles and open at the matched line [^line] |
| .gss | `.git status --short` | |
| .glo | `.git log --oneline --decorate`  | |
| .glg | `.git log --stat`  | |
| .glgp | `.git log --stat --patch` | |
| .gbl | `.git blame -w` | |
| .gb | `.git branch` | |
| .gba | `.git branch --all` | |
| .gbd | `.git branch --delete` | |
| .gbD | `.git branch --delete --force` | |
| .gm | `.git merge` | |
| .gma | `.git merge --abort` | |
| .gmc | `.git merge --continue` | |
| .gc! | `.git commit --verbose --amend` | |
| .gcm | `.git commit --message` | |
| .gcp | `.git cherry-pick` | |
| .gcpa | `.git cherry-pick --abort` | |
| .gcpc | `.git cherry-pick --continue` | |
| .gclean | `.git clean --interactive -d` | |
| .gp | `.git push` | requires `DOT_ORIGIN` be set |
| .gl | `.git pull` | requires `DOT_ORIGIN` be set |
| .lazygit | `lazygit -g ${DOT_REPO}/ -w ${DOT_HOME}` | requires `lazygit` be installed |
| .gitui | `gitui -d ${DOT_REPO}/ -w ${DOT_HOME}` | requires gitui to be installed |
| .gclone | `git clone --bare "${DOT_ORIGIN}" "${DOT_REPO}"; .git config --local status.showUntrackedFiles no` | [^untracked] |
| .ginit | `git init --bare "${DOT_REPO}"; .git config --local status.showUntrackedFiles no`   |   |

[^line]: Opens the editor with `+line file` arguments. Works with vi, emacs, nano, micro, and any editor that accepts a line number via `+N`.
[^untracked]: Also set git's `status.showUntrackedFiles` to `no`. This prevents every file in `$DOT_HOME` from showing as "untracked" by git.
[^fzf]: requires [FZF](https://github.com/junegunn/fzf)

## requirements

- `EDITOR` set to your liking 
- [git](https://git-scm.com/)
- [bat](https://github.com/sharkdp/bat) (optional, default preview command)
- [fzf](https://github.com/junegunn/fzf) (optional)
- [lazygit](https://github.com/jesseduffield/lazygit) (optional)
- [gitui](https://github.com/extrawurst/gitui) (optional)

## installation

1. clone this repository or simply copy the [dotgit.sh](./dotgit.sh)
2. add some configuration sauce to your shell initialization (.i.e. `.zshrc` or `.bashrc`). The `DOT_REPO` and `DOT_HOME` variables **must be set** for the dotgit.sh to load!
  ```bash
  export DOT_REPO="${HOME}/.dotfiles"   # this is where the repo will live
  export DOT_HOME="${HOME}"             # this is generally the same as `$HOME`
  export DOT_ORIGIN="git@github.com:user/your-dotfiles-repo.git"   # optional
  source <path to dotGit.sh>
  ```
3. restart your shell or `source ~/.zshrc` or `source ~/.bashrc`
4. run `.ginit` to start a new repo, or `.gclone` to clone an existing one
    - if cloning: `.gco <branch>` to checkout your config files (see *initial clone cleanup* below if files conflict)
    - if initializing: start tracking files with `.ga`

## configuration

`DOT_REPO` and `DOT_HOME` must be set before sourcing `dotgit.sh`. All other variables are optional.

| variable | default | description |
| --- | --- | --- |
| `DOT_REPO` | *(required)* | path to the bare git repository |
| `DOT_HOME` | *(required)* | work tree root, usually `$HOME` |
| `DOT_ORIGIN` | *(unset)* | remote URL; enables `.gp`, `.gl`, and `.gclone` |
| `DOTGIT_PREVIEW` | `bat -p --color=always` | fzf preview command |
| `DOTGIT_MULTI_LIMIT` | `5` | max files selectable at once in `.ge` and `.gg` |
| `DOTGIT_OPEN_FMT` | `split` | how `.gg` passes file+line to the editor; `split` uses `+line file` (works with most editors); set to `+e {file}\|{line}` for vim/nvim multi-file line jumping |
| `DOTGIT_ANYGIT` | *(unset)* | set to `yes` to also load unprefixed `g*` aliases for any git repo |
| `DEBUG` | *(unset)* | set to any value to print load/unload messages |

### ANYGIT

Setting `DOTGIT_ANYGIT=yes` causes dotGit to source a transformed copy of itself that registers a parallel set of aliases without the leading `.` — so `.ga` becomes `ga`, `.gc` becomes `gc`, etc. These work against whichever git repo your shell is currently in, like ordinary git aliases.

## initial clone cleanup

Existing configuration files will prevent checking out the files. To list the files causing the checkout to fail, run the following.

```bash
.g checkout 2>&1|grep -E '^\s'|cut -f2-|xargs -I {} echo "{}"
```

To remove all the conflicting files, simply change the `echo` in the above command to `rm`. **This will delete files, so be sure you want to remove them.** Once the files are removed the checkout will succeed.

## future features

- command line completion
- manage system configuration files

## alternatives

- [GNU Stow](https://www.gnu.org/software/stow)
- [dotbare](https://github.com/kazhala/dotbare) (this is close in spirit to dotGit, and can be used together with dotGit from what I can tell)
- [Home Manager](https://github.com/nix-community/home-manager)
