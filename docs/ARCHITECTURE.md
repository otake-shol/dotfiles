# アーキテクチャ

dotfilesの構造と依存関係を図示します。

## ディレクトリ構造

```
dotfiles/
├── bootstrap.sh           # エントリーポイント（初回セットアップ）
├── Makefile               # Stow操作インターフェース
├── Brewfile               # パッケージ定義
│
├── stow/                  # GNU Stowパッケージ群
│   ├── zsh/               # シェル設定（メイン）
│   ├── git/               # Git設定
│   ├── nvim/              # Neovim設定
│   ├── ghostty/           # ターミナル設定
│   ├── bat/               # bat設定
│   ├── atuin/             # シェル履歴設定
│   ├── yazi/              # ファイルマネージャー設定
│   ├── claude/            # Claude Code設定
│   ├── gh/                # GitHub CLI設定
│   ├── ssh/               # SSH設定（テンプレート）
│   └── antigravity/       # エディタ設定（非Stow）
│
├── scripts/               # ユーティリティスクリプト
│   ├── lib/               # 共通ライブラリ
│   ├── setup/             # セットアップスクリプト
│   ├── maintenance/       # メンテナンススクリプト
│   └── utils/             # ヘルパースクリプト
│
└── docs/                  # ドキュメント
```

## Zsh 読み込みフロー

```mermaid
flowchart TD
    subgraph "起動時（instant prompt）"
        A[".zshrc"] --> B["Powerlevel10k<br>instant prompt"]
    end

    subgraph "プラグイン初期化"
        B --> C["plugins.zsh"]
        C --> C1["cache.zsh<br>（キャッシュユーティリティ）"]
        C --> C2["Oh My Zsh"]
        C --> C3["zsh-autosuggestions"]
        C --> C4["zsh-syntax-highlighting"]
        C --> C5["zsh-completions"]
    end

    subgraph "基本設定"
        C --> D["core.zsh"]
        D --> D1["エディタ設定"]
        D --> D2["History設定"]
        D --> D3["Zshオプション"]
        D --> E[".aliases"]
        E --> E1["aliases/*.zsh"]
        E --> E2["functions/*.zsh"]
    end

    subgraph "遅延読み込み"
        D --> F["lazy.zsh"]
        F --> F1["asdf<br>（初回使用時）"]
        F --> F2["direnv<br>（precmd hook）"]
        F --> F3["atuin<br>（キャッシュ）"]
        F --> F4["fzf関数<br>（初回呼び出し時）"]
    end

    subgraph "ツール設定"
        F --> G["tools.zsh"]
        G --> G1["fzf オプション"]
        G --> G2["zoxide<br>（キャッシュ）"]
        G --> G3["yazi関数"]
        G --> G4["bun"]
        G --> G5["PATH設定"]
        G --> G6["更新リマインダー"]
    end

    subgraph "最終処理"
        G --> H[".p10k.zsh<br>（テーマ設定）"]
        H --> I[".zshrc.local<br>（ローカル設定）"]
    end

    style A fill:#7aa2f7
    style B fill:#bb9af7
    style C fill:#9ece6a
    style D fill:#e0af68
    style E fill:#e0af68
    style F fill:#7dcfff
    style G fill:#f7768e
    style H fill:#bb9af7
    style I fill:#565f89
```

## スクリプト依存関係

```mermaid
flowchart LR
    subgraph "共通ライブラリ"
        L1["common.sh"]
        L2["os_detect.sh"]
        L1 --> L2
    end

    subgraph "セットアップ"
        S1["bootstrap.sh"]
        S2["macos_defaults.sh"]
        S1 --> L1
        S1 --> S2
    end

    subgraph "メンテナンス"
        M1["verify_setup.sh"]
        M2["update_all.sh"]
        M3["check_updates.sh"]
        M4["sync_brewfile.sh"]
        M1 --> L1
        M2 --> L1
        M3 --> L1
        M4 --> L1
    end

    subgraph "ユーティリティ"
        U1["dothelp.sh"]
        U2["zsh_benchmark.sh"]
        U3["setup_ssh.sh"]
        U1 --> L1
        U2 --> L1
        U3 --> L1
    end
```

## Stow パッケージ構成

| パッケージ | 管理方式 | 理由 |
|-----------|---------|------|
| zsh | Stow | 標準的なホームディレクトリ配置 |
| git | Stow | 標準的なホームディレクトリ配置 |
| nvim | Stow | XDG準拠（~/.config/nvim） |
| ghostty | Stow | XDG準拠（~/.config/ghostty） |
| bat | Stow | XDG準拠（~/.config/bat） |
| atuin | Stow | XDG準拠（~/.config/atuin） |
| yazi | Stow | XDG準拠（~/.config/yazi） |
| claude | Stow | ~/.claude/ ディレクトリ |
| gh | Stow | XDG準拠（~/.config/gh） |
| ssh | **テンプレート** | 機密情報を含む可能性があるため |
| antigravity | **手動リンク** | macOS固有パス（~/Library/Application Support/） |

## テーマ統一（TokyoNight）

```mermaid
flowchart TD
    T["TokyoNight テーマ"]
    T --> N["Neovim<br>init.lua"]
    T --> G["Ghostty<br>config"]
    T --> F["fzf<br>FZF_DEFAULT_OPTS"]
    T --> B["bat<br>themes/"]
    T --> Y["yazi<br>theme.toml"]

    style T fill:#7aa2f7
```

## キャッシュ戦略

| 対象 | キャッシュ場所 | TTL | 更新トリガー |
|------|---------------|-----|-------------|
| zsh-plugin-cache | ~/.cache/ | 7日 | 手動 or TTL超過 |
| atuin-init.zsh | ~/.cache/ | 7日 | TTL超過 |
| zoxide-init.zsh | ~/.cache/ | 7日 | TTL超過 |
| zcompdump | ~/.cache/ | 24時間 | TTL超過 |
| dotfiles-reminder | ~/.cache/ | 7日 | TTL超過 |

## セキュリティ設計

```mermaid
flowchart LR
    subgraph "Git管理外（.gitignore）"
        L1[".gitconfig.local<br>（個人情報）"]
        L2[".zshrc.local<br>（環境変数）"]
        L3["~/.ssh/config<br>（機密情報）"]
    end

    subgraph "テンプレート（Git管理）"
        T1[".gitconfig.local.template"]
        T2[".zshrc.local.template"]
        T3["config.template"]
    end

    subgraph "保護機構"
        P1["git-secrets<br>（コミット前スキャン）"]
        P2["lefthook<br>（pre-commit hooks）"]
    end

    T1 -.-> L1
    T2 -.-> L2
    T3 -.-> L3

    P1 --> |"AWS/GitHub/OpenAI<br>キーパターン検出"| L1
    P1 --> |"AWS/GitHub/OpenAI<br>キーパターン検出"| L2
    P2 --> |"機密情報チェック"| P1
```
