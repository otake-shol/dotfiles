# Brewfile - Homebrewパッケージ管理
# 使用方法: brew bundle --file=Brewfile

# ========================================
# CLI Tools
# ========================================

# --- Git ---
brew "git"                         # Homebrew版で最新機能
brew "gh"                          # GitHub公式CLI
brew "git-secrets"                 # APIキー誤コミット防止(グローバルhook)
brew "git-delta"                   # diff表示: side-by-side+シンタックスハイライト

# --- バージョン管理・エディタ ---
brew "asdf"                        # Node/Python/Terraform統一管理(.tool-versions)
brew "neovim"                      # 軽微な編集・git commit用

# --- シェル・ターミナル ---
brew "atuin"                       # SQLite履歴+fuzzy検索(Ctrl+R代替)
brew "fzf"                         # 汎用fuzzy finder
brew "zoxide"                      # 学習型cd
brew "direnv"                      # ディレクトリ別.envrc自動読み込み
brew "yazi"                        # Rust製TUIファイラー

# --- モダンCLI ---
brew "bat"                         # cat代替: ハイライト+行番号+Git統合
brew "eza"                         # ls代替: アイコン+Git状態+ツリー
brew "fd"                          # find代替: 高速+.gitignore尊重
brew "ripgrep"                     # grep代替: 高速+Unicode対応
brew "btop"                        # top代替: GPU監視+マウス操作
brew "glow"                        # Markdownレンダリング表示
brew "tldr"                        # manページ簡易版
brew "trash"                       # rm代替: ゴミ箱へ移動
brew "curl"                        # macOS標準より新しいバージョン
brew "jq"                          # JSON処理
brew "sd"                          # sed代替: 直感的な構文
brew "tree"                        # ディレクトリツリー表示

# --- 開発ツール ---
brew "stow"                        # dotfilesシンボリックリンク管理
brew "shellcheck"                  # シェルスクリプトlinter(make lint)

# --- ドキュメント生成 ---
brew "marp-cli"                    # Markdownスライド生成
brew "pandoc"                      # Markdown→PDF/HTML/Word 等の汎用変換
brew "typst"                       # モダン組版エンジン(日本語PDF生成)
brew "poppler"                     # PDFユーティリティ(pdfinfo/pdftotext 等)

# --- メディア・文字起こし ---
brew "ffmpeg"                      # 音声/動画変換(yt-dlpの依存)
brew "yt-dlp"                      # YouTube等の動画/字幕/音声ダウンロード
brew "whisper-cpp"                 # ローカル音声文字起こし(C++高速実装)

# ========================================
# GUI Applications
# ========================================

# --- ターミナル ---
cask "ghostty"                     # Zig製高速ターミナル(GPU描画+TokyoNight)
cask "cmux"                        # Ghosttyベース(AI通知+組み込みブラウザ)

# --- ユーティリティ ---
cask "1password"                   # パスワードマネージャー(SSH鍵管理統合)
cask "1password-cli"               # 1Passwordシークレット取得
cask "tailscale"                   # VPNメッシュネットワーク
cask "alt-tab"                     # Windows風Cmd+Tab(ウィンドウプレビュー)
cask "cleanshot"                   # スクリーンショット+録画+注釈
cask "jordanbaird-ice"             # メニューバーアイコン整理
cask "raycast"                     # Spotlight代替(拡張+スニペット)

# --- ブラウザ・生産性 ---
cask "arc"                         # モダンChromiumブラウザ
cask "readdle-spark"               # メールクライアント
cask "ticktick"                    # ToDoリスト+ポモドーロ
cask "obsidian"                    # Markdownナレッジベース(Vault設定は別管理)
cask "slack"                       # チームコミュニケーション

# --- デザイン・開発 ---
cask "figma"                       # デザイン+プロトタイピング
cask "claude"                      # Claude Code CLI
cask "codex"                       # OpenAI Codex CLI(ChatGPT Plus/Pro連携)
cask "orbstack"                    # Docker Desktop代替(軽量+高速)

# --- フォント ---
cask "font-jetbrains-mono-nerd-font"  # メインフォント(リガチャ+Nerd Font)
