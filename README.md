# dotGit ::: 🪄 dotfiles +  🧸 bare git repo + 🐚 shell aliases

There are a lot of ways to manage your dotfiles. dotGit implements an idea that has been floating around on the internet for a while: a bare git repo for storing your dotfiles. A quick search finds [this post](https://news.ycombinator.com/item?id=11070797), but there may be older sources. dotGit combines this with some convenient shell aliases, a couple of functions, and FZF's matching magic to track your dotfiles files with ease.

dotGit has modest aims:
- 🏡 keep configuration files where tools expect them in `$HOME`
- 🐚 stay as light and close to git and the shell as possible
- 🚀 reduce friction and make configuration changes quick and convenient


## usage

Most of dotGit is just some aliases that point to the `--git-dir` and `--work-tree`.

The real daily winners for me are the "edit" (`.ge`) and "grep" (`.gg`) aliases. They get me to where I need to be fast.

### a normal workflow for making configuration changes 

1. `.gl` - pull changes from origin
2. make some changes. Try:
    - `.ge zshrc` - presents all files with `zshrc` in the name
    - `.gg PATH` - runs `git grep` across your dotfiles and presents the results
4. `.gc -m 'commit comment' .zshrc` - will commit the changes
5. `.gp` - pushes the changes to the origin

### a list of all aliases defined


| alias | action | note |
| --- | --- | --- |
| .git | `git --git-dir=${DOT_REPO} --work-tree=${DOT_HOME}` | |
| .g | `.git` | |
| .ga | `.git add` | |
| .gc | `.git commit`  | |
| .gco | `.git checkout`  | |
| .gd | `.git diff` | |
| .ge | calls the `_dotgit_ge` helper function | the dotGit edit feature [^fzf] |
| .gg | calls the `_dotgit_gg` helper function | grep your dotfiles, and jump to correct line [^line] |
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
| .gc! | `.git commit --verbose --amend` | 
| .gcm | `.git commit --message` | |
| .gcp | `.git cherry-pick` | |
| .gcpa | `.git cherry-pick --abort` | |
| .gcpc | `.git cherry-pick --continue` | |
| .gclean | `.git clean --interactive -d` | |
| .ginit | `git init --bare "${DOT_REPO}"; .git config --local status.showUntrackedFiles no` | [^untracked] |
| .gp | `.git push` | requires `DOT_ORIGIN` be set |
| .gl | `.git pull` | requires `DOT_ORIGIN` be set 
| .gclone | `git clone --bare "${DOT_ORIGIN}" "${DOT_REPO}"; .git config --local status.showUntrackedFiles no` | |
| .lazygit | `lazygit -g ${DOT_REPO}/ -w ${DOT_HOME}` | requires `lazygit` be installed |
| .gitui | `gitui -d ${DOT_REPO}/ -w ${DOT_HOME}` | requires gitui to be installed |

[^line]: This works with vi, emacs, nano, micro, and any editor that accepts the line number to open the file to.
[^untracked]: Also set git's `status.showUntrackedFiles` to `no`. This prevents every file in `$DOT_HOME` from showing as "untracked" by git.
[^fzf]: requires [FZF](https://github.com/junegunn/fzf)

## requirements

- `EDITOR` set to your liking 
- [git](https://git-scm.com/)
- [bat](https://github.com/sharkdp/bat)
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
  source <path to dotGit.sh>`
  ```
3. restart your shell or `source ~/.zshrc` or `source ~/.bashrc`
4. run `.ginit` or `.gclone` (see the *initial clone setup* below, if cloning)
5. `.gc <branch>` to checkout the config files


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
