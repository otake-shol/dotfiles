# Brewfile - Homebrewパッケージ管理
# 使用方法: brew bundle --file=Brewfile
#
# 選定基準:
#   - モダンCLI: 従来コマンドの高速・高機能代替を優先
#   - 統一テーマ: TokyoNight対応ツールを優先
#   - 軽量性: 単機能で高速なツールを選択

# Taps
tap "oven-sh/bun"      # bun用

# ========================================
# CLI Tools
# ========================================

# --- Git関連 ---
brew "git"
#   選定理由: 必須。Homebrew版は最新機能が使える

brew "gh"
#   選定理由: GitHub公式CLI。API操作・PR作成が高速
#   代替候補: hub（非推奨化）
#   拡張: gh-dash（gh extension install dlvhdr/gh-dash）

brew "git-secrets"
#   選定理由: AWS/APIキーの誤コミット防止。pre-commit hookで自動スキャン
#   代替候補: gitleaks（高機能だが設定が複雑）

brew "git-delta"
#   選定理由: diff表示が美しい。side-by-side・行番号・シンタックスハイライト
#   代替候補: diff-so-fancy（機能少ない）
#   補完関係: difftastic（AST比較）と併用

brew "difftastic"
#   選定理由: AST比較でリファクタリング時の本質的な変更を検出
#   用途: 大規模リファクタリング、PRレビュー時に使い分け

brew "gnupg"
#   選定理由: GPGコミット署名・ファイル暗号化。セットアップはdocs/setup/GPG_SIGNING.md参照
#   代替候補: なし（デファクト標準）

brew "lazygit"
#   選定理由: Git TUI。ステージング・コミット・ブランチ操作が直感的
#   代替候補: tig（機能少ない）、gitui（Rust製、同等機能）

# --- バージョン管理 ---
brew "asdf"
#   選定理由: Node/Python/Terraform等を統一管理。.tool-versionsでプロジェクト別バージョン固定
#   代替候補: nvm+pyenv（ツールごとに分散）、mise（新興で実績少ない）

# --- エディタ ---
brew "neovim"
#   選定理由: 軽微な編集用。Lua設定でモダン。ターミナル内で完結
#   代替候補: vim（Lua非対応）、helix（キーバインドが独自）
#   メインエディタ: Antigravity（別途caskでインストール不可）

# --- シェル・ターミナル ---
brew "atuin"
#   選定理由: SQLite履歴・クラウド同期・fuzzy検索。Ctrl+Rを完全代替
#   代替候補: mcfly（同期なし）、hstr（機能少ない）

brew "fzf"
#   選定理由: 汎用fuzzy finder。パイプで何でも絞り込める
#   代替候補: peco/percol（開発停滞）、skim（Rust製だが互換性問題）

brew "zoxide"
#   選定理由: 学習型cd。使用頻度でディレクトリをランク付け
#   代替候補: autojump（Python依存で遅い）、z.lua（Lua依存）

brew "direnv"
#   選定理由: ディレクトリ別.envrc自動読み込み。プロジェクト切り替えが楽
#   代替候補: dotenv（手動source必要）

brew "yazi"
#   選定理由: Rust製高速TUIファイラー。プレビュー・vim風操作
#   代替候補: ranger（Python製で遅い）、lf（Go製、機能少ない）

brew "ffmpegthumbnailer"
#   選定理由: yazi動画サムネイル依存

brew "poppler"
#   選定理由: yaziPDFプレビュー依存

# --- ユーティリティ ---
brew "bat"
#   選定理由: cat代替。シンタックスハイライト・行番号・Git統合・TokyoNightテーマ対応
#   代替候補: ccat（Git統合なし）、highlight（設定複雑）

brew "eza"
#   選定理由: ls代替。Nerd Fontアイコン・Git状態・ツリー表示
#   代替候補: lsd（機能同等だがメンテ頻度低）、exa（開発終了→ezaがfork）

brew "fd"
#   選定理由: find代替。直感的構文・高速・.gitignore自動尊重
#   代替候補: find（構文が複雑）

brew "ripgrep"
#   選定理由: grep代替。圧倒的高速・.gitignore尊重・Unicode対応
#   代替候補: ag/ack（ripgrepより遅い）、grep（機能不足）

brew "stow"
#   選定理由: シンボリックリンク管理。dotfilesの宣言的デプロイ
#   代替候補: 手動ln -s（保守困難）、chezmoi（テンプレート過剰）

brew "btop"
#   選定理由: top/htop代替。美しいUI・マウス操作・GPU監視
#   代替候補: htop（機能少ない）、bottom（TUI操作性劣る）

# brew "procs"  # 削除: btop + fkill関数で代替可能

brew "glow"
#   選定理由: Markdownターミナル表示。READMEをCLIで確認
#   代替候補: mdcat（機能少ない）

brew "tldr"
#   選定理由: manページ簡易版。実用的な例を表示
#   代替候補: cheat（同等）、tealdeer（Rust版、高速）

brew "dust"
#   選定理由: du代替。ディスク使用量をビジュアル表示・直感的
#   代替候補: ncdu（TUI操作）、du（出力が見づらい）

brew "duf"
#   選定理由: df代替。ディスク空き容量を見やすく表示
#   代替候補: df（出力が見づらい）

brew "trash"
#   選定理由: rm代替。ゴミ箱へ移動で復元可能
#   代替候補: rmtrash（メンテ停滞）

brew "curl"
#   選定理由: HTTPクライアント。macOS標準より新しいバージョン

brew "jq"
#   選定理由: JSON処理の標準ツール。パイプラインで加工
#   代替候補: fx（インタラクティブ向け）、gojq（互換性問題）

# --- 開発ツール ---
brew "tokei"
#   選定理由: コード統計。高速・多言語対応
#   代替候補: cloc（Perl製で遅い）、scc（同等だが知名度低）

brew "httpie"
#   選定理由: curl代替。直感的な構文・JSON対応・カラー出力
#   代替候補: curl（構文が複雑）、xh（Rust版httpie）

brew "hyperfine"
#   選定理由: コマンドベンチマーク。統計情報・ウォームアップ対応
#   代替候補: time（統計なし）

# brew "watchexec"  # 削除: 使用頻度低い

brew "lefthook"
#   選定理由: Git hooks管理。並列実行・YAML設定・高速
#   代替候補: husky（Node依存）、pre-commit（Python依存）

brew "shellcheck"
#   選定理由: シェルスクリプトlinter。lefthook pre-commitで使用
#   代替候補: なし（デファクト標準）

brew "yamllint"
#   選定理由: YAML linter。lefthook pre-commitで使用

brew "wget"
#   選定理由: ファイルダウンロード。curlより再帰取得が得意

brew "yq"
#   選定理由: YAML/JSON/XML処理。jqのYAML版
#   代替候補: jq（JSON専用）

brew "tree"
#   選定理由: ディレクトリツリー表示。シンプルで軽量

brew "sd"
#   選定理由: sed代替。直感的な構文で置換
#   代替候補: sed（構文が複雑）

brew "uv"
#   選定理由: 高速Pythonパッケージ管理。pip/venv代替
#   代替候補: pip（遅い）、poetry（重い）

brew "mkcert"
#   選定理由: ローカルSSL証明書生成。HTTPS開発環境構築

brew "mas"
#   選定理由: Mac App Store CLI。自動化・スクリプト連携

brew "markdownlint-cli"
#   選定理由: Markdown linter。ドキュメント品質維持

brew "marp-cli"
#   選定理由: Markdownからスライド（PDF/HTML/PPTX）生成。CLI完結でCI統合可能
#   代替候補: slidev（Web専用）、reveal.js（設定複雑）、Google Slides API（認証必要）

brew "git-absorb"
#   選定理由: 自動fixupコミット生成。リベース効率化

brew "git-cliff"
#   選定理由: 変更履歴（CHANGELOG）自動生成

brew "terraform-docs"
#   選定理由: Terraformモジュールドキュメント自動生成

brew "tflint"
#   選定理由: Terraform linter。ベストプラクティス検証

# --- クラウド/AWS ---
brew "awscli"
#   選定理由: AWS公式CLI
#   代替候補: aws-vault（認証ラッパー、補完的に使用可）

# --- JSランタイム ---
brew "oven-sh/bun/bun"
#   選定理由: 超高速JS/TSランタイム。npm互換・バンドラー内蔵
#   代替候補: deno（npm互換性問題）
#   補完関係: Node.js（asdf管理）と併用

# ========================================
# GUI Applications
# ========================================

# --- ターミナル ---
cask "ghostty"
#   選定理由: Zig製高速ターミナル。GPU描画・TokyoNightテーマ・ネイティブタブ
#   代替候補: kitty（設定複雑）、alacritty（タブなし）、wezterm（Lua設定）、iTerm2（重い）

# --- ユーティリティ ---
cask "1password"
#   選定理由: パスワードマネージャー。家族共有・SSH鍵管理・CLI統合
#   代替候補: Bitwarden（セルフホスト向け）

cask "1password-cli"
#   選定理由: 1Passwordのシークレットをスクリプトから取得

cask "tailscale"
#   選定理由: VPNメッシュネットワーク。外出先からSSH接続
#   代替候補: ZeroTier（設定複雑）、WireGuard（手動設定必要）

cask "alt-tab"
#   選定理由: Windows風Cmd+Tab。ウィンドウプレビュー表示
#   代替候補: macOS標準（アプリ単位でウィンドウ選べない）

cask "appcleaner"
#   選定理由: アプリ完全削除。関連ファイルも検出
#   代替候補: AppZapper（有料）

cask "cleanshot"
#   選定理由: スクリーンショット・録画。注釈・クラウドアップロード
#   代替候補: macOS標準（注釈機能弱い）、Skitch（開発停滞）

cask "homerow"
#   選定理由: キーボードでUI操作。Vimium風のヒント表示
#   代替候補: Shortcat（機能少ない）、Vimac（開発停滞）

cask "jordanbaird-ice"
#   選定理由: メニューバーアイコン整理。自動非表示
#   代替候補: Bartender（有料）、Hidden Bar（機能少ない）

cask "raycast"
#   選定理由: Spotlight代替。拡張機能・スニペット・ウィンドウ管理
#   代替候補: Alfred（一部有料）、macOS Spotlight（拡張性なし）

# --- ブラウザ ---
cask "arc"
#   選定理由: モダンChromiumブラウザ。スペース・サイドバー・Command Bar
#   代替候補: Chrome（従来型UI）、Vivaldi（機能過多）

# --- 生産性 ---
cask "readdle-spark"
#   選定理由: メールクライアント。Smart Inbox・スヌーズ・チーム共有
#   代替候補: Apple Mail（機能少ない）、Airmail（安定性問題）

cask "ticktick"
#   選定理由: ToDoリスト。ポモドーロ・カレンダー統合・習慣トラッカー
#   代替候補: Todoist（ポモドーロなし）、Things（買い切り高額）

# --- コミュニケーション ---
cask "slack"
#   選定理由: チームコミュニケーション標準

# --- デザイン ---
cask "figma"
#   選定理由: デザイン・プロトタイピング。Web版より安定
#   代替候補: Sketch（macOS専用・買い切り）

# --- AI・開発 ---
cask "claude"
#   選定理由: Claude Code CLI。MCP統合・エージェント機能

cask "dbeaver-community"
#   選定理由: データベースGUI。多DB対応・ER図生成
#   代替候補: TablePlus（一部有料）、DataGrip（有料）

cask "bruno"
#   選定理由: APIクライアント。Git管理可能・オフライン動作
#   代替候補: Postman（クラウド強制）、Insomnia（方針変更で不安定）

cask "orbstack"
#   選定理由: Docker Desktop代替。軽量・高速・Rosetta統合
#   代替候補: Docker Desktop（リソース消費大）、colima（CLI専用）

# --- フォント ---
cask "font-hack-nerd-font"
#   選定理由: プログラミング向け等幅フォント+アイコン

cask "font-jetbrains-mono-nerd-font"
#   選定理由: JetBrains製等幅フォント。リガチャ対応・Ghosttyメインフォント

# ========================================
# オプション：開発環境
# ========================================
# 必要に応じてコメントアウトを外してインストール
# asdfで管理する場合は不要

# brew "node"           # asdf推奨
# brew "python@3.13"    # asdf推奨
# brew "php"
# brew "composer"
# brew "mysql"
# brew "postgresql@14"
# brew "docker"         # orbstack推奨
