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

<img src="https://ghostty.org/og-image.png" width="600" alt="Ghostty">

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

<img src="https://www.raycast.com/og-image.png" width="600" alt="Raycast">

> Spotlight を超える生産性ランチャー

| 項目 | 内容 |
|------|------|
| インストール | `brew install --cask raycast` |
| 公式サイト | https://www.raycast.com/ |

**特徴:**
- 高速なアプリ起動・ファイル検索
- スニペット・クリップボード履歴
- 拡張機能エコシステム
- ウィンドウ管理・計算機

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

<img src="https://www.homerow.app/homerow-og-image.png" width="600" alt="Homerow">

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

### ブラウザ

#### Arc

<img src="https://arc.net/og-image.png" width="600" alt="Arc">

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

<img src="https://sparkmailapp.com/images/share/spark-share.png" width="600" alt="Spark">

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

<img src="https://www.ticktick.com/static/img/og-image.png" width="600" alt="TickTick">

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

<img src="https://cdn.sanity.io/images/599r6htc/localized/b58bb1fc1c5e5b099e42635da4c47f5fc8c90e56-2400x1260.png" width="600" alt="Figma">

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

## CLI ツール

### Git 関連

| ツール | 説明 | インストール |
|--------|------|--------------|
| **git** | バージョン管理 | `brew install git` |
| **gh** | GitHub CLI | `brew install gh` |
| **lazygit** | Git TUI | `brew install lazygit` |
| **git-secrets** | 認証情報漏洩防止 | `brew install git-secrets` |
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

#### bat

<img src="https://camo.githubusercontent.com/7b7c397acc5b91b4c4cf7756015185fe3c5f700f70d256a212de51294a0cf673/68747470733a2f2f696d6775722e636f6d2f724773646e44652e706e67" width="600" alt="bat">

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
