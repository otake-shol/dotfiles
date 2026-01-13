# dotfiles

個人用の設定ファイル管理リポジトリ

## 🚀 クイックスタート

### 自動セットアップ（推奨）

新しいMacで最速セットアップ：

```bash
# リポジトリのクローン
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 自動セットアップスクリプトを実行
bash bootstrap.sh
```

これで以下が自動的に設定されます：
- Homebrewのインストール確認
- 必須アプリケーションのインストール
- dotfilesのシンボリックリンク作成
- Oh My Zsh + Powerlevel10kのセットアップ

### 手動セットアップ

最小限の手順で基本的な環境をセットアップします。

```bash
# 1. リポジトリのクローン
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Homebrewの確認（未インストールの場合はインストール）
which brew || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. アプリケーションのインストール
brew bundle --file=Brewfile  # 必須ツールのみ

# 4. 基本設定のシンボリックリンク作成
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.aliases ~/.aliases
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig

# 5. 設定の反映
source ~/.zshrc
```

---

## 📦 アプリケーション管理

このdotfilesでは、Homebrewを使用してアプリケーションを管理しています。

### インストール

```bash
# 必須ツールのみ（推奨）
cd ~/dotfiles
brew bundle --file=Brewfile

# 全ツール（開発環境完全再現）
brew bundle --file=Brewfile.full
```

### 新しいアプリの追加

**自動追加（推奨）:**

Claude Code の `dotfiles-manager` エージェントを使用：

```
"htop を dotfiles に追加して"
"Ice というアプリを必須ツールとして追加"
```

エージェントが自動で以下を実行します：
- Brewfile への追加
- docs/APPS.md の更新
- コミット

詳細は [docs/DOTFILES_MANAGER.md](docs/DOTFILES_MANAGER.md) を参照。

**手動追加:**

```bash
# 1. アプリをインストール
brew install <package-name>

# 2. Brewfile に追記
echo 'brew "<package-name>"' >> ~/dotfiles/Brewfile

# 3. Brewfile の更新
cd ~/dotfiles
./scripts/generate_brewfile.sh

# 4. コミット
git add Brewfile docs/APPS.md
git commit -m "Add <package-name>"
```

### 主なアプリケーション

- **ターミナル**: Ghostty
- **ユーティリティ**: Ice (メニューバー管理)
- **AI**: Claude CLI
- **Git**: git, gh, lazygit, git-secrets
- **エディタ**: Neovim, Vim
- **バージョン管理**: asdf, nvm, pyenv, tfenv

詳細は [docs/APPS.md](docs/APPS.md) を参照してください。

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
├── .aliases            # シェルエイリアス（94+個）
├── .zshrc              # Zsh設定
├── .vim/               # Vim設定
├── Brewfile            # 必須アプリケーション
├── Brewfile.full       # 全アプリケーション（バックアップ）
├── bootstrap.sh        # 自動セットアップスクリプト
├── .claude/            # Claude Code設定
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── agents/
│   │   ├── dotfiles-manager.md   # アプリ追加自動化エージェント
│   │   └── frontend-engineer.md
│   └── plugins/
├── antigravity/        # Antigravity設定
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt
├── cursor/             # Cursor設定
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.txt
├── docs/               # ドキュメント
│   ├── APPS.md         # アプリケーション一覧
│   ├── DOTFILES_MANAGER.md  # アプリ追加エージェントの使い方
│   └── SETUP.md        # 詳細セットアップ手順
├── gh/                 # GitHub CLI設定
│   └── config.yml
├── ghostty/            # Ghosttyターミナル設定
│   ├── config
│   └── shaders/
├── git/                # Git設定
│   └── .gitconfig
├── scripts/            # ヘルパースクリプト
│   └── generate_brewfile.sh
└── vscode/             # VS Code設定
    ├── settings.json
    └── extensions.txt
```

## 参考リンク

- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Ghostty](https://ghostty.org/)
