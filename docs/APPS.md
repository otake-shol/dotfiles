# アプリケーション一覧

dotfilesで管理しているアプリケーションとツールの一覧です。

## インストール

```bash
# 必須ツールのみ（推奨）
brew bundle --file=~/dotfiles/Brewfile

# 全ツール
brew bundle --file=~/dotfiles/Brewfile.full
```

---

## GUI アプリケーション

### ターミナル

#### Ghostty

<img src="https://ghostty.org/social-share-card.jpg" width="600" alt="Ghostty">

> GPU アクセラレーション対応の高速モダンターミナル

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask ghostty` |
| 設定ファイル | `~/dotfiles/ghostty/config` |
| 公式サイト | https://ghostty.org/ |

**特徴:**
- Zig言語で書かれた高速ターミナル
- ネイティブGUI（macOS/Linux）
- リッチなカスタマイズ性
- シェーダー対応

---

### ユーティリティ

#### Raycast

<img src="https://www.raycast.com/opengraph-image-pwu6ef.png" width="600" alt="Raycast">

> Spotlight を超える生産性ランチャー

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask raycast` |
| 設定ファイル | `~/dotfiles/raycast/` |
| 公式サイト | https://www.raycast.com/ |

**特徴:**
- 高速なアプリ起動・ファイル検索
- スニペット・クリップボード履歴
- 拡張機能エコシステム
- ウィンドウ管理・計算機

**自作 Script Commands:**

macOS日本語入力のユーザー辞書を管理するスクリプト。

| コマンド | 説明 |
|---------|------|
| ユーザー辞書に登録 | 読みと単語を入力して辞書に登録 |
| ユーザー辞書一覧 | 登録済み単語を一覧表示 |
| ユーザー辞書から削除 | 読みを入力して辞書から削除 |

**セットアップ:**
```bash
# Raycast で "Import Script Command" を実行し、以下を選択
~/dotfiles/raycast/scripts/
```

---

#### AltTab

<img src="https://alt-tab-macos.netlify.app/public/demo/frontpage.jpg" width="600" alt="AltTab">

> Windows 風のウィンドウスイッチャー

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask alt-tab` |
| 公式サイト | https://alt-tab-macos.netlify.app/ |

**特徴:**
- ウィンドウのプレビュー表示
- すべてのウィンドウを一覧表示
- キーボードショートカットでの高速切り替え

---

#### Homerow

<img src="https://www.homerow.app/app-icon.png" width="120" alt="Homerow">

> キーボードだけで画面上のすべてを操作

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask homerow` |
| 公式サイト | https://www.homerow.app/ |

**特徴:**
- Vimライクなナビゲーション
- すべてのUI要素にショートカット
- マウス不要の効率的操作

---

#### Ice

> メニューバーアイコンの管理ツール

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask jordanbaird-ice` |
| GitHub | https://github.com/jordanbaird/Ice |

**特徴:**
- メニューバーアイコンの表示/非表示
- グループ化・並び替え
- Bartender の無料代替

---

#### CleanShot X

> 高機能スクリーンショット・画面録画ツール

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask cleanshot` |
| 公式サイト | https://cleanshot.com/ |

**特徴:**
- スクリーンショット・画面録画
- 注釈・モザイク・矢印追加
- クラウドアップロード
- スクロールキャプチャ
- GIF 作成

---

#### 1Password

> 安全で使いやすいパスワードマネージャー

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask 1password` |
| 公式サイト | https://1password.com/ |

**特徴:**
- パスワードの安全な保存・自動入力
- 二要素認証のサポート
- 家族・チームでの共有機能
- ブラウザ拡張機能

---

#### AppCleaner

> アプリの完全アンインストールツール

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask appcleaner` |
| 公式サイト | https://freemacsoft.net/appcleaner/ |

**特徴:**
- アプリの関連ファイルも含めて完全削除
- ドラッグ&ドロップで簡単操作
- 軽量で高速
- 無料

---

### ブラウザ

#### Arc

<img src="https://arc.net/og.png" width="600" alt="Arc">

> 次世代のブラウザ体験

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask arc` |
| 公式サイト | https://arc.net/ |

**特徴:**
- スペース機能でタブ整理
- サイドバー型の革新的UI
- Split View で画面分割
- コマンドバーで高速操作
- 美しいデザイン

---

### 生産性

#### Spark

<img src="https://cdn-rdstaticassets.readdle.com/spark/img/spark3/index/banner-device.png" width="600" alt="Spark">

> スマートで高速なメールクライアント

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask readdle-spark` |
| 公式サイト | https://sparkmailapp.com/ |

**特徴:**
- 複数アカウント統合管理
- スマート通知
- AI機能搭載
- Gmail / Outlook / iCloud 対応

---

#### TickTick

<img src="https://d107mjio2rjf74.cloudfront.net/sites/res/newHome/tick/header1.jpg" width="600" alt="TickTick">

> オールインワンのタスク管理

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask ticktick` |
| 公式サイト | https://www.ticktick.com/ |

**特徴:**
- タスク管理・リマインダー
- カレンダー統合
- ポモドーロタイマー
- 習慣トラッカー
- クロスプラットフォーム同期

---

### コミュニケーション

#### Slack

<img src="https://a.slack-edge.com/80588/marketing/img/meta/slack_hash_256.png" width="200" alt="Slack">

> チームコラボレーションの定番

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask slack` |
| 公式サイト | https://slack.com/ |

---

### デザイン

#### Figma

<img src="https://cdn.sanity.io/images/599r6htc/regionalized/1adfa5a99040c80af7b4b5e3e2cf845315ea2367-2400x1260.png?w=1200&q=70&fit=max&auto=format" width="600" alt="Figma">

> コラボレーティブデザインツール

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask figma` |
| 公式サイト | https://www.figma.com/ |

**特徴:**
- リアルタイム共同編集
- UI/UXデザイン
- プロトタイピング
- デザインシステム管理

---

### 開発ツール

#### Claude

> AI コーディングアシスタント

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask claude` |
| 設定ファイル | `~/dotfiles/.claude/` |
| 公式サイト | https://claude.ai/ |

---

#### DBeaver Community

> ユニバーサルデータベース GUI クライアント

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask dbeaver-community` |
| 公式サイト | https://dbeaver.io/ |

**特徴:**
- 多数のデータベース対応（MySQL, PostgreSQL, SQLite, MongoDB 等）
- ER 図自動生成
- SQL エディタ・補完
- データエクスポート/インポート

---

#### Bruno

> オープンソース API クライアント

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask bruno` |
| 公式サイト | https://www.usebruno.com/ |

**特徴:**
- REST / GraphQL 対応
- Git フレンドリー（コレクションをファイルで管理）
- オフライン動作
- Postman / Insomnia からのインポート

---

## CLI ツール

### Git 関連

| ツール | 説明 | インストール |
|--------|------|--------------|
| **git** | バージョン管理 | `brew install git` |
| **gh** | GitHub CLI | `brew install gh` |
| **lazygit** | Git TUI | `brew install lazygit` |
| **git-secrets** | 認証情報漏洩防止 | `brew install git-secrets` |
| **git-delta** | 美しい diff 表示 | `brew install git-delta` |
| **tig** | Git テキストUI | `brew install tig` |

#### lazygit

<img src="https://github.com/jesseduffield/lazygit/raw/assets/demo/commit_and_push-compressed.gif" width="600" alt="lazygit">

> ターミナルで使える直感的な Git クライアント

---

### シェル・ターミナル

#### fzf

<img src="https://raw.githubusercontent.com/junegunn/i/master/fzf-preview.png" width="600" alt="fzf">

> コマンドライン用ファジーファインダー

| 項目 | 内容 |
|------|------|
| インストール | `brew install fzf` |
| GitHub | https://github.com/junegunn/fzf |

**キーバインド:**
- `Ctrl+R` - コマンド履歴検索
- `Ctrl+T` - ファイル検索
- `Alt+C` - ディレクトリ移動

---

#### zoxide

> スマートな cd コマンド

| 項目 | 内容 |
|------|------|
| インストール | `brew install zoxide` |
| GitHub | https://github.com/ajeetdsouza/zoxide |

**使用例:**
```bash
z dotfiles    # ~/dotfiles に移動（部分一致）
z doc         # 最もよく使う "doc" を含むディレクトリへ
zi            # インタラクティブ選択
```

---

#### yazi

<img src="https://raw.githubusercontent.com/sxyazi/yazi/main/assets/logo.png" width="100" alt="yazi">

> 高速ターミナルファイルマネージャー（Rust製）

| 項目 | 内容 |
|------|------|
| インストール | `brew install yazi ffmpegthumbnailer poppler` |
| 公式サイト | https://yazi-rs.github.io/ |
| GitHub | https://github.com/sxyazi/yazi |

**特徴:**
- 非同期I/Oによる高速動作
- 画像・PDF・動画プレビュー（標準で動作）
- Vimスタイルキーバインド
- Git統合（変更ファイルの色分け）
- Luaプラグインシステム
- マルチタブ対応

**基本キーバインド:**

| キー | 動作 |
|------|------|
| `j/k` | 上下移動 |
| `h/l` | 親/子ディレクトリ |
| `Enter` | ファイルを開く |
| `Space` | 選択 |
| `y` | コピー |
| `p` | 貼り付け |
| `d` | 削除（ゴミ箱へ） |
| `r` | リネーム |
| `/` | 検索 |
| `q` | 終了 |

**シェル統合（.zshrc に追加済み）:**
```bash
# y コマンドで起動、終了時にディレクトリを移動
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
```

---

#### bat

<img src="https://imgur.com/rGsdnDe.png" width="600" alt="bat">

> シンタックスハイライト付き cat

| 項目 | 内容 |
|------|------|
| インストール | `brew install bat` |
| GitHub | https://github.com/sharkdp/bat |

**特徴:**
- シンタックスハイライト
- Git 差分表示
- 行番号表示
- ページャー機能

---

#### tmux

> ターミナルマルチプレクサ

| 項目 | 内容 |
|------|------|
| インストール | `brew install tmux` |
| 公式サイト | https://github.com/tmux/tmux |

**特徴:**
- セッション管理
- ウィンドウ分割
- SSH 接続維持

---

#### direnv

> ディレクトリ別の環境変数管理

| 項目 | 内容 |
|------|------|
| インストール | `brew install direnv` |
| GitHub | https://github.com/direnv/direnv |

**特徴:**
- ディレクトリごとに環境変数を自動設定
- `.envrc` ファイルで管理
- プロジェクト切り替え時に自動適用

---

### モダン CLI ツール

従来のUnixコマンドの高機能・高速な代替ツール。

#### eza

> ls の高機能代替

| 項目 | 内容 |
|------|------|
| インストール | `brew install eza` |
| GitHub | https://github.com/eza-community/eza |

**特徴:**
- Git ステータス統合
- ファイルアイコン表示
- ツリー表示対応
- カラフルな出力

---

#### fd

> find の高速代替

| 項目 | 内容 |
|------|------|
| インストール | `brew install fd` |
| GitHub | https://github.com/sharkdp/fd |

**特徴:**
- シンプルな構文
- 正規表現サポート
- `.gitignore` 自動対応
- find より 5〜10 倍高速

---

#### ripgrep (rg)

> grep の超高速代替

| 項目 | 内容 |
|------|------|
| インストール | `brew install ripgrep` |
| GitHub | https://github.com/BurntSushi/ripgrep |

**特徴:**
- 圧倒的な検索速度
- `.gitignore` 自動対応
- 複数ファイルタイプ対応
- コード検索に最適

---

### システムモニタリング

#### btop

<img src="https://github.com/aristocratos/btop/raw/main/Img/normal.png" width="600" alt="btop">

> 美しいシステムモニター

| 項目 | 内容 |
|------|------|
| インストール | `brew install btop` |
| GitHub | https://github.com/aristocratos/btop |

---

### エディタ

| ツール | 説明 | インストール |
|--------|------|--------------|
| **neovim** | モダン Vim | `brew install neovim` |
| **vim** | テキストエディタ | `brew install vim` |

---

### バージョン管理

| ツール | 説明 | インストール |
|--------|------|--------------|
| **asdf** | 複数言語バージョン管理 | `brew install asdf` |
| **nvm** | Node.js 管理 | `brew install nvm` |
| **pyenv** | Python 管理 | `brew install pyenv` |
| **tfenv** | Terraform 管理 | `brew install tfenv` |

---

### ユーティリティ

| ツール | 説明 | インストール |
|--------|------|--------------|
| **stow** | シンボリックリンク管理 | `brew install stow` |
| **tree** | ディレクトリツリー表示 | `brew install tree` |
| **nb** | CLI メモ・ブックマーク | `brew install nb` |
| **curl** | HTTP クライアント | `brew install curl` |
| **wget** | ダウンローダー | `brew install wget` |
| **jq** | JSON 処理ツール | `brew install jq` |
| **yq** | YAML/TOML 処理ツール | `brew install yq` |
| **gnupg** | GPG 暗号化 | `brew install gnupg` |

---

### クラウド / AWS

#### AWS CLI

> Amazon Web Services 公式 CLI

| 項目 | 内容 |
|------|------|
| インストール | `brew install awscli` |
| 公式サイト | https://aws.amazon.com/cli/ |

**機能:**
- AWS リソース管理
- Amazon Q（AI アシスタント）搭載
- `aws q chat` でチャット起動

---

## フォント

| フォント | 用途 | インストール |
|---------|------|--------------|
| **Hack Nerd Font** | プログラミング用 | `brew install --cask font-hack-nerd-font` |
| **JetBrains Mono** | プログラミング用 | `brew install --cask font-jetbrains-mono-nerd-font` |

---

## Brewfile の更新

```bash
# 現在の環境を保存
brew bundle dump --force --file=~/dotfiles/Brewfile.full

# 必須ツールのみ編集
vim ~/dotfiles/Brewfile
```
