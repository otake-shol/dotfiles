# Brewfile - 必須ツールのみ
# 新しいMacをセットアップする際に最低限必要なツールを記載
# 完全な環境は Brewfile.full を参照

# ========================================
# Taps
# ========================================
tap "homebrew/cask-versions"

# ========================================
# CLI Tools (必須)
# ========================================

# Git関連
brew "git"
brew "gh"              # GitHub CLI
brew "git-secrets"     # AWS認証情報の誤コミット防止
brew "lazygit"         # Git TUI

# バージョン管理
brew "asdf"            # 複数言語のバージョン管理
brew "nvm"             # Node.jsバージョン管理

# エディタ
brew "neovim"          # モダンなVim
brew "vim"

# シェル・ターミナル
brew "tmux"            # ターミナルマルチプレクサ
brew "fzf"             # ファジーファインダー
brew "starship"        # クロスシェルプロンプト

# ユーティリティ
brew "stow"            # シンボリックリンク管理
brew "tree"            # ディレクトリツリー表示
brew "btop"            # システムモニター
brew "curl"            # HTTPクライアント
brew "wget"            # ダウンローダー

# セキュリティ
brew "gnupg"           # GPG暗号化

# ========================================
# GUI Applications (必須)
# ========================================

# ターミナル
cask "ghostty"         # 高速でモダンなターミナル

# ユーティリティ
cask "alt-tab"         # Windows風のタスクスイッチャー
cask "jordanbaird-ice" # メニューバー管理
cask "raycast"         # 生産性向上ランチャー

# ブラウザ
cask "arc"             # モダンなChromiumベースブラウザ

# 生産性
cask "readdle-spark"   # メールクライアント
cask "ticktick"        # ToDoリスト・タスク管理

# コミュニケーション
cask "slack"           # チームコミュニケーション

# デザイン
cask "figma"           # デザインツール・プロトタイピング

# AI・開発
cask "claude"          # Claude CLI

# フォント
cask "font-hack-nerd-font"
cask "font-jetbrains-mono-nerd-font"

# ========================================
# オプション：開発環境
# ========================================
# 必要に応じてコメントアウトを外してインストール

# brew "node"
# brew "python@3.13"
# brew "php"
# brew "composer"
# brew "mysql"
# brew "postgresql@14"
# brew "docker"
