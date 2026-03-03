# dotGit — .gg and .ge demo

Output demo/demo.gif

Set Shell zsh
Set Width 1200
Set Height 450
Set FontSize 16
Set TypingSpeed 100ms

Sleep 1s

Hide
Type "export DOT_REPO=$HOME/.dotfiles DOT_HOME=$HOME && source /home/matthias/Code/dotGit/dotgit.sh"
Enter
Sleep 500ms
Show

# .gg — grep your dotfiles and jump to the line
Hide
Type "./demo/demo-note.sh 'Search your dotfiles for PATH'"
Enter
Sleep 500ms
Show
Sleep 3s

Type "EDITOR=nano .gg PATH"
Sleep 1500ms
Enter
Sleep 3000ms

Screenshot screenshot.png
Sleep 1500ms

Down
Sleep 1500ms
Down
Sleep 1500ms
Down
Sleep 1500ms
Down
Sleep 1500ms
Up
Sleep 1200ms
Up
Sleep 1200ms
Enter
Sleep 2000ms

Ctrl+X
Sleep 2500ms

# .ge — fuzzy find and edit
Hide
Type "./demo/demo-note.sh 'Fuzzy find and edit your dotfiles'"
Enter
Sleep 500ms
Show
Sleep 3s

Type "EDITOR=nano .ge"
Sleep 1500ms
Enter
Sleep 3000ms
Down
Sleep 1200ms
Down
Sleep 1200ms
Down
Sleep 1200ms
Up
Sleep 1000ms
Type "zshrc"
Sleep 2000ms
Down
Sleep 1200ms
Enter
Sleep 2000ms

Ctrl+X
Sleep 1500ms
