# Brewfile - 必須ツールのみ
# 新しいMacをセットアップする際に最低限必要なツールを記載
# 完全な環境は Brewfile.full を参照

# Taps
tap "oven-sh/bun"      # bun用

# ========================================
# CLI Tools (必須)
# ========================================

# Git関連
brew "git"
brew "gh"              # GitHub CLI
brew "git-secrets"     # AWS認証情報の誤コミット防止
brew "lazygit"         # Git TUI
brew "git-delta"       # git diffを美しく表示
brew "difftastic"      # 構文認識diff（リファクタリング時に便利）

# バージョン管理
brew "asdf"            # 複数言語のバージョン管理（Node.js含む）

# エディタ
brew "neovim"          # モダンなVim
brew "vim"

# シェル・ターミナル
brew "atuin"           # シェル履歴管理（クラウド同期対応）
brew "tmux"            # ターミナルマルチプレクサ
brew "zellij"          # モダンなターミナルマルチプレクサ（Rust製）
brew "fzf"             # ファジーファインダー
brew "zoxide"          # 高速ディレクトリナビゲーション
brew "direnv"          # ディレクトリ別環境変数管理
brew "yazi"            # 高速ターミナルファイルマネージャー
brew "ffmpegthumbnailer" # 動画サムネイル（yazi依存）
brew "poppler"         # PDFプレビュー（yazi依存）

# ユーティリティ
brew "bat"             # catの高機能代替（シンタックスハイライト付き）
brew "eza"             # lsの高機能代替（Git統合・アイコン）
brew "fd"              # findの高速代替
brew "ripgrep"         # grepの超高速代替（rg）
brew "stow"            # シンボリックリンク管理
brew "tree"            # ディレクトリツリー表示
brew "btop"            # システムモニター
brew "nb"              # コマンドラインメモ・ブックマーク管理
brew "curl"            # HTTPクライアント
brew "mas"             # Mac App Store CLI
brew "jq"              # JSON処理ツール
brew "yq"              # YAML/TOML処理ツール

# AI駆動開発向けユーティリティ
brew "glow"            # マークダウンレンダラー（ドキュメント閲覧）
brew "tldr"            # manページの簡潔版
brew "httpie"          # モダンHTTPクライアント（API開発）
brew "watchexec"       # ファイル監視・自動実行（TDD）
brew "tokei"           # コード統計（プロジェクト分析）
brew "lefthook"        # 高速Git hooks管理

# モダンCLIツール（従来コマンドの高機能代替）
brew "dust"            # du代替（ディスク使用量可視化）
brew "procs"           # ps代替（プロセス表示）
brew "sd"              # sed代替（直感的な正規表現置換）
brew "hyperfine"       # コマンドベンチマーク
brew "git-absorb"      # fixup commitの自動化

# セキュリティ
brew "gnupg"           # GPG暗号化
brew "mkcert"          # ローカルHTTPS証明書作成
brew "nss"             # mkcert Firefox対応

# クラウド/AWS
brew "awscli"          # AWS CLI（Amazon Q含む）

# ========================================
# GUI Applications (必須)
# ========================================

# ターミナル
cask "ghostty"         # 高速でモダンなターミナル

# ユーティリティ
cask "1password"       # パスワードマネージャー
cask "1password-cli"   # 1Password CLI（シークレット管理）
cask "alt-tab"         # Windows風のタスクスイッチャー
cask "appcleaner"      # アプリ完全削除
cask "cleanshot"       # スクリーンショット・画面録画
cask "espanso"         # テキスト展開（プロンプトスニペット管理）
cask "homerow"         # キーボードショートカット操作
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
cask "dbeaver-community" # データベースGUIクライアント
cask "bruno"           # APIクライアント（REST/GraphQL）
cask "orbstack"        # 軽量Docker代替（Docker Desktop不要）

# フォント
cask "font-hack-nerd-font"
cask "font-jetbrains-mono-nerd-font"

# JSランタイム
brew "oven-sh/bun/bun" # 超高速JS/TSランタイム（Node.js補完）

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
