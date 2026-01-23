# VHS Demo - dotfiles Overview
# https://github.com/charmbracelet/vhs
#
# 使用方法: vhs demo/demo.tape

# 出力設定
Output demo/demo.gif
Set FontSize 16
Set Width 1200
Set Height 800
Set Theme "Dracula"
Set Padding 20

# シェル設定
Set Shell "zsh"
Set TypingSpeed 50ms

# タイトル
Type "# 🏠 dotfiles - World-Class Development Environment"
Enter
Sleep 1s

# セットアップ
Type "# Quick Install"
Enter
Sleep 500ms
Type "git clone https://github.com/YOUR_USERNAME/dotfiles ~/dotfiles"
Sleep 1s
Enter
Type "cd ~/dotfiles && bash bootstrap.sh"
Sleep 2s
Enter

# シェル機能デモ
Sleep 1s
Type "# Modern CLI Tools"
Enter
Sleep 500ms

# ファイル一覧 (eza)
Type "ll"
Enter
Sleep 2s

# ファイル検索 (fd + fzf)
Type "# Fuzzy file finder"
Enter
Type "fvim"
Sleep 1s
Enter
Sleep 2s
Escape

# Git操作 (fzf + git)
Type "# Git branch selector"
Enter
Type "fbr"
Sleep 1s
Enter
Sleep 2s
Escape

# ディレクトリジャンプ (zoxide)
Type "# Smart directory jump"
Enter
Type "z dotfiles"
Enter
Sleep 1s

# 完了
Type "# 🎉 That's it! Your terminal is now supercharged!"
Enter
Sleep 2s
