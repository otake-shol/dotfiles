# セットアップガイド

新しいMacをセットアップする際の詳細な手順です。

## 🚀 クイックスタート

最速で環境を構築したい場合：

```bash
# 1. リポジトリのクローン
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. 自動セットアップスクリプトを実行
bash bootstrap.sh
```

これだけで基本的な環境が整います。

---

## 📋 手動セットアップ

各ステップを個別に実行したい場合の詳細手順です。

### Step 1: Homebrewのインストール

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2: dotfilesのクローン

```bash
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Step 3: アプリケーションのインストール

#### 必須ツールのみ（推奨）
```bash
brew bundle --file=Brewfile
```

#### 全ツール
```bash
brew bundle --file=Brewfile.full
```

### Step 4: dotfilesのシンボリックリンク作成

#### Zsh設定
```bash
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.aliases ~/.aliases
```

#### Git設定
```bash
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
```

#### Ghosttyターミナル設定
```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
ln -sf ~/dotfiles/ghostty/shaders ~/.config/ghostty/shaders
```

#### Vim設定（存在する場合）
```bash
ln -sf ~/dotfiles/.vim ~/.vim
```

#### Claude Code設定
```bash
mkdir -p ~/.claude
ln -sf ~/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/dotfiles/.claude/settings.json ~/.claude/settings.json
ln -sf ~/dotfiles/.claude/agents ~/.claude/agents
ln -sf ~/dotfiles/.claude/plugins ~/.claude/plugins
```

#### GitHub CLI設定
```bash
mkdir -p ~/.config/gh
ln -sf ~/dotfiles/gh/config.yml ~/.config/gh/config.yml
```

#### エディタ設定（VS Code, Cursor, Antigravity）
詳細はREADME.mdの「詳細セットアップ手順」セクションを参照してください。

### Step 5: Oh My Zshのセットアップ

#### Oh My Zshインストール
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Powerlevel10kテーマ
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

#### Zshプラグイン
```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

#### Nerd Fontのインストール
```bash
brew install --cask font-meslo-lg-nerd-font
```

ターミナルのフォント設定を「MesloLGS Nerd Font」に変更してください。

### Step 6: 設定の反映

```bash
source ~/.zshrc
# または
exec zsh
```

初回起動時、Powerlevel10kのセットアップウィザードが起動します。

### Step 7: 追加設定

#### nvm設定
```bash
mkdir -p ~/.nvm
```

#### git-secrets設定
```bash
git secrets --install ~/.git-templates/git-secrets
git secrets --register-aws --global
```

---

## 🔧 カスタマイズ

### Brewfileの更新

現在インストールされているアプリケーションをBrewfileに保存：

```bash
cd ~/dotfiles
brew bundle dump --force --file=Brewfile.full
```

### 新しいアプリの追加

1. アプリをインストール
   ```bash
   brew install <package-name>
   ```

2. Brewfileに追記
   ```bash
   echo 'brew "<package-name>"' >> ~/dotfiles/Brewfile
   ```

3. コミット
   ```bash
   cd ~/dotfiles
   git add Brewfile
   git commit -m "Add <package-name>"
   git push
   ```

---

## 🐛 トラブルシューティング

### Homebrewのパスが通らない

Apple Silicon Mac の場合：
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Intel Mac の場合：
```bash
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/usr/local/bin/brew shellenv)"
```

### Oh My Zshのテーマが表示されない

1. Nerd Fontがインストールされているか確認
   ```bash
   brew list --cask | grep nerd-font
   ```

2. ターミナルのフォント設定を確認
   - Ghostty: `~/.config/ghostty/config` の `font-family` 設定
   - iTerm2: Preferences → Profiles → Text → Font

### シンボリックリンクエラー

既存の設定ファイルが存在する場合：
```bash
# バックアップを作成
mv ~/.zshrc ~/.zshrc.backup

# 再度リンク作成
ln -sf ~/dotfiles/.zshrc ~/.zshrc
```

### brew bundle install が失敗する

```bash
# Homebrewを最新に更新
brew update
brew upgrade

# 再度インストール
brew bundle --file=Brewfile
```

---

## 📚 参考リンク

- [Homebrew](https://brew.sh/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Ghostty](https://ghostty.org/)

---

## ✅ チェックリスト

新しいMacのセットアップ後、以下を確認してください：

- [ ] Homebrewがインストールされている (`brew --version`)
- [ ] Oh My Zshがインストールされている (`ls ~/.oh-my-zsh`)
- [ ] Powerlevel10kテーマが適用されている
- [ ] Nerd Fontが設定されている
- [ ] Git設定が反映されている (`git config --list`)
- [ ] GitHub CLIにログインしている (`gh auth status`)
- [ ] エイリアスが動作している (`alias`)
- [ ] nvmが動作している (`nvm --version`)
- [ ] asdfが動作している (`asdf --version`)
