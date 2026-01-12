# dotfiles

個人用の設定ファイル管理リポジトリ

## 構成

```
dotfiles/
├── .aliases          # シェルエイリアス
├── .zshrc            # Zsh設定
├── claude/           # Claude Code設定
│   ├── CLAUDE.md     # ユーザー指示
│   └── settings.json # 設定
├── antigravity/      # Antigravity (VS Code系) 設定
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt  # 拡張機能リスト
├── git/              # Git設定
│   └── .gitconfig
├── ghostty/          # Ghosttyターミナル設定
│   ├── config
│   └── shaders/
│       └── bloom.glsl
└── oh-my-zsh-setup.md  # Oh My Zshセットアップ手順
```

## シンボリックリンク

このdotfilesを使用するには、以下のシンボリックリンクを作成してください。

### Zsh
```bash
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.aliases ~/.aliases
```

### Claude Code
```bash
ln -sf ~/dotfiles/claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/dotfiles/claude/settings.json ~/.claude/settings.json
```

### Antigravity
```bash
ln -sf ~/dotfiles/antigravity/settings.json ~/Library/Application\ Support/Antigravity/User/settings.json
ln -sf ~/dotfiles/antigravity/keybindings.json ~/Library/Application\ Support/Antigravity/User/keybindings.json
```

### Git
```bash
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
```

### Ghostty
```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
ln -sf ~/dotfiles/ghostty/shaders ~/.config/ghostty/shaders
```

## セットアップ

```bash
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
# 上記のシンボリックリンクコマンドを実行
```
