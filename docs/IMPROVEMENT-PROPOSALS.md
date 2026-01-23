# dotfiles 改善提案書

> 作成日: 2026-01-23
> 目的: 世界最高のMac開発環境をポータブルに実現する

---

## 目次

1. [現状評価](#現状評価)
2. [提案サマリー](#提案サマリー)
3. [カテゴリ1: 追加すべきCLIツール](#カテゴリ1-追加すべきcliツール)
4. [カテゴリ2: 追加すべきGUIアプリケーション](#カテゴリ2-追加すべきguiアプリケーション)
5. [カテゴリ3: 既存設定の最適化](#カテゴリ3-既存設定の最適化)
6. [カテゴリ4: 自動化・CI/CD強化](#カテゴリ4-自動化cicd強化)
7. [カテゴリ5: セキュリティ強化](#カテゴリ5-セキュリティ強化)
8. [カテゴリ6: macOSシステム設定追加](#カテゴリ6-macosシステム設定追加)
9. [実装ロードマップ](#実装ロードマップ)

---

## 現状評価

### 強み

| カテゴリ | 評価 | 詳細 |
|---------|------|------|
| モダンCLIツール | ★★★★★ | eza, bat, fd, ripgrep, fzf, zoxide等を完備 |
| AI駆動開発 | ★★★★★ | Claude Code + 13個のMCPサーバー統合 |
| 自動化 | ★★★★☆ | bootstrap.sh, Hooks, Brewfile管理 |
| セキュリティ | ★★★★☆ | git-secrets, 機密ファイル分離 |
| ドキュメント | ★★★★☆ | AI駆動開発ガイド、MCPガイド等充実 |
| テーマ統一 | ★★★★★ | TokyoNightで全ツール統一 |

### 改善余地

| カテゴリ | 現状 | 改善後 |
|---------|------|--------|
| シェル履歴 | 基本的な履歴管理 | AI/クラウド同期対応 |
| Neovim | ミニマル設定 | プラグインエコシステム活用 |
| バックアップ | 手動 | 自動化・クラウド連携 |
| CI/CD | なし | GitHub Actionsで検証自動化 |
| macOS設定 | 基本項目のみ | 開発者向け最適化完備 |

---

## 提案サマリー

### 全提案一覧（42項目）

| # | カテゴリ | 項目 | 優先度 | 工数 |
|---|---------|------|--------|------|
| 1-1 | CLI | atuin（履歴管理） | 高 | 軽 |
| 1-2 | CLI | mcfly（AI履歴検索） | 中 | 軽 |
| 1-3 | CLI | just（コマンドランナー） | 高 | 軽 |
| 1-4 | CLI | navi（チートシート） | 中 | 軽 |
| 1-5 | CLI | difftastic（構造diff） | 高 | 軽 |
| 1-6 | CLI | git-cliff（CHANGELOG生成） | 中 | 軽 |
| 1-7 | CLI | ast-grep（構造検索） | 中 | 軽 |
| 1-8 | CLI | broot（ファイルエクスプローラー） | 中 | 軽 |
| 1-9 | CLI | viddy（watch代替） | 低 | 軽 |
| 1-10 | CLI | bottom（リソースモニター） | 低 | 軽 |
| 1-11 | CLI | xh（HTTPクライアント） | 中 | 軽 |
| 1-12 | CLI | gping（グラフィカルping） | 低 | 軽 |
| 1-13 | CLI | bandwhich（帯域監視） | 低 | 軽 |
| 1-14 | CLI | dog（DNS lookup） | 低 | 軽 |
| 1-15 | CLI | grex（正規表現生成） | 中 | 軽 |
| 1-16 | CLI | mkcert（ローカルHTTPS） | 高 | 軽 |
| 1-17 | CLI | age（暗号化） | 中 | 軽 |
| 1-18 | CLI | git-lfs（大容量ファイル） | 高 | 軽 |
| 1-19 | CLI | bun（JSランタイム） | 高 | 軽 |
| 1-20 | CLI | deno（JSランタイム） | 中 | 軽 |
| 1-21 | CLI | mise（asdf代替） | 中 | 中 |
| 2-1 | GUI | OrbStack（Docker代替） | 高 | 軽 |
| 2-2 | GUI | Cursor / VS Code | 中 | 軽 |
| 2-3 | GUI | Proxyman（HTTPデバッグ） | 中 | 軽 |
| 2-4 | GUI | TablePlus（DB GUI） | 中 | 軽 |
| 2-5 | GUI | Fork（Git GUI） | 低 | 軽 |
| 2-6 | GUI | Karabiner-Elements | 高 | 中 |
| 2-7 | GUI | MonitorControl | 中 | 軽 |
| 2-8 | GUI | Amphetamine | 低 | 軽 |
| 2-9 | GUI | Keka（圧縮） | 中 | 軽 |
| 2-10 | GUI | IINA（動画プレーヤー） | 低 | 軽 |
| 2-11 | GUI | Notion | 中 | 軽 |
| 2-12 | GUI | Obsidian | 中 | 軽 |
| 2-13 | GUI | Hand Mirror | 低 | 軽 |
| 2-14 | GUI | Zoom | 中 | 軽 |
| 2-15 | GUI | Spotify | 低 | 軽 |
| 3-1 | 設定 | zsh補完強化 | 高 | 軽 |
| 3-2 | 設定 | Neovimプラグイン導入 | 中 | 重 |
| 3-3 | 設定 | tmuxプラグイン追加 | 低 | 軽 |
| 3-4 | 設定 | Gitエイリアス拡充 | 中 | 軽 |
| 3-5 | 設定 | エイリアス追加 | 中 | 軽 |
| 3-6 | 設定 | fzf設定強化 | 中 | 軽 |
| 3-7 | 設定 | .tool-versions拡充 | 中 | 軽 |
| 3-8 | 設定 | bootstrap.sh改善 | 高 | 中 |
| 4-1 | 自動化 | GitHub Actions導入 | 高 | 中 |
| 4-2 | 自動化 | 定期更新スクリプト | 中 | 軽 |
| 4-3 | 自動化 | Mackup連携 | 中 | 中 |
| 4-4 | 自動化 | dotfiles lint | 中 | 軽 |
| 4-5 | 自動化 | バージョン通知 | 低 | 軽 |
| 5-1 | セキュリティ | 1Password CLI | 高 | 軽 |
| 5-2 | セキュリティ | SSH鍵ローテーション | 中 | 中 |
| 5-3 | セキュリティ | GPG設定強化 | 中 | 中 |
| 5-4 | セキュリティ | Firewall自動設定 | 低 | 軽 |
| 6-1 | macOS | Mission Control | 中 | 軽 |
| 6-2 | macOS | Hot Corners | 中 | 軽 |
| 6-3 | macOS | Safari開発者設定 | 中 | 軽 |
| 6-4 | macOS | アクセシビリティ | 中 | 軽 |
| 6-5 | macOS | プライバシー設定 | 高 | 軽 |
| 6-6 | macOS | 通知設定 | 低 | 軽 |

---

## カテゴリ1: 追加すべきCLIツール

### 1-1. atuin（シェル履歴管理）⭐ 高優先度

> SQLiteベースの高機能シェル履歴管理。クラウド同期対応。

```bash
brew install atuin
```

**特徴:**
- 全デバイス間で履歴を同期（オプション）
- SQLiteで高速検索
- コンテキスト情報（ディレクトリ、終了コード、実行時間）を記録
- fzfライクなインタラクティブ検索
- 統計情報表示

**設定例:**
```toml
# ~/.config/atuin/config.toml
sync_address = "https://api.atuin.sh"
sync_frequency = "5m"
search_mode = "fuzzy"
filter_mode = "global"
style = "compact"
```

**メリット:**
- 複数Mac間で履歴共有
- 「あのコマンド何だっけ？」を解決
- コマンド実行統計が見れる

---

### 1-2. mcfly（AI履歴検索）

> ニューラルネットワークベースのシェル履歴検索。

```bash
brew install mcfly
```

**特徴:**
- コンテキストに基づいた履歴サジェスト
- 現在のディレクトリ、最近のコマンドを考慮
- 失敗したコマンドを優先度下げ

**atuinとの使い分け:**
- atuin: 同期・統計重視
- mcfly: AIサジェスト重視
- 両方導入も可能（キーバインド分離）

---

### 1-3. just（コマンドランナー）⭐ 高優先度

> makeの現代版。プロジェクトごとのコマンド管理。

```bash
brew install just
```

**特徴:**
- シンプルな構文（makeより直感的）
- 引数・環境変数サポート
- シェルコマンドをそのまま記述
- ドキュメント自動生成

**justfile例:**
```just
# プロジェクトのコマンド一覧

# 開発サーバー起動
dev:
    npm run dev

# テスト実行
test:
    npm test

# ビルド
build:
    npm run build

# 依存関係更新
update:
    npm update
    npm audit fix

# Docker環境起動
docker-up:
    docker compose up -d

# クリーンアップ
clean:
    rm -rf node_modules dist .next
```

**メリット:**
- プロジェクトごとのコマンドを標準化
- `just --list` でコマンド一覧表示
- チーム開発での共通言語

---

### 1-4. navi（インタラクティブチートシート）

> コマンドのチートシートをインタラクティブに検索・実行。

```bash
brew install navi
```

**特徴:**
- コマンドをカテゴリ別に整理
- プレースホルダーで引数入力
- カスタムチートシート作成可能
- fzf統合

**チートシート例:**
```
% docker

# コンテナ一覧
docker ps -a

# イメージ削除
docker rmi <image_id>

# 未使用リソース削除
docker system prune -a

% git

# ブランチ削除（リモート）
git push origin --delete <branch>

# 直前のコミットメッセージ変更
git commit --amend -m "<message>"
```

---

### 1-5. difftastic（構造認識diff）⭐ 高優先度

> プログラミング言語の構文を理解したdiff表示。

```bash
brew install difftastic
```

**特徴:**
- 50+言語の構文解析対応
- インデント変更を無視
- 実際の変更箇所のみハイライト
- side-by-side表示

**Git統合:**
```gitconfig
[diff]
    external = difft
```

**メリット:**
- リファクタリング時のノイズ削減
- コードレビューの効率化

---

### 1-6. git-cliff（CHANGELOG自動生成）

> Conventional Commitsから美しいCHANGELOGを生成。

```bash
brew install git-cliff
```

**特徴:**
- Conventional Commits準拠
- カスタマイズ可能なテンプレート
- セマンティックバージョニング対応
- GitHub/GitLab連携

**使用例:**
```bash
# CHANGELOG生成
git cliff -o CHANGELOG.md

# 特定バージョン間の変更
git cliff v1.0.0..v2.0.0
```

---

### 1-7. ast-grep（構造認識検索・置換）

> ASTベースのコード検索・リファクタリングツール。

```bash
brew install ast-grep
```

**特徴:**
- コードパターンマッチング
- 複数言語対応（JS/TS, Python, Go, Rust等）
- 大規模リファクタリング
- lintルール作成

**使用例:**
```bash
# console.logを検索
ast-grep --pattern 'console.log($$$)'

# 関数名変更
ast-grep --pattern 'oldFunc($ARGS)' --rewrite 'newFunc($ARGS)'
```

---

### 1-8. broot（ファイルエクスプローラー）

> 大規模ディレクトリの高速ナビゲーション。

```bash
brew install broot
```

**特徴:**
- ファジー検索
- ツリー表示 + ファイル内容プレビュー
- Git統合
- カスタムコマンド

**yaziとの使い分け:**
- yazi: ファイル操作重視
- broot: 検索・ナビゲーション重視

---

### 1-9. viddy（モダンwatch）

> watchコマンドの高機能代替。

```bash
brew install viddy
```

**特徴:**
- 差分ハイライト
- 履歴をさかのぼれる
- ページャーモード
- シンタックスハイライト

**使用例:**
```bash
viddy -d 'kubectl get pods'
```

---

### 1-10. bottom（リソースモニター）

> btopの代替/補完。Rust製で軽量。

```bash
brew install bottom
```

**特徴:**
- 低リソース消費
- カスタマイズ可能
- バッテリー情報表示
- プロセスツリー

---

### 1-11. xh（HTTPクライアント）

> HTTPieのRust実装。高速で軽量。

```bash
brew install xh
```

**特徴:**
- HTTPieと同じ構文
- 起動が高速
- セッション管理
- JSON自動フォーマット

**HTTPieとの使い分け:**
- 日常使用: xh（高速）
- 高度な機能: HTTPie

---

### 1-12. gping（グラフィカルping）

> pingをグラフで可視化。

```bash
brew install gping
```

**特徴:**
- 複数ホスト同時監視
- レイテンシをグラフ表示
- パケットロス可視化

---

### 1-13. bandwhich（帯域監視）

> プロセスごとのネットワーク帯域表示。

```bash
brew install bandwhich
```

**特徴:**
- どのプロセスが帯域を使っているか可視化
- リモートIP表示
- リアルタイム更新

---

### 1-14. dog（DNS lookup）

> digの現代版。

```bash
brew install dog
```

**特徴:**
- カラフルな出力
- 複数DNSサーバー同時クエリ
- JSON出力

---

### 1-15. grex（正規表現生成）

> サンプル文字列から正規表現を自動生成。

```bash
brew install grex
```

**使用例:**
```bash
$ grex foo-123 bar-456 baz-789
^[a-z]{3}-\d{3}$
```

---

### 1-16. mkcert（ローカルHTTPS）⭐ 高優先度

> ローカル開発用のHTTPS証明書を簡単作成。

```bash
brew install mkcert
brew install nss  # Firefox対応
```

**使用例:**
```bash
mkcert -install
mkcert localhost 127.0.0.1 ::1
```

**メリット:**
- ローカルでHTTPS開発
- ブラウザ警告なし
- 複数ドメイン対応

---

### 1-17. age（暗号化）

> シンプルで安全なファイル暗号化。

```bash
brew install age
```

**特徴:**
- GPGより簡単
- SSH鍵での暗号化対応
- 複数受信者対応

**使用例:**
```bash
# 暗号化
age -r age1... secret.txt > secret.txt.age

# SSH鍵で暗号化
age -R ~/.ssh/id_ed25519.pub secret.txt > secret.txt.age
```

---

### 1-18. git-lfs（大容量ファイル）⭐ 高優先度

> Gitで大容量ファイルを効率的に管理。

```bash
brew install git-lfs
git lfs install
```

**使用例:**
```bash
# 追跡対象設定
git lfs track "*.psd"
git lfs track "*.zip"
```

---

### 1-19. bun（JSランタイム）⭐ 高優先度

> 超高速JavaScript/TypeScriptランタイム。

```bash
brew install bun
```

**特徴:**
- Node.jsより数倍高速
- TypeScriptネイティブ対応
- npm互換パッケージマネージャー
- バンドラー内蔵

**使用例:**
```bash
bun install        # npm installの代替
bun run dev        # スクリプト実行
bun test           # テスト実行
```

---

### 1-20. deno（JSランタイム）

> セキュアなJavaScript/TypeScriptランタイム。

```bash
brew install deno
```

**特徴:**
- セキュリティファースト（明示的な権限）
- 依存関係管理不要（URL import）
- TypeScriptネイティブ
- 標準ライブラリ充実

---

### 1-21. mise（asdf代替）

> 次世代バージョンマネージャー。asdfより高速。

```bash
brew install mise
```

**特徴:**
- Rust製で高速
- asdf互換（.tool-versions対応）
- 環境変数管理（direnv代替）
- タスクランナー機能

**移行検討:**
- 現在のasdfからの移行が可能
- .tool-versionsをそのまま使用可能

---

## カテゴリ2: 追加すべきGUIアプリケーション

### 2-1. OrbStack（Docker代替）⭐ 高優先度

> 軽量・高速なDocker Desktop代替。

```bash
brew install --cask orbstack
```

**特徴:**
- Docker Desktopより軽量（メモリ50%削減）
- 起動が高速
- Linux VM管理
- ネイティブmacOS統合

**メリット:**
- 開発マシンのリソース節約
- M1/M2 Macで特に効果的

---

### 2-2. Cursor / VS Code

> AI統合IDE。

```bash
# Cursor（AI特化）
brew install --cask cursor

# VS Code（汎用）
brew install --cask visual-studio-code
```

**Antigravityとの使い分け:**
- Antigravity: Google製、軽量
- Cursor: AI補完が強力
- VS Code: 拡張機能エコシステム

---

### 2-3. Proxyman（HTTPデバッグ）

> macOSネイティブのHTTPデバッグプロキシ。

```bash
brew install --cask proxyman
```

**特徴:**
- HTTPリクエスト/レスポンス監視
- リクエスト改変
- SSL復号化
- ネイティブUI

---

### 2-4. TablePlus（DB GUI）

> モダンなデータベースGUIクライアント。

```bash
brew install --cask tableplus
```

**特徴:**
- 美しいUI
- 複数DB対応（MySQL, PostgreSQL, SQLite, Redis等）
- SSH トンネル
- クエリ履歴

**DBeaver との使い分け:**
- DBeaver: 無料、高機能
- TablePlus: UI優先、有料（無料版制限あり）

---

### 2-5. Fork（Git GUI）

> 高速で美しいGit GUIクライアント。

```bash
brew install --cask fork
```

**特徴:**
- 直感的なUI
- インタラクティブrebase
- マージ競合解決
- 画像diff

**lazygitとの使い分け:**
- lazygit: ターミナル、キーボード操作
- Fork: GUI、マウス操作、複雑な操作

---

### 2-6. Karabiner-Elements ⭐ 高優先度

> macOSキーボードカスタマイズの決定版。

```bash
brew install --cask karabiner-elements
```

**おすすめ設定:**
- Caps Lock → Escape（Vim用）
- Caps Lock長押し → Control
- 英数/かな → IME切り替え強化

**設定例:**
```json
{
  "simple_modifications": [
    { "from": { "key_code": "caps_lock" }, "to": { "key_code": "escape" } }
  ]
}
```

---

### 2-7. MonitorControl

> 外部モニターの輝度・音量をキーボードで調整。

```bash
brew install --cask monitorcontrol
```

**特徴:**
- 外部モニターの輝度調整
- キーボードショートカット対応
- DDC/CI対応

---

### 2-8. Amphetamine

> Macのスリープを防止。

```bash
# Mac App Storeから
mas install 937984704
```

**特徴:**
- 時間指定
- アプリ実行中は起動維持
- スケジュール設定

---

### 2-9. Keka（圧縮/展開）

> 高機能アーカイバ。

```bash
brew install --cask keka
```

**特徴:**
- 多数のフォーマット対応
- パスワード付きZIP
- 7z, RAR対応
- macOS標準より高機能

---

### 2-10. IINA（動画プレーヤー）

> macOSネイティブのモダン動画プレーヤー。

```bash
brew install --cask iina
```

**特徴:**
- mpvベース
- ピクチャインピクチャ
- Touch Bar対応
- 美しいUI

---

### 2-11. Notion

> オールインワンワークスペース。

```bash
brew install --cask notion
```

**特徴:**
- ドキュメント・Wiki
- データベース
- カレンダー
- AI機能

---

### 2-12. Obsidian

> マークダウンベースのナレッジベース。

```bash
brew install --cask obsidian
```

**特徴:**
- ローカルファイルベース
- バックリンク
- グラフビュー
- プラグインエコシステム

**Notionとの使い分け:**
- Notion: チーム共有、オンライン
- Obsidian: 個人、オフライン、プライバシー重視

---

### 2-13. Hand Mirror

> メニューバーからカメラをすぐ確認。

```bash
# Mac App Storeから
mas install 1502839586
```

**特徴:**
- ビデオ会議前の身だしなみチェック
- ワンクリックで起動
- 軽量

---

### 2-14. Zoom

> ビデオ会議の定番。

```bash
brew install --cask zoom
```

---

### 2-15. Spotify

> 音楽ストリーミング。

```bash
brew install --cask spotify
```

---

## カテゴリ3: 既存設定の最適化

### 3-1. zsh補完強化 ⭐ 高優先度

**現状:** 基本的なOh My Zshプラグイン

**改善案:**

```bash
# 追加プラグイン
plugins=(
  # 既存
  zsh-autosuggestions
  zsh-syntax-highlighting
  git
  # 追加推奨
  zsh-completions            # 追加補完
  zsh-history-substring-search  # 履歴検索強化
  docker                     # Docker補完
  kubectl                    # Kubernetes補完
  npm                        # npm補完
  yarn                       # yarn補完
)
```

**.zshrc 追加設定:**
```bash
# zsh-completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
```

---

### 3-2. Neovimプラグイン導入

**現状:** ミニマル設定（プラグインなし）

**改善案:** lazy.nvim でプラグイン管理

**推奨プラグイン:**
```lua
-- ~/.config/nvim/lua/plugins.lua

return {
  -- パッケージマネージャー
  { "folke/lazy.nvim" },

  -- テーマ
  { "folke/tokyonight.nvim" },

  -- ファイルエクスプローラー
  { "nvim-tree/nvim-tree.lua" },

  -- ファジーファインダー
  { "nvim-telescope/telescope.nvim" },

  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },

  -- 補完
  { "hrsh7th/nvim-cmp" },

  -- Git
  { "lewis6991/gitsigns.nvim" },

  -- ステータスライン
  { "nvim-lualine/lualine.nvim" },

  -- シンタックスハイライト
  { "nvim-treesitter/nvim-treesitter" },
}
```

**工数:** 重（設定が複雑）

---

### 3-3. tmuxプラグイン追加

**現状:** resurrect, continuum のみ

**追加推奨:**
```bash
# ~/.tmux.conf 追加

set -g @plugin 'tmux-plugins/tmux-sensible'      # 合理的なデフォルト
set -g @plugin 'tmux-plugins/tmux-yank'          # コピー強化
set -g @plugin 'tmux-plugins/tmux-pain-control'  # ペイン操作強化
set -g @plugin 'tmux-plugins/tmux-sessionist'    # セッション管理
set -g @plugin 'christoomey/vim-tmux-navigator'  # Vim-tmux統合ナビ
```

---

### 3-4. Gitエイリアス拡充

**追加推奨（.gitconfig）:**
```gitconfig
[alias]
    # 既存に追加
    sw = switch                    # git switch
    swc = switch -c                # git switch -c（ブランチ作成）
    rs = restore                   # git restore
    rss = restore --staged         # ステージング解除

    # 便利系
    undo = reset HEAD~1 --mixed    # 直前のコミットを取り消し
    amend = commit --amend --no-edit  # 直前のコミットに追加
    wip = commit -m "WIP"          # 作業中コミット

    # ログ系
    graph = log --graph --oneline --all
    today = log --since=midnight --oneline
    week = log --since='1 week ago' --oneline

    # ブランチ系
    recent = branch --sort=-committerdate --format='%(committerdate:relative)%09%(refname:short)'
    cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d"
```

---

### 3-5. エイリアス追加

**.aliases 追加:**
```bash
# ========================================
# 追加エイリアス
# ========================================

# just (コマンドランナー)
alias j="just"
alias jl="just --list"

# bun
alias b="bun"
alias bi="bun install"
alias br="bun run"
alias bx="bunx"

# OrbStack Docker
alias orbctl="orb"

# ディレクトリ作成＆移動
mkcd() { mkdir -p "$1" && cd "$1"; }

# ファイル作成＆編集
touchopen() { touch "$1" && nvim "$1"; }

# Git worktree
alias gwt="git worktree"
alias gwta="git worktree add"
alias gwtl="git worktree list"
alias gwtr="git worktree remove"

# 一時ディレクトリで作業
tmpcd() { cd "$(mktemp -d)"; }

# ポート使用プロセス検索
port() { lsof -i :"$1"; }

# JSONフォーマット（クリップボード）
jsonf() { pbpaste | jq '.' | pbcopy && pbpaste; }

# base64エンコード/デコード
b64e() { echo -n "$1" | base64; }
b64d() { echo -n "$1" | base64 -d; }

# URLエンコード/デコード
urle() { python3 -c "import urllib.parse; print(urllib.parse.quote('$1'))"; }
urld() { python3 -c "import urllib.parse; print(urllib.parse.unquote('$1'))"; }
```

---

### 3-6. fzf設定強化

**.zshrc 追加:**
```bash
# fzf + git統合
# ブランチ選択
fbr() {
  local branches branch
  branches=$(git branch -a --color=always | grep -v HEAD) &&
  branch=$(echo "$branches" |
    fzf --ansi --preview 'git log --oneline --graph --color=always {1}' |
    sed 's/.* //') &&
  git checkout $(echo "$branch" | sed "s#remotes/origin/##")
}

# コミット選択
fshow() {
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(green)%cr" |
  fzf --ansi --preview 'git show --color=always {1}' \
    --bind 'enter:execute(git show --color=always {1} | less -R)'
}

# ファイル選択してVimで開く
fvim() {
  local file
  file=$(fzf --preview 'bat --color=always {}') && nvim "$file"
}

# プロセスkill
fkill() {
  local pid
  pid=$(ps -ef | fzf --header='Select process to kill' | awk '{print $2}')
  [ -n "$pid" ] && kill -9 "$pid"
}
```

---

### 3-7. .tool-versions拡充

**現状:**
```
nodejs 20.11.0
python 3.12.1
```

**追加推奨:**
```
nodejs 20.11.0
python 3.12.1
ruby 3.3.0        # 必要に応じて
golang 1.22.0     # 必要に応じて
rust stable       # 必要に応じて
java temurin-21   # 必要に応じて
```

---

### 3-8. bootstrap.sh改善 ⭐ 高優先度

**追加機能:**

```bash
# ドライランモード
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}ドライランモード: 実際の変更は行いません${NC}"
fi

# Rosetta 2 インストール確認（Apple Silicon）
if [[ $(uname -m) == "arm64" ]]; then
    if ! /usr/bin/pgrep -q oahd; then
        echo -e "${YELLOW}Rosetta 2をインストールしますか? (y/n)${NC}"
        read -r answer
        if [ "$answer" = "y" ]; then
            softwareupdate --install-rosetta --agree-to-license
        fi
    fi
fi

# バックアップ機能
backup_existing() {
    local file="$1"
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        mv "$file" "${file}.backup.$(date +%Y%m%d%H%M%S)"
        echo -e "${YELLOW}バックアップ: ${file}${NC}"
    fi
}

# ロールバック機能
if [[ "$1" == "--rollback" ]]; then
    echo -e "${YELLOW}バックアップからの復元...${NC}"
    # 実装
fi
```

---

## カテゴリ4: 自動化・CI/CD強化

### 4-1. GitHub Actions導入 ⭐ 高優先度

**.github/workflows/lint.yml:**
```yaml
name: Lint dotfiles

on:
  push:
    branches: [master, main]
  pull_request:
    branches: [master, main]

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run ShellCheck
        uses: ludeeus/action-shellcheck@master
        with:
          scandir: './scripts'
          additional_files: 'bootstrap.sh'

  yaml-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: YAML Lint
        uses: ibiqlik/action-yamllint@v3
        with:
          file_or_dir: .

  markdown-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Markdown Lint
        uses: articulate/actions-markdownlint@v1
        with:
          config: .markdownlint.json
          files: '**/*.md'
```

---

### 4-2. 定期更新スクリプト

**scripts/weekly-update.sh:**
```bash
#!/bin/bash
# 週次メンテナンススクリプト

echo "=== dotfiles 週次メンテナンス ==="

# Homebrew更新
echo "→ Homebrew更新中..."
brew update
brew upgrade
brew cleanup

# Oh My Zsh更新
echo "→ Oh My Zsh更新中..."
omz update

# asdf プラグイン更新
echo "→ asdf更新中..."
asdf plugin update --all

# TPM更新（tmuxプラグイン）
echo "→ tmuxプラグイン更新中..."
~/.tmux/plugins/tpm/bin/update_plugins all

# Neovimプラグイン更新（lazy.nvim使用時）
# nvim --headless "+Lazy! sync" +qa

echo "=== 完了 ==="
```

**crontab設定（オプション）:**
```bash
# 毎週日曜日の午前3時に実行
0 3 * * 0 /bin/bash ~/dotfiles/scripts/weekly-update.sh >> ~/logs/weekly-update.log 2>&1
```

---

### 4-3. Mackup連携

> アプリ設定のバックアップ・同期ツール。

```bash
brew install mackup
```

**.mackup.cfg:**
```ini
[storage]
engine = icloud

[applications_to_sync]
# 同期するアプリ
ghostty
raycast
espanso

[applications_to_ignore]
# 同期しないアプリ（dotfilesで管理）
git
zsh
neovim
tmux
```

---

### 4-4. dotfiles lint

**scripts/lint.sh:**
```bash
#!/bin/bash
# dotfiles lint スクリプト

echo "=== dotfiles Lint ==="

# ShellCheck
echo "→ ShellCheck..."
shellcheck scripts/*.sh bootstrap.sh

# YAML Lint
echo "→ YAML Lint..."
yamllint .

# Markdown Lint
echo "→ Markdown Lint..."
markdownlint '**/*.md' --ignore node_modules

echo "=== 完了 ==="
```

---

### 4-5. バージョン通知

**scripts/check-new-versions.sh:**
```bash
#!/bin/bash
# 新バージョン通知スクリプト

# asdf管理ツールの新バージョンチェック
echo "=== 新バージョンチェック ==="

for plugin in $(asdf plugin list); do
    current=$(asdf current $plugin 2>/dev/null | awk '{print $2}')
    latest=$(asdf latest $plugin 2>/dev/null)

    if [ "$current" != "$latest" ]; then
        echo "[$plugin] 現在: $current → 最新: $latest"
    fi
done
```

---

## カテゴリ5: セキュリティ強化

### 5-1. 1Password CLI ⭐ 高優先度

```bash
brew install --cask 1password-cli
```

**機能:**
- シークレットをCLIから取得
- 環境変数に安全に注入
- dotfilesで機密情報を扱わずに済む

**使用例:**
```bash
# シークレット取得
op item get "API Key" --fields password

# 環境変数として使用
export API_KEY=$(op item get "API Key" --fields password)
```

**.zshrc.local での活用:**
```bash
# 1Password CLIでシークレット管理
if command -v op &> /dev/null; then
    export GITHUB_TOKEN=$(op item get "GitHub Token" --fields password 2>/dev/null)
fi
```

---

### 5-2. SSH鍵ローテーション手順

**docs/security/ssh-key-rotation.md:**
```markdown
# SSH鍵ローテーション手順

## 新しい鍵の生成
```bash
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/id_ed25519_new
```

## GitHub/GitLabに新しい公開鍵を追加

## SSH configを更新
```bash
Host github.com
    IdentityFile ~/.ssh/id_ed25519_new
```

## 古い鍵を削除
```bash
rm ~/.ssh/id_ed25519_old*
```
```

---

### 5-3. GPG設定強化

**追加設定:**
```bash
# GPGエージェント設定
echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf

# Git署名設定
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
git config --global tag.gpgsign true
```

---

### 5-4. Firewall自動設定

**scripts/macos-security.sh:**
```bash
#!/bin/bash
# macOS セキュリティ設定

# Firewallを有効化
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# ステルスモードを有効化
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

# 署名済みアプリを自動許可
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned on

echo "Firewall設定完了"
```

---

## カテゴリ6: macOSシステム設定追加

### 6-1. Mission Control設定

**scripts/macos-defaults.sh 追加:**
```bash
# Mission Control
defaults write com.apple.dock mru-spaces -bool false          # スペースを最近使用順に並べ替えない
defaults write com.apple.dock expose-animation-duration -float 0.1  # Mission Controlアニメーション高速化
defaults write com.apple.dock expose-group-apps -bool true    # アプリケーションごとにグループ化
```

---

### 6-2. Hot Corners設定

```bash
# Hot Corners
# 左上: Mission Control (2)
# 右上: デスクトップ表示 (4)
# 左下: なし (0)
# 右下: Launchpad (11)

defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-corner -int 4
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-corner -int 11
defaults write com.apple.dock wvous-br-modifier -int 0
```

---

### 6-3. Safari開発者設定

```bash
# Safari開発者メニュー
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

# WebKitインスペクタをすべてのページで許可
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
```

---

### 6-4. アクセシビリティ設定

```bash
# ズーム機能（Ctrl+スクロール）
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144

# マウスカーソルを大きく
defaults write com.apple.universalaccess mouseDriverCursorSize -float 1.5
```

---

### 6-5. プライバシー設定 ⭐ 高優先度

```bash
# 診断データを送信しない
defaults write com.apple.CrashReporter DialogType -string "none"

# Siri提案を無効化（プライバシー）
defaults write com.apple.Siri StatusMenuVisible -bool false
defaults write com.apple.Siri UserHasDeclinedEnable -bool true

# ターゲティング広告を制限
defaults write com.apple.AdLib forceLimitAdTracking -bool true
```

---

### 6-6. 通知設定

```bash
# 通知センターを無効化（集中時用のスクリプト）
# launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist

# Do Not Disturb自動化は設定アプリから
```

---

## 実装ロードマップ

### Phase 1: 即座に導入（高優先度・軽工数）

1. **CLIツール**
   - [ ] atuin
   - [ ] just
   - [ ] difftastic
   - [ ] mkcert
   - [ ] git-lfs
   - [ ] bun

2. **GUIアプリ**
   - [ ] OrbStack
   - [ ] Karabiner-Elements

3. **設定改善**
   - [ ] zsh補完強化
   - [ ] bootstrap.sh改善

4. **自動化**
   - [ ] GitHub Actions

5. **セキュリティ**
   - [ ] 1Password CLI

### Phase 2: 中期導入（1-2週間）

1. **CLIツール**
   - [ ] mcfly or atuin選定
   - [ ] navi
   - [ ] ast-grep
   - [ ] age

2. **設定改善**
   - [ ] Gitエイリアス拡充
   - [ ] fzf設定強化
   - [ ] エイリアス追加

3. **自動化**
   - [ ] 定期更新スクリプト
   - [ ] Mackup連携

4. **macOS設定**
   - [ ] Mission Control
   - [ ] Hot Corners
   - [ ] プライバシー設定

### Phase 3: 長期検討（要検証）

1. **Neovimプラグイン導入**
   - lazy.nvim + 各種プラグイン
   - 工数大、要テスト

2. **mise移行検討**
   - asdfからの移行
   - 互換性検証

3. **追加GUIアプリ**
   - 必要に応じて選定

---

## チェックリスト

### 導入前確認

- [ ] 現在の環境をバックアップ
- [ ] Brewfileの現状を記録（`brew bundle dump`）
- [ ] 設定ファイルの現状をコミット

### 導入後確認

- [ ] シェル起動時間が許容範囲内か（`time zsh -i -c exit`）
- [ ] 新しいツールのエイリアスが競合していないか
- [ ] Brewfileが正しく更新されているか
- [ ] bootstrap.shが新環境で動作するか

---

## 参考リンク

- [Modern Unix](https://github.com/ibraheemdev/modern-unix) - モダンCLIツール一覧
- [Awesome macOS](https://github.com/iCHAIT/awesome-macOS) - macOSアプリ一覧
- [dotfiles.github.io](https://dotfiles.github.io/) - dotfilesベストプラクティス
