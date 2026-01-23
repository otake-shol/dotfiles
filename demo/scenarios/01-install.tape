# VHS Demo - Installation Process
# Shows the bootstrap process

Output demo/scenarios/01-install.gif
Set FontSize 14
Set Width 1000
Set Height 600
Set Theme "Dracula"
Set TypingSpeed 40ms
Set Shell "zsh"

Type "# dotfiles Installation Demo"
Enter
Sleep 1s

Type "# Step 1: Clone the repository"
Enter
Sleep 500ms
Type "git clone https://github.com/YOUR_USERNAME/dotfiles ~/dotfiles"
Enter
Sleep 1.5s

Type "# Step 2: Run bootstrap"
Enter
Type "cd ~/dotfiles"
Enter
Sleep 500ms
Type "bash bootstrap.sh --dry-run"
Enter
Sleep 3s

Type "# Step 3: Verify setup"
Enter
Type "bash scripts/maintenance/verify-setup.sh"
Enter
Sleep 3s

Type "# ✅ Installation complete!"
Enter
Sleep 2s
