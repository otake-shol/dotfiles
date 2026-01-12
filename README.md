# dotfiles

個人用の設定ファイル管理リポジトリ

## 構成

```
dotfiles/
├── .aliases            # シェルエイリアス
├── .zshrc              # Zsh設定
├── .vim/               # Vim設定
│   ├── colors/
│   └── pack/
├── antigravity/        # Antigravity設定
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt
├── claude/             # Claude Code設定
│   ├── CLAUDE.md
│   └── settings.json
├── cursor/             # Cursor設定
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt
├── docker/             # Docker設定
│   └── config.json
├── fish/               # Fish shell設定
│   ├── config.fish
│   └── conf.d/
├── gh/                 # GitHub CLI設定
│   └── config.yml
├── ghostty/            # Ghosttyターミナル設定
│   ├── config
│   └── shaders/
├── git/                # Git設定
│   └── .gitconfig
├── nvim/               # Neovim設定
│   ├── init.vim
│   └── pack/
├── starship/           # Starshipプロンプト設定
│   └── starship.toml
├── vscode/             # VS Code設定
│   ├── settings.json
│   └── extensions.txt
└── oh-my-zsh-setup.md
```

## シンボリックリンク

このdotfilesを使用するには、以下のシンボリックリンクを作成してください。

### Shell
```bash
# Zsh
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.aliases ~/.aliases

# Fish
ln -sf ~/dotfiles/fish ~/.config/fish

# Starship
ln -sf ~/dotfiles/starship/starship.toml ~/.config/starship.toml
```

### Editors
```bash
# Vim
ln -sf ~/dotfiles/.vim ~/.vim

# Neovim
ln -sf ~/dotfiles/nvim ~/.config/nvim

# VS Code
ln -sf ~/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json

# Cursor
ln -sf ~/dotfiles/cursor/settings.json ~/Library/Application\ Support/Cursor/User/settings.json
ln -sf ~/dotfiles/cursor/keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json

# Antigravity
ln -sf ~/dotfiles/antigravity/settings.json ~/Library/Application\ Support/Antigravity/User/settings.json
ln -sf ~/dotfiles/antigravity/keybindings.json ~/Library/Application\ Support/Antigravity/User/keybindings.json

# Claude Code
ln -sf ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/dotfiles/claude/settings.json ~/.claude/settings.json
```

### Tools
```bash
# Git
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig

# GitHub CLI
ln -sf ~/dotfiles/gh/config.yml ~/.config/gh/config.yml

# Docker
ln -sf ~/dotfiles/docker/config.json ~/.docker/config.json

# Ghostty
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
ln -sf ~/dotfiles/ghostty/shaders ~/.config/ghostty/shaders
```

## セットアップ

```bash
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles
# 上記のシンボリックリンクコマンドを実行
```
