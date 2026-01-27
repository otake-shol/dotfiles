# AI Prompts Library

AIメンター/アシスタント用プロンプトのバージョン管理。

## ディレクトリ構成

```
.ai-prompts/
├── README.md              # このファイル
├── gemini/                # Google AI Studio Gems
│   └── *.md               # 1 Gem = 1ファイル
└── claude/
    └── project-templates/ # プロジェクト別CLAUDE.mdテンプレート
```

## 運用ルール

### Git = Single Source of Truth

- プロンプトの**正式版**は常にGitで管理
- 各サービス上での試行錯誤後、良い結果はGitにコミット

### ファイル命名規則

| 種別 | 命名 | 例 |
|------|------|-----|
| Gemini Gem | `<用途>-mentor.md` | `coding-mentor.md` |
| Claude テンプレート | `<プロジェクト種別>.md` | `nextjs-app.md` |

### ワークフロー

```
[編集] Git上でMarkdownを編集
    ↓
[反映] 各サービスにコピペ
    ↓
[検証] 実際に使って調整
    ↓
[保存] 調整結果をGitにコミット
```

### Gemini Gems の同期

1. **Git → Gems**: ファイル内容をGems設定画面にコピペ
2. **Gems → Git**: 調整後のプロンプトをファイルに保存してコミット

※ Gems APIが提供されるまで手動同期

## テンプレート構造

### Gemini Gem テンプレート

```markdown
# <Gem名>

## 役割
<このGemの役割・ペルソナ>

## 指示
<具体的な振る舞いの指示>

## 制約
<やってはいけないこと>

## 出力形式
<期待する回答のフォーマット>
```

## セットアップ

```bash
# dotfilesからシンボリックリンク作成
make install-ai-prompts

# 展開先: ~/.ai-prompts/
```
