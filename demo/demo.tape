# dotGit — .gg and .ge demo

Output demo/demo.gif

Set Shell zsh
Set Width 1200
Set Height 450
Set FontSize 16
Set TypingSpeed 50ms

Sleep 500ms

Hide
Type "export DOT_REPO=$HOME/.dotfiles DOT_HOME=$HOME && source ./dotgit.sh"
Enter
Sleep 300ms
Show

# configure dotGit
Hide
Type "./demo/demo-note.sh 'Configure dotGit'"
Enter
Sleep 300ms
Show
Sleep 2s

Type "EDITOR=nvim"
Sleep 800ms
Enter
Type "DOT_REPO=$HOME/.dotfiles"
Sleep 800ms
Enter
Type "DOT_HOME=$HOME"
Sleep 800ms
Enter
Type "source ./dotgit.sh"
Enter

Screenshot demo/configure.png
Sleep 500ms

Sleep 2s


# .gg — grep your dotfiles and jump to the line
Hide
Type "./demo/demo-note.sh 'Search your dotfiles for PATH'"
Enter
Sleep 300ms
Show
Sleep 2s

Type ".gg PATH"
Sleep 800ms
Enter
Sleep 2s

Screenshot demo/gg.png
Sleep 500ms

Down
Sleep 400ms
Down
Sleep 400ms
Down
Sleep 400ms
Down
Sleep 400ms
Up
Sleep 300ms
Up
Sleep 300ms
Enter
Sleep 4s

Type ":q!"
Enter
Sleep 800ms

# .ge — fuzzy find and edit
Hide
Type "./demo/demo-note.sh 'Fuzzy find and edit your dotfiles'"
Enter
Sleep 300ms
Show
Sleep 2s

Type ".ge"
Sleep 800ms
Enter
Sleep 2s

Screenshot demo/ge.png
Sleep 500ms

Down
Sleep 400ms
Down
Sleep 400ms
Down
Sleep 400ms
Up
Sleep 300ms
Type "zshrc"
Sleep 1s
Down
Sleep 400ms
Enter
Sleep 4s

Type ":q!"
Enter
Sleep 800ms
