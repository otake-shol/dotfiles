# dotfiles

個人用の設定ファイル管理リポジトリ

## クイックスタート

最小限の手順で基本的な環境をセットアップします。

```bash
# 1. リポジトリのクローン
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Homebrewの確認（未インストールの場合はインストール）
which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. 基本設定のシンボリックリンク作成
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.aliases ~/.aliases
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig

# 4. 設定の反映
source ~/.zshrc
```

これで基本的な環境が整います。より詳細なセットアップは以下の手順を参照してください。

---

## 詳細セットアップ手順

### 1. Oh My Zsh + Powerlevel10k

より見やすく使いやすいターミナル環境を構築します。

**1-1. Oh My Zshのインストール**

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

**1-2. Nerd Fontのインストール**

```bash
brew install --cask font-meslo-lg-nerd-font
```

インストール後、ターミナルのフォント設定を「MesloLGS Nerd Font」に変更してください。

**1-3. Powerlevel10kとプラグインのインストール**

```bash
# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

**1-4. 設定の反映**

```bash
source ~/.zshrc
```

初回起動時、Powerlevel10kのセットアップウィザードが起動します。

### 2. ターミナル

**Ghosttyのインストールと設定**

```bash
# インストール
brew install --cask ghostty

# 設定ファイルのシンボリックリンク
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
ln -sf ~/dotfiles/ghostty/shaders ~/.config/ghostty/shaders
```

### 3. エディタ

**VS Code**

```bash
brew install --cask visual-studio-code
ln -sf ~/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
```

**Cursor**

```bash
brew install --cask cursor
ln -sf ~/dotfiles/cursor/settings.json ~/Library/Application\ Support/Cursor/User/settings.json
ln -sf ~/dotfiles/cursor/keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json
```

**Antigravity**

```bash
brew install --cask antigravity
ln -sf ~/dotfiles/antigravity/settings.json ~/Library/Application\ Support/Antigravity/User/settings.json
ln -sf ~/dotfiles/antigravity/keybindings.json ~/Library/Application\ Support/Antigravity/User/keybindings.json
```

**Claude Code CLI**

```bash
brew install claude
ln -sf ~/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/dotfiles/.claude/settings.json ~/.claude/settings.json
ln -sf ~/dotfiles/.claude/agents ~/.claude/agents
ln -sf ~/dotfiles/.claude/plugins ~/.claude/plugins
```

### 4. 開発ツール

**Git**

```bash
brew install git
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
```

**GitHub CLI**

```bash
brew install gh
mkdir -p ~/.config/gh
ln -sf ~/dotfiles/gh/config.yml ~/.config/gh/config.yml
```

**git-secrets（AWS認証情報の誤コミット防止）**

```bash
brew install git-secrets
git secrets --install ~/.git-templates/git-secrets
git secrets --register-aws --global
```

### 5. バージョン管理ツール

**asdf（複数言語のバージョン管理）**

```bash
brew install asdf
```

**nvm（Node.jsバージョン管理）**

```bash
brew install nvm
mkdir -p ~/.nvm
```

nvmの設定は`.zshrc`で既に設定済みです。

## 構成ファイル一覧

```
dotfiles/
├── .aliases            # シェルエイリアス
├── .zshrc              # Zsh設定
├── .claude/            # Claude Code設定
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── agents/
│   └── plugins/
├── antigravity/        # Antigravity設定
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt
├── cursor/             # Cursor設定
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt
├── gh/                 # GitHub CLI設定
│   └── config.yml
├── ghostty/            # Ghosttyターミナル設定
│   ├── config
│   └── shaders/
├── git/                # Git設定
│   └── .gitconfig
└── vscode/             # VS Code設定
    ├── settings.json
    └── extensions.txt
```

## 参考リンク

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Ghostty](https://ghostty.org/)
