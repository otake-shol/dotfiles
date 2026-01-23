# AI駆動開発環境 完全ガイド

**最終更新**: 2026-01-15
**対象**: 新しいMacや環境でAI駆動開発環境を構築するエンジニア

---

## 概要

このガイドでは、AI駆動開発に必要な設定を網羅的に解説します。環境が変わってもスムーズに開発を始められるよう、以下の領域をカバーしています：

| 領域 | 内容 |
|------|------|
| [1. Claude Code](#1-claude-code) | CLI AIアシスタント、MCP、hooks、commands |
| [2. エディタ統合](#2-エディタ統合) | VS Code、Cursor、Antigravity + AI機能 |
| [3. Git/GitHub](#3-gitgithub) | gh CLI、テンプレート、git-secrets |
| [4. ターミナル](#4-ターミナル) | Ghostty、tmux、Zsh |
| [5. セキュリティ](#5-セキュリティ) | 認証情報保護、環境変数管理 |
| [6. プロンプト管理](#6-プロンプト管理) | スニペット、テンプレート |
| [7. 仕様駆動開発](#7-仕様駆動開発) | 仕様定義、TDD/BDD、トレーサビリティ |

---

## 1. Claude Code

### 1.1 基本設定

Claude CodeはCLIベースのAIアシスタントで、コーディング作業を強力にサポートします。

#### インストール
```bash
brew install claude  # Homebrew経由
# または
npm install -g @anthropic-ai/claude-code
```

#### 設定ファイルの配置
```bash
# dotfilesからシンボリックリンク
mkdir -p ~/.claude
ln -sf ~/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/dotfiles/.claude/settings.json ~/.claude/settings.json
ln -sf ~/dotfiles/.claude/agents ~/.claude/agents
ln -sf ~/dotfiles/.claude/hooks ~/.claude/hooks
ln -sf ~/dotfiles/.claude/commands ~/.claude/commands
ln -sf ~/dotfiles/.claude/plugins ~/.claude/plugins
```

### 1.2 CLAUDE.md（グローバル指示）

`~/.claude/CLAUDE.md` はClaude Codeに対するグローバルな指示を定義するファイルです。

**推奨設定項目：**
- テストコード品質の基準
- コードスタイルガイドライン
- 禁止事項（ハードコーディング等）
- プロジェクト固有のルール

### 1.3 settings.json（権限設定）

`~/.claude/settings.json` でツールの許可・拒否を設定します。

```json
{
  "permissions": {
    "allow": [
      "Bash(npm:*)",
      "Bash(git:*)",
      "Bash(brew:*)"
    ],
    "deny": [
      "Bash(curl|wget:*:--insecure)",
      "Bash(rm:-rf /*)"
    ]
  }
}
```

### 1.4 Hooks（自動化）

hooksディレクトリにスクリプトを配置して、特定のイベントで自動実行できます。

**例: Brewfile自動更新フック**
```bash
# ~/.claude/hooks/update-brewfile.sh
#!/bin/bash
cd ~/dotfiles && brew bundle dump --force --file=Brewfile.full
```

### 1.5 Commands（カスタムコマンド）

`~/.claude/commands/` にMarkdownファイルを配置すると、`/コマンド名` で呼び出せます。

### 1.6 Agents（専門エージェント）

`~/.claude/agents/` に専門エージェントを定義できます。

| エージェント | 用途 |
|-------------|------|
| code-reviewer.md | コードレビュー |
| test-engineer.md | テスト作成 |
| frontend-engineer.md | フロントエンド開発 |
| backend-engineer.md | バックエンド開発 |
| devops-engineer.md | インフラ・CI/CD |

### 1.7 MCPサーバー

MCPサーバーでClaude Codeの機能を拡張できます。

#### 必須級（推奨）
| サーバー | 用途 | 設定 |
|---------|------|------|
| Context7 | リアルタイムドキュメント参照 | 認証不要 |
| Serena | シンボリックコード解析（LSP統合） | 認証不要 |
| Playwright | ブラウザ自動化・E2Eテスト | 認証不要 |
| GitHub | Issue/PR管理 | PAT必要 |
| Sequential Thinking | 構造化された問題解決 | 認証不要 |

#### 設定ファイル
MCPサーバーは `~/.claude/settings.json` または `~/.claude/settings.local.json` で設定します。

詳細は [mcp-servers-guide.md](mcp-servers-guide.md) を参照してください。

---

## 2. エディタ統合

### 2.1 Antigravity（推奨）

Google製のモダンエディタ。AI機能が統合されています。

```bash
# ファイルを開く
open -a "Antigravity" <ファイルパス>
```

#### 拡張機能管理
```bash
# 拡張機能リストのエクスポート
~/dotfiles/antigravity/export-extensions.sh

# 拡張機能の一括インストール
~/dotfiles/antigravity/install-extensions.sh
```

詳細は [antigravity-extensions.md](antigravity-extensions.md) を参照。

### 2.2 VS Code / Cursor

AI補完を活用するための設定：

#### 推奨拡張機能
```
# AI関連
claude-ai.claude-vscode       # Claude公式
github.copilot               # GitHub Copilot
continue.continue            # Continue（オープンソースAI補完）

# 開発効率
esbenp.prettier-vscode
dbaeumer.vscode-eslint
```

#### settings.json
```json
{
  "editor.inlineSuggest.enabled": true,
  "editor.formatOnSave": true,
  "github.copilot.enable": {
    "*": true
  }
}
```

### 2.3 Neovim + AI

Neovimでも AI補完を利用できます。

**推奨プラグイン：**
- `zbirenbaum/copilot.lua` - GitHub Copilot
- `jackMort/ChatGPT.nvim` - ChatGPT統合
- `David-Kunz/gen.nvim` - ローカルLLM統合

---

## 3. Git/GitHub

### 3.1 GitHub CLI (gh)

```bash
# インストール
brew install gh

# 認証
gh auth login

# 設定確認
gh auth status
```

#### 便利なエイリアス（.aliasesに追加済み）
```bash
alias ghpr='gh pr create'
alias ghpv='gh pr view --web'
alias ghic='gh issue create'
```

### 3.2 コミットテンプレート

```bash
# テンプレートの設定
git config --global commit.template ~/dotfiles/git/commit-template.txt
```

### 3.3 git-secrets（認証情報保護）

```bash
# インストール
brew install git-secrets

# グローバル設定
git secrets --install ~/.git-templates/git-secrets
git secrets --register-aws --global
```

### 3.4 .gitignore グローバル設定

```bash
git config --global core.excludesfile ~/dotfiles/git/.gitignore_global
```

---

## 4. ターミナル

### 4.1 Ghostty

高速でモダンなターミナルエミュレータ。

```bash
# 設定のシンボリックリンク
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/ghostty/config ~/.config/ghostty/config
```

**推奨設定（config）：**
```
font-family = "JetBrains Mono Nerd Font"
font-size = 14
theme = tokyo-night
```

### 4.2 tmux

ターミナルマルチプレクサ。

```bash
ln -sf ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
```

### 4.3 Zsh + Oh My Zsh

```bash
# Oh My Zshインストール
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10kテーマ
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# プラグイン
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

---

## 5. セキュリティ

### 5.1 環境変数管理

機密情報は環境変数で管理し、dotfilesにはコミットしません。

```bash
# ~/.zshrc.local（gitignoreに追加）に記載
export GITHUB_PERSONAL_ACCESS_TOKEN="ghp_xxxxx"
export OPENAI_API_KEY="sk-xxxxx"
export ANTHROPIC_API_KEY="sk-ant-xxxxx"
```

### 5.2 direnv

ディレクトリごとに環境変数を自動設定。

```bash
brew install direnv

# .zshrcに追加
eval "$(direnv hook zsh)"

# プロジェクトごとに.envrcを作成
echo 'export DATABASE_URL="..."' > .envrc
direnv allow
```

### 5.3 認証情報保護チェックリスト

- [ ] `.env`ファイルが`.gitignore`に含まれている
- [ ] `git-secrets`がインストールされている
- [ ] APIキーは環境変数で管理している
- [ ] PATは最小限の権限で発行している

---

## 6. プロンプト管理

### 6.1 Raycast スニペット

Raycastのスニペット機能でプロンプトを管理できます。

**設定場所：** `~/dotfiles/raycast/`

### 6.2 Espanso（テキスト展開）

```bash
brew install espanso

# 設定
mkdir -p ~/.config/espanso
ln -sf ~/dotfiles/espanso/match/base.yml ~/.config/espanso/match/base.yml
```

### 6.3 AIプロンプトテンプレート

詳細は [AI-PROMPTS.md](AI-PROMPTS.md) を参照。

---

## 7. 仕様駆動開発

### 7.1 概要

仕様駆動開発（Spec-Driven Development）は、実装前に仕様を明確に定義し、その仕様に基づいてテストと実装を進めるアプローチです。Claude Codeを活用することで、仕様の曖昧さを早期に発見し、テストケースを自動生成できます。

### 7.2 推奨プロジェクト構成

```
project/
├── .claude/
│   └── CLAUDE.md          # プロジェクト固有の指示
├── specs/                  # 仕様ドキュメント
│   ├── features/          # 機能仕様
│   ├── api/               # API仕様（OpenAPI等）
│   └── data-models/       # データモデル仕様
├── tests/
└── src/
```

### 7.3 開発フロー

```
仕様定義 → 仕様レビュー → テスト作成 → 実装 → 検証
    ↑                                        ↓
    ←←←← フィードバック ←←←←←←←←←←←←←←←←←←←
```

1. **仕様定義**: 機能仕様、API仕様、データモデルを文書化
2. **仕様レビュー**: Claude Codeで曖昧さ・漏れを検出
3. **テスト作成**: 仕様からテストケースを自動生成（TDD）
4. **実装**: 仕様とテストに基づいて実装
5. **検証**: 仕様との整合性を確認

### 7.4 Claude Codeの活用

```bash
# 仕様レビュー
"specs/features/auth.md の仕様をレビューし、曖昧な点を指摘してください"

# 仕様からテスト生成
"specs/features/auth.md の受け入れ基準に基づいてテストケースを生成してください"

# 整合性確認
"実装が仕様と整合しているか確認してください"
```

### 7.5 MCPサーバーの活用

| MCP | 用途 |
|-----|------|
| Sequential Thinking | 複雑な仕様の段階的分析 |
| Serena | コードと仕様の整合性確認 |
| Playwright | E2Eテストによる仕様検証 |

詳細は [SPEC-DRIVEN-DEV.md](SPEC-DRIVEN-DEV.md) を参照。

---

## クイックセットアップチェックリスト

新しい環境でのセットアップ時に確認してください：

### 必須
- [ ] Homebrew インストール済み
- [ ] dotfiles クローン済み
- [ ] Claude Code インストール済み
- [ ] `~/.claude/` の設定ファイルがリンク済み
- [ ] MCPサーバー（最低限Context7, Serena）が設定済み
- [ ] GitHub CLI (`gh`) にログイン済み
- [ ] git-secrets 設定済み

### 推奨
- [ ] Ghostty + Nerd Font 設定済み
- [ ] Oh My Zsh + Powerlevel10k 設定済み
- [ ] tmux 設定済み
- [ ] direnv 設定済み
- [ ] エディタ（Antigravity/VS Code/Cursor）のAI拡張設定済み

### オプション
- [ ] Raycast スニペット設定済み
- [ ] Espanso 設定済み
- [ ] 追加MCPサーバー（Playwright, GitHub等）設定済み

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [SETUP.md](SETUP.md) | 詳細セットアップ手順 |
| [mcp-servers-guide.md](mcp-servers-guide.md) | MCPサーバー設定ガイド |
| [APPS.md](APPS.md) | アプリケーション一覧 |
| [AI-PROMPTS.md](AI-PROMPTS.md) | AIプロンプトテンプレート集 |
| [SPEC-DRIVEN-DEV.md](SPEC-DRIVEN-DEV.md) | 仕様駆動開発ガイド |
| [antigravity-extensions.md](antigravity-extensions.md) | Antigravity拡張機能 |

---

## 参考リンク

- [Claude Code 公式ドキュメント](https://docs.anthropic.com/claude-code)
- [MCP (Model Context Protocol)](https://modelcontextprotocol.io/)
- [GitHub does dotfiles](https://dotfiles.github.io/)
