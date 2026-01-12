# dotfiles

個人用の設定ファイル管理リポジトリ

## セットアップガイド（ハンズオン）

このガイドに従って、ゼロから開発環境をセットアップしていきます。

### Step 1: リポジトリのクローン

```bash
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Step 2: Homebrewのインストール

Homebrewがインストールされていない場合は、まずインストールします。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 3: Oh My Zsh + Powerlevel10kのセットアップ

> 参考: https://zenn.dev/collabostyle/articles/6d668b46627d64

#### 3-1. Oh My Zshのインストール

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

実行後、`~/.zshrc` が自動生成されます。

#### 3-2. Nerd Fontのインストール

Powerlevel10kの正しい表示にはNerd Font対応フォントが必要です。

**Homebrewでインストール（推奨）:**

```bash
brew install --cask font-meslo-lg-nerd-font
```

**手動でインストール:**

1. [Nerd Fonts Releases](https://github.com/ryanoasis/nerd-fonts/releases/latest) にアクセス
2. Assetsから `Meslo.zip` をダウンロード
3. 解凍して以下の4つのフォントをインストール:
   - MesloLGSNerdFont-Regular.ttf
   - MesloLGSNerdFont-Bold.ttf
   - MesloLGSNerdFont-Italic.ttf
   - MesloLGSNerdFont-BoldItalic.ttf

**フォントの設定:**

ターミナル（GhosttyやiTerm2など）のフォント設定を「MesloLGS Nerd Font」に変更してください。

#### 3-3. Powerlevel10kのインストール

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

#### 3-4. Zshプラグインのインストール

```bash
# zsh-autosuggestions（コマンド履歴から自動補完）
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting（コマンドの色分け表示）
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

**プラグインの説明:**

| プラグイン | 説明 |
|-----------|------|
| git | Gitの補完とエイリアス |
| z | よく使うディレクトリへの高速移動 |
| colored-man-pages | manページのカラー表示 |
| zsh-autosuggestions | 過去のコマンド履歴から自動補完を提案 |
| zsh-syntax-highlighting | 入力中のコマンドを色分け表示 |

#### 3-5. dotfilesの.zshrcをシンボリックリンク

```bash
# 元の.zshrcをバックアップ（必要に応じて）
mv ~/.zshrc ~/.zshrc.backup

# dotfilesの.zshrcをシンボリックリンク
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.aliases ~/.aliases
```

このdotfilesの`.zshrc`には、以下の設定が既に含まれています：
- `ZSH_THEME="powerlevel10k/powerlevel10k"`
- プラグインの有効化（git、z、colored-man-pages、zsh-autosuggestions、zsh-syntax-highlighting）

#### 3-6. 設定の反映

```bash
source ~/.zshrc
```

または新しいターミナルを開きます。初回起動時、Powerlevel10kのセットアップウィザードが起動します。

### Step 4: ターミナルのインストール

```bash
# Ghostty（高速でモダンなターミナル）
brew install --cask ghostty
```

Ghosttyの設定ファイルをシンボリックリンク:

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
ln -sf ~/dotfiles/ghostty/shaders ~/.config/ghostty/shaders
```

### Step 5: Fish Shellのインストール（オプション）

```bash
# Fish shell
brew install fish
```

Fishの設定をシンボリックリンク:

```bash
# Fish
ln -sf ~/dotfiles/fish ~/.config/fish
```

### Step 6: エディタのインストール

```bash
# VS Code
brew install --cask visual-studio-code

# Cursor
brew install --cask cursor

# Antigravity
brew install --cask antigravity

# Claude Code CLI
brew install claude
```

エディタの設定をシンボリックリンク:

```bash
# VS Code
ln -sf ~/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json

# Cursor
ln -sf ~/dotfiles/cursor/settings.json ~/Library/Application\ Support/Cursor/User/settings.json
ln -sf ~/dotfiles/cursor/keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json

# Antigravity
ln -sf ~/dotfiles/antigravity/settings.json ~/Library/Application\ Support/Antigravity/User/settings.json
ln -sf ~/dotfiles/antigravity/keybindings.json ~/Library/Application\ Support/Antigravity/User/keybindings.json

# Claude Code
ln -sf ~/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/dotfiles/.claude/settings.json ~/.claude/settings.json
ln -sf ~/dotfiles/.claude/agents ~/.claude/agents
ln -sf ~/dotfiles/.claude/plugins ~/.claude/plugins
```

### Step 7: 開発ツールのインストール

```bash
# Git（最新版）
brew install git

# git-secrets（AWS認証情報の誤コミット防止）
brew install git-secrets

# GitHub CLI
brew install gh

# Docker Desktop
brew install --cask docker
```

開発ツールの設定をシンボリックリンク:

```bash
# Git
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig

# GitHub CLI
mkdir -p ~/.config/gh
ln -sf ~/dotfiles/gh/config.yml ~/.config/gh/config.yml

# Docker
mkdir -p ~/.docker
ln -sf ~/dotfiles/docker/config.json ~/.docker/config.json
```

git-secretsの初期設定:

```bash
git secrets --install ~/.git-templates/git-secrets
git secrets --register-aws --global
```

### Step 8: バージョン管理ツールのインストール

```bash
# asdf（複数言語のバージョン管理）
brew install asdf

# nvm（Node.jsバージョン管理）
brew install nvm
```

nvmの設定（`.zshrc`で既に設定済み）:

```bash
mkdir -p ~/.nvm
```

### 完了！

これで開発環境のセットアップが完了しました。新しいターミナルを開いて動作を確認してください。

## 構成ファイル一覧

```
dotfiles/
├── .aliases            # シェルエイリアス
├── .zshrc              # Zsh設定
├── .claude/            # Claude Code設定
│   ├── CLAUDE.md
│   ├── settings.json
│   ├── settings.local.json
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
└── vscode/             # VS Code設定
    ├── settings.json
    └── extensions.txt
```
