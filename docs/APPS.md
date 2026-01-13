# アプリケーション一覧

このドキュメントは、dotfilesで管理しているアプリケーションとツールの一覧です。

## 📦 インストール方法

### 必須ツールのみ（推奨）
```bash
cd ~/dotfiles
brew bundle --file=Brewfile
```

### 全ツール
```bash
cd ~/dotfiles
brew bundle --file=Brewfile.full
```

---

## 🖥️ GUI アプリケーション

### ターミナル

#### Ghostty
- **用途**: 高速でモダンなGPUアクセラレーションターミナル
- **インストール**: `brew install --cask ghostty`
- **設定**: `~/dotfiles/ghostty/config`
- **公式**: https://ghostty.org/

### ユーティリティ

#### AltTab
- **用途**: Windows風のAlt-Tabウィンドウスイッチャー
- **インストール**: `brew install --cask alt-tab`
- **説明**: macOSのCmd-Tabを、Windowsのようなウィンドウプレビュー付きスイッチャーに置き換える。すべてのウィンドウを一覧表示し、視覚的に切り替え可能
- **公式**: https://alt-tab-macos.netlify.app/
- **GitHub**: https://github.com/lwouis/alt-tab-macos

#### Homerow
- **用途**: キーボードショートカットで画面上のすべてのボタンを操作
- **インストール**: `brew install --cask homerow`
- **説明**: macOSのあらゆるUI要素にキーボードショートカットを割り当て。マウスを使わずに効率的な操作を実現。Vimライクなナビゲーションをシステム全体に拡張
- **公式**: https://www.homerow.app/

#### Ice (jordanbaird-ice)
- **用途**: macOSのメニューバーアイコンを管理・非表示にする
- **インストール**: `brew install --cask jordanbaird-ice`
- **公式**: https://github.com/jordanbaird/Ice

#### Raycast
- **用途**: macOS用の生産性向上ランチャー（Spotlight/Alfred代替）
- **インストール**: `brew install --cask raycast`
- **説明**: 高速でカスタマイズ可能なランチャー。アプリ起動、ファイル検索、計算、スニペット、拡張機能など多機能
- **公式**: https://www.raycast.com/

### ブラウザ

#### Arc
- **用途**: モダンなChromiumベースのウェブブラウザ
- **インストール**: `brew install --cask arc`
- **説明**: スペース機能によるタブ管理、サイドバー型UI、Split View、コマンドバー、美しいデザインが特徴。生産性向上に特化したブラウザ
- **公式**: https://arc.net/

### 生産性

#### Spark
- **用途**: メールクライアント
- **インストール**: `brew install --cask readdle-spark`
- **説明**: Readdle社製の高速でスマートなメールアプリ。複数アカウント管理、スマート通知、チーム機能、美しいデザイン。Gmail、Outlook、iCloudなど主要メールサービスに対応
- **公式**: https://sparkmailapp.com/

#### TickTick
- **用途**: ToDoリスト・タスク管理
- **インストール**: `brew install --cask ticktick`
- **説明**: シンプルで強力なタスク管理アプリ。リマインダー、カレンダー、ポモドーロタイマー、習慣トラッカー機能を搭載。クロスプラットフォーム対応で同期可能
- **公式**: https://www.ticktick.com/

### コミュニケーション

#### Slack
- **用途**: チームコミュニケーション・コラボレーション
- **インストール**: `brew install --cask slack`
- **説明**: ビジネス向けメッセージングアプリ。チャンネル、DM、ファイル共有、アプリ連携など豊富な機能。リモートワークやチーム開発に必須のツール
- **公式**: https://slack.com/

### デザイン

#### Figma
- **用途**: UIデザイン・プロトタイピングツール
- **インストール**: `brew install --cask figma`
- **説明**: ブラウザベースのコラボレーティブデザインツール。UI/UXデザイン、プロトタイピング、デザインシステム管理、リアルタイムコラボレーションが可能
- **公式**: https://www.figma.com/

### 開発ツール

#### Claude CLI
- **用途**: Anthropic Claude AIのコマンドラインインターフェース
- **インストール**: `brew install --cask claude`
- **設定**: `~/dotfiles/.claude/`

#### Multipass
- **用途**: 軽量なLinux VM管理
- **インストール**: `brew install --cask multipass`

#### ngrok
- **用途**: ローカル開発サーバーを外部公開
- **インストール**: `brew install --cask ngrok`

#### Sequel Pro Nightly
- **用途**: MySQL/MariaDBのGUIクライアント
- **インストール**: `brew install --cask sequel-pro-nightly`

---

## ⌨️ CLI ツール

### Git関連

| ツール | 用途 | インストール |
|--------|------|--------------|
| git | バージョン管理システム | `brew install git` |
| gh | GitHub CLI | `brew install gh` |
| git-secrets | AWS認証情報の誤コミット防止 | `brew install git-secrets` |
| lazygit | Git用TUI（ターミナルUI） | `brew install lazygit` |
| tig | Gitのテキストインターフェース | `brew install tig` |

### バージョン管理

| ツール | 用途 | インストール |
|--------|------|--------------|
| asdf | 複数言語のバージョン管理 | `brew install asdf` |
| nvm | Node.jsバージョン管理 | `brew install nvm` |
| nodebrew | Node.jsバージョン管理（代替） | `brew install nodebrew` |
| pyenv | Pythonバージョン管理 | `brew install pyenv` |
| tfenv | Terraformバージョン管理 | `brew install tfenv` |

### エディタ

| ツール | 用途 | インストール |
|--------|------|--------------|
| neovim | モダンなVim | `brew install neovim` |
| vim | テキストエディタ | `brew install vim` |

### シェル・ターミナル

| ツール | 用途 | インストール |
|--------|------|--------------|
| tmux | ターミナルマルチプレクサ | `brew install tmux` |
| fzf | ファジーファインダー（ファイル・コマンド履歴検索） | `brew install fzf` |
| zoxide | 高速ディレクトリナビゲーション（cdの代替） | `brew install zoxide` |
| sheldon | 高速なシェルプラグインマネージャー | `brew install sheldon` |
| starship | クロスシェルプロンプト | `brew install starship` |
| pure | Zshプロンプトテーマ | `brew install pure` |

#### 詳細

**fzf (Fuzzy Finder)**
- コマンドライン上でのファイル検索、コマンド履歴検索、プロセス検索などに使える
- Ctrl+R でコマンド履歴を検索、Ctrl+T でファイルを検索可能
- 公式: https://github.com/junegunn/fzf

**zoxide**
- `cd` の代替コマンド。よく使うディレクトリを記憶し、部分一致で高速移動
- 使用例: `z dotfiles` → `~/dotfiles` に移動
- `cd` より圧倒的に高速なディレクトリ移動を実現
- 公式: https://github.com/ajeetdsouza/zoxide

**sheldon**
- Rust製の高速なシェルプラグインマネージャー
- Oh My Zsh や Prezto の代替として使用可能
- プラグインの並列ダウンロードと遅延読み込みに対応
- 公式: https://sheldon.cli.rs

### 開発言語・ランタイム

| ツール | 用途 | インストール |
|--------|------|--------------|
| node | JavaScript実行環境 | `brew install node` |
| python@3.13 | Python 3.13 | `brew install python@3.13` |
| php | PHPインタープリタ | `brew install php` |
| composer | PHP依存関係管理 | `brew install composer` |
| ruby | Ruby言語 | `brew install ruby` |
| perl | Perl言語 | `brew install perl` |
| yarn | JavaScriptパッケージマネージャー | `brew install yarn` |

### データベース

| ツール | 用途 | インストール |
|--------|------|--------------|
| mysql | MySQLデータベース | `brew install mysql` |
| postgresql@14 | PostgreSQL 14 | `brew install postgresql@14` |

### ユーティリティ

| ツール | 用途 | インストール |
|--------|------|--------------|
| stow | シンボリックリンク管理 | `brew install stow` |
| tree | ディレクトリツリー表示 | `brew install tree` |
| btop | システムモニター | `brew install btop` |
| neofetch | システム情報表示 | `brew install neofetch` |
| curl | HTTPクライアント | `brew install curl` |
| wget | ダウンローダー | `brew install wget` |
| fswatch | ファイル監視ツール | `brew install fswatch` |
| cmatrix | Matrixスクリーンセーバー | `brew install cmatrix` |
| cowsay | アスキーアート | `brew install cowsay` |
| sl | 遊び用コマンド | `brew install sl` |

### セキュリティ

| ツール | 用途 | インストール |
|--------|------|--------------|
| gnupg | GPG暗号化 | `brew install gnupg` |
| pinentry-mac | macOS用PINエントリー | `brew install pinentry-mac` |

### ビルドツール・その他

| ツール | 用途 | インストール |
|--------|------|--------------|
| gradle | Javaビルドツール | `brew install gradle` |
| maven | Javaプロジェクト管理 | `brew install maven` |
| springboot | Spring Boot CLI | `brew install pivotal/tap/springboot` |
| heroku | Heroku CLI | `brew install heroku/brew/heroku` |
| imagemagick | 画像処理 | `brew install imagemagick` |
| pdftk-java | PDF操作 | `brew install pdftk-java` |
| unison | ファイル同期 | `brew install unison` |

---

## 🌐 ブラウザ拡張機能

ブラウザ拡張機能の詳細な管理方法は [docs/BROWSER_EXTENSIONS.md](BROWSER_EXTENSIONS.md) を参照してください。

### 生産性向上

#### Vimium
- **用途**: ブラウザでVimキーバインドを使用
- **対応ブラウザ**: Chrome, Edge, Firefox
- **説明**: キーボードだけでブラウジング可能。リンクナビゲーション、タブ切り替え、ページスクロールなどをVimライクに操作
- **インストール**:
  - Chrome: https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb
  - Firefox: https://addons.mozilla.org/firefox/addon/vimium-ff/
- **公式**: https://github.com/philc/vimium

---

## 🔤 フォント

| フォント | 用途 | インストール |
|---------|------|--------------|
| Hack Nerd Font | プログラミング用フォント | `brew install --cask font-hack-nerd-font` |
| JetBrains Mono Nerd Font | プログラミング用フォント | `brew install --cask font-jetbrains-mono-nerd-font` |

---

## 📝 メモ

### カテゴリ別追加インストール

開発環境に応じて、以下のコマンドで追加インストール可能：

```bash
# フロントエンド開発
brew install node yarn

# バックエンド開発（PHP）
brew install php composer mysql

# バックエンド開発（Python）
brew install python@3.13 pyenv

# データベース
brew install mysql postgresql@14

# インフラ・DevOps
brew install terraform tfenv docker
```

### Brewfileの更新

現在の環境を保存：
```bash
cd ~/dotfiles
brew bundle dump --force --file=Brewfile.full
```

必須ツールのみ保存（手動で編集）：
```bash
vim ~/dotfiles/Brewfile
```
