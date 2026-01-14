# AI駆動開発環境の調査レポート

**作成日**: 2026-01-14
**対象**: Claude Codeを活用したAI駆動開発環境

---

## 現状評価

現在の環境は**非常によく整備されています**。主な強みは：

- ✅ モダンなCLIツール群（bat, eza, fd, ripgrep, fzf, zoxide）
- ✅ Git環境（delta, git-secrets, lazygit）
- ✅ Claude Code + Serena MCP（シンボリック解析）
- ✅ Context7 MCP（ドキュメント参照）
- ✅ Ghostty（高速ターミナル、適切に設定済み）
- ✅ 自動化Hook（Brewfile更新）
- ✅ カスタムエージェント（frontend-engineer）

---

## 不足・改善提案

### 🔴 優先度：高（AI駆動開発に直接影響）

#### 1. Playwright MCP Server

E2Eテストの自動生成・実行をClaude Codeから直接操作可能に

| メリット | デメリット |
|---------|-----------|
| ブラウザ操作を自然言語で指示可能 | ブラウザ起動によるリソース消費 |
| スクリーンショット取得・UI確認 | 初回セットアップに時間がかかる |
| テスト自動生成 | |

**導入方法**: Claude Codeのプラグインマーケットプレイスからインストール

---

#### 2. GitHub MCP Server

Issue/PR操作をClaude Codeから直接実行

| メリット | デメリット |
|---------|-----------|
| Issue作成・更新を会話内で完結 | PAT（Personal Access Token）の管理が必要 |
| PR作成・レビューコメントの自動化 | 権限設定に注意が必要 |
| プロジェクト管理との連携 | |

---

#### 3. uv（Python パッケージマネージャー）

Rust製の超高速Pythonパッケージマネージャー

```bash
brew install uv
```

| メリット | デメリット |
|---------|-----------|
| pip/venvより10-100倍高速 | 比較的新しいツール（エコシステムが発展途上） |
| pyenvの代替としても機能 | 既存のpyenv環境との併用に工夫が必要 |
| Claude Codeとの相性が良い（MCP開発等） | |

---

#### 4. Docker / OrbStack

コンテナ環境（現在Brewfileでコメントアウト）

```bash
# OrbStack推奨（Docker Desktopより軽量・高速）
cask "orbstack"
```

| メリット | デメリット |
|---------|-----------|
| 開発環境の再現性 | リソース消費（OrbStackで軽減可能） |
| AI生成コードの隔離テスト | 学習コスト |
| データベース等の依存管理 | |

---

### 🟡 優先度：中（生産性向上）

#### 5. Aerospace / yabai（ウィンドウマネージャー）

```bash
brew install --cask aerospace  # 推奨：設定が簡単
# または
brew install koekeishiya/formulae/yabai  # 上級者向け
```

| ツール | メリット | デメリット |
|-------|---------|-----------|
| Aerospace | 設定が簡単、i3風のタイル型WM | yabaiより機能が限定的 |
| yabai | 高機能、カスタマイズ性が高い | SIP無効化が必要な機能あり、設定が複雑 |

**共通メリット**: キーボードでウィンドウ操作、Claude Code + エディタ + ブラウザの効率的配置

---

#### 6. Karabiner-Elements

```bash
cask "karabiner-elements"
```

| メリット | デメリット |
|---------|-----------|
| Caps Lock → Ctrl/Escマッピング | 初期設定が複雑 |
| 複雑なキーバインド設定 | システム深部にアクセスするため権限設定が必要 |
| Vim/Emacsユーザーに必須級 | |

---

#### 7. commitizen / cz-cli

Conventional Commitsの強制

```bash
brew install commitizen
```

| メリット | デメリット |
|---------|-----------|
| コミットメッセージの標準化 | 対話式コミットが煩わしい場合も |
| CHANGELOG自動生成の基盤 | チーム全体での導入が望ましい |
| Claude Codeにコミット規約を教える必要が減る | |

---

#### 8. CleanShot X（スクリーンショット/録画）

```bash
cask "cleanshot"
```

| メリット | デメリット |
|---------|-----------|
| 注釈・モザイク機能 | 有料（$29の買い切り） |
| GIF/動画録画 | macOS標準機能でも代用可能 |
| クラウドアップロード（共有が楽） | |
| バグ報告・UI確認に便利 | |

---

### 🟢 優先度：低（あると便利）

#### 9. Ollama（ローカルLLM）

```bash
brew install ollama
```

| メリット | デメリット |
|---------|-----------|
| オフラインでLLM利用可能 | GPUがないと遅い |
| プライバシー重視のタスク | Claude比で品質が劣る |
| Claude APIのコスト削減（単純タスク用） | |

---

#### 10. httpie / xh（HTTPクライアント）

```bash
brew install httpie  # または xh（Rust版、高速）
```

| メリット | デメリット |
|---------|-----------|
| curlより直感的な構文 | curlで十分な場合も多い |
| JSON対応が優秀 | Bruno（既存）との役割重複 |
| API開発・デバッグ効率化 | |

---

## Claude Code設定の改善提案

### 1. 追加のカスタムエージェント

現在 `frontend-engineer` のみ。以下も検討：

```
.claude/agents/
├── frontend-engineer.md  # 既存
├── backend-engineer.md   # API設計、DB設計レビュー
├── code-reviewer.md      # PR review-toolkit相当の機能
├── test-engineer.md      # テスト設計・実装特化
└── devops-engineer.md    # CI/CD、インフラ関連
```

---

### 2. CLAUDE.mdの拡充

現在はテストとBrewfileのルールのみ。以下を追加検討：

```markdown
## コーディング規約
- 命名規則
- ファイル構成ルール
- コメント規約

## セキュリティルール
- 機密情報の取り扱い
- 外部API呼び出し時の注意

## Git運用ルール
- ブランチ命名規則
- コミットメッセージ形式（Conventional Commits）
- PR作成時のチェックリスト
```

---

### 3. プラグインのインストール

現在 `installed_plugins.json` が空。推奨プラグイン：

| プラグイン | 用途 |
|-----------|------|
| `pr-review-toolkit` | PRレビュー自動化 |
| `commit-commands` | /commit, /commit-push-pr |
| `code-review` | コードレビュー |
| `hookify` | カスタムHook簡単作成 |

---

## 即座に追加推奨のBrewfile変更

```ruby
# AI駆動開発強化
brew "uv"              # 高速Pythonパッケージマネージャー
brew "commitizen"      # Conventional Commits

# 開発効率化
cask "orbstack"        # 軽量Docker代替
cask "aerospace"       # タイル型ウィンドウマネージャー
cask "karabiner-elements"  # キーボードカスタマイズ

# オプション
cask "cleanshot"       # スクリーンショット（有料）
brew "ollama"          # ローカルLLM
```

---

## まとめ

| カテゴリ | 現状 | 推奨アクション |
|---------|------|---------------|
| MCPサーバー | 2/7 | Playwright, GitHub追加 |
| コンテナ | なし | OrbStack導入 |
| Python環境 | pyenv | uv追加 |
| ウィンドウ管理 | なし | Aerospace導入 |
| キーボード | 標準 | Karabiner-Elements検討 |
| Git運用 | 良好 | commitizen追加 |
| Claude設定 | 基本的 | エージェント・プラグイン拡充 |

---

## 次のステップ

1. [ ] 優先度高のツールから順にインストール
2. [ ] Claude Codeプラグインのインストール（`/install-plugin`）
3. [ ] カスタムエージェントの追加作成
4. [ ] CLAUDE.mdの拡充
5. [ ] 新しいツールのエイリアス追加（.aliases）
