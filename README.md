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

詳細な手動セットアップ手順は [docs/SETUP.md](docs/SETUP.md) を参照してください。

---

## 📦 アプリケーション管理

Homebrewを使用してアプリケーションを管理しています。

### インストール

```bash
# 必須ツールのみ（推奨）
cd ~/dotfiles
brew bundle --file=Brewfile

# 全ツール（開発環境完全再現）
brew bundle --file=Brewfile.full
```

### 主なアプリケーション

- **ターミナル**: Ghostty
- **ユーティリティ**: AltTab, Homerow, Ice, Raycast
- **ブラウザ**: Arc
- **生産性**: Spark（メール）, TickTick（タスク管理）
- **開発**: Claude CLI, Git, Neovim
- **シェルツール**: fzf, zoxide, sheldon

詳細は [docs/APPS.md](docs/APPS.md) を参照してください。

### 新しいアプリの追加

**自動追加（推奨）:**

Claude Code の `dotfiles-manager` エージェントを使用：

```
"htop を dotfiles に追加して"
"Ice というアプリを必須ツールとして追加"
```

詳細は [docs/DOTFILES_MANAGER.md](docs/DOTFILES_MANAGER.md) を参照。

**手動追加:**

```bash
# 1. アプリをインストールして Brewfile に追記
brew install <package-name>
echo 'brew "<package-name>"' >> ~/dotfiles/Brewfile

# 2. 変更をコミット
cd ~/dotfiles
git add Brewfile docs/APPS.md
git commit -m "Add <package-name>"
```

---

## 🌐 ブラウザ拡張機能管理

ブラウザ拡張機能のリストを管理しています：

- **Arc**: [browser-extensions/arc.md](browser-extensions/arc.md)
- **Chrome**: [browser-extensions/chrome.md](browser-extensions/chrome.md)
- **Firefox**: [browser-extensions/firefox.md](browser-extensions/firefox.md)

詳細な管理方法は [docs/BROWSER_EXTENSIONS.md](docs/BROWSER_EXTENSIONS.md) を参照。

---

## 📁 主な設定ファイル

### シェル設定
- `.zshrc` - Zsh設定（Oh My Zsh + 16プラグイン）
- `.aliases` - エイリアス設定（94+個）

### アプリケーション設定
- `Brewfile` - 必須アプリケーション
- `Brewfile.full` - 全アプリケーション（バックアップ）
- `bootstrap.sh` - 自動セットアップスクリプト

### エディタ設定
- `.claude/` - Claude Code設定（エージェント含む）
- `antigravity/` - Antigravity設定
- `cursor/` - Cursor設定
- `vscode/` - VS Code設定

### 開発ツール設定
- `git/.gitconfig` - Git設定
- `gh/config.yml` - GitHub CLI設定
- `ghostty/` - Ghosttyターミナル設定

### ブラウザ拡張
- `browser-extensions/` - ブラウザ拡張機能リスト

### ドキュメント
- `docs/APPS.md` - アプリケーション一覧
- `docs/SETUP.md` - 詳細セットアップ手順
- `docs/DOTFILES_MANAGER.md` - アプリ追加エージェントの使い方
- `docs/BROWSER_EXTENSIONS.md` - ブラウザ拡張機能管理ガイド

---

## 🔧 構成

```
dotfiles/
├── .aliases              # エイリアス（94+個）
├── .zshrc                # Zsh設定
├── Brewfile              # 必須アプリ
├── Brewfile.full         # 全アプリ
├── bootstrap.sh          # 自動セットアップ
├── .claude/              # Claude Code設定
├── browser-extensions/   # ブラウザ拡張リスト
├── docs/                 # ドキュメント
├── git/                  # Git設定
├── ghostty/              # ターミナル設定
└── scripts/              # ヘルパースクリプト
```

完全な構成は [docs/SETUP.md](docs/SETUP.md) を参照してください。

---

## 📚 ドキュメント

- **[APPS.md](docs/APPS.md)** - インストール済みアプリケーション一覧
- **[SETUP.md](docs/SETUP.md)** - 詳細セットアップ手順
- **[DOTFILES_MANAGER.md](docs/DOTFILES_MANAGER.md)** - アプリ自動追加エージェント
- **[BROWSER_EXTENSIONS.md](docs/BROWSER_EXTENSIONS.md)** - ブラウザ拡張管理ガイド

---

## 🔗 参考リンク

### ツール・ライブラリ

- [Homebrew](https://brew.sh/) - macOSパッケージマネージャー
- [Oh My Zsh](https://ohmyz.sh/) - Zsh設定フレームワーク
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Zshテーマ
- [Nerd Fonts](https://www.nerdfonts.com/) - アイコン付きフォント
- [Ghostty](https://ghostty.org/) - GPUアクセラレーションターミナル

### 参考動画

- [dotfiles管理の参考動画](https://www.youtube.com/watch?v=qJjg4A_5AZw&t=857s) - このdotfiles構成の参考にした動画
