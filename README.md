# dotGit - 🐚 shell aliases + 🪄 dotfiles +  🧸 bare git repo 

There are a lot of ways to manage your dotfiles. dotGit implements an idea that has been floating around on the internet for a while: a bare git repo for storing your dotfiles. A quick search finds [this post](https://news.ycombinator.com/item?id=11070797), but there may be older sources.

dotGit has modest aims:
- 🏡 keep config files where tools expect them in `$HOME`
- 🐚 stay as light and close to git and the shell as possible
- 🚀 reduce friction and make config changes quick and convenient

dotGit gives you a handful of shell aliases (tested with `zsh`🐚 and `bash`) to make dotfile management quick and easy. The shortcuts mimic a subset of those found in the [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) [git](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git) plugin.

- `.g` is the alias for running `git` with correct `--git-dir` and `--work-tree`
- `.ga` runs `git add`
- `.gc` runs `git commmit`
- `.gco` runs `git checkout`
- `.gd` runs `git diff`
- `.gss` shows the `git status --short`
- `.gp` will `git push` the changes to the origin
- `.gl` will `git pull` changes from the origin
- `.glo` runs `git log --oneline --decorate `
- `.glg` runs `git log --stat`
- `.glgp` runs `git log --stat --patch`
- `.gg` runs `git grep` on your dotfiles. If [FZF](https://github.com/junegunn/fzf) is installed it will be used to present the matches, and make it easy open your `$EDITOR` on the right line (works with vi, emacs, nano, micro, and any editor that accepts the `+<number>` syntax to indicate the line number).
- `.ge` (requires [FZF](https://github.com/junegunn/fzf)) lists all files using FZF and opens the selected file in your  `$EDITOR`
- `.lazygit` (requires [lazygit](https://github.com/jesseduffield/lazygit)) will run `lazygit` with the correct `-g` and `-w`
- `.gitui` (requires [gitui](https://github.com/extrawurst/gitui)) will run `gitui` with the correct `-d` and `-w`

There are two additional aliases used to (re)set up the bare git setup.
- `.ginit` creates the bare git repository in `$DOT_FILES` directory.
- `.gclone` will clone the repository set in `$DOT_ORIGIN` into the `$DOT_FILES` directory
Both of these aliases also set git's `status.showUntrackedFiles` to `no`. This prevents every file in `$DOT_HOME` from showing as "untracked" by git.

## requirements

- `EDITOR` set to your liking 
- [git](https://git-scm.com/)
- [bat](https://github.com/sharkdp/bat)
- [fzf](https://github.com/junegunn/fzf) (optional)
- [lazygit](https://github.com/jesseduffield/lazygit) (optional)
- [gitui](https://github.com/extrawurst/gitui) (optional)

## installation

1. clone this repository or simply copy the [dotGit.sh](./dotGit.sh)
2. add some config sauce to your shell initialization (.i.e. `.zshrc` or `.bashrc`). The `DOT_FILES` and `DOT_HOME` variables **must be set** for the dotGit.sh to load!
  ```bash
  export DOT_FILES="${HOME}/.dotfiles"
  export DOT_HOME="${HOME}"
  export DOT_ORIGIN="git@github.com:user/your-dotfiles-repo.git" # optional
  source <path to dotGit.sh>`
  ```
3. restart your shell or `source ~/.zshrc` or `source ~/.bashrc`
4. run `.ginit` or `.gclone` (see the *initial clone setup* below, if cloning)
5. `.gc <branch>` to checkout the config files


## initial clone cleanup

Existing config files will prevent checking out the files. To list the files causing the checkout to fail, run the following.

```bash
.g checkout 2>&1|grep -E '^\s'|cut -f2-|xargs -I {} echo "{}"
```

To remove all the conflicting files, simply change the `echo` in the above command to `rm`. **This will delete files, so be sure you want to remove them.** Once the files are removed the checkout will succeed.


## alternatives

- [GNU Stow](https://www.gnu.org/software/stow)
- [dotbare](https://github.com/kazhala/dotbare) (this is close in spirit to dotGit, and can be used together with dotGit from what I can tell)
- [Home Manager](https://github.com/nix-community/home-manager)
