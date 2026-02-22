---
description: Markdownスライドを生成（クイック/インタラクティブ）
allowed-tools: Read, Write, Glob, Bash(marp *), Bash(mkdir *), Bash(open *)
---

# /slides - AIスライド生成

Marp CLIを使ってMarkdownからスライド（PDF/HTML/PPTX）を生成する。

## モード判定

ユーザー入力から自動判定：

- **クイックモード**: ファイルパス、URL、または変換対象テキストが含まれている場合
- **インタラクティブモード**: テーマ・トピックのみの場合（対話で構成を練る）

## クイックモード

1. 入力テキスト/ファイルを分析
2. Marp形式のMarkdownに変換
3. 出力先をユーザーに確認
4. 3形式で出力

## インタラクティブモード

1問ずつ順番に聞く（まとめて聞かない）：

1. **対象者は？** - 誰に向けたスライドか
2. **何分の発表？** - スライド枚数の目安を決定（1分=1-2枚）
3. **特に伝えたいことは？** - キーメッセージの特定

回答を元に構成案を提示 → 承認後に生成。

## Marpフロントマター

生成するMarkdownには必ず以下を含める：

```markdown
---
marp: true
paginate: true
size: 16:9
theme: default
---
```

## スライド構成ガイドライン

- 1スライド = 1メッセージ
- 箇条書きは最大5項目
- コードブロックはフォントサイズに注意（長すぎるコードは分割）
- セクション区切りには見出しスライドを使う
- `---` でスライドを区切る

## カスタムテーマ

TokyoNightテーマを使う場合：

```bash
marp --no-stdin slide.md -o slide.pdf --theme ~/.claude/commands/slides-theme.css
```

テーマを使うかどうかはユーザーに確認する。

## 出力

出力先ディレクトリをユーザーに確認した上で、3形式を同時生成：

```bash
marp --no-stdin slide.md -o slide.pdf
marp --no-stdin slide.md -o slide.html
marp --no-stdin slide.md -o slide.pptx
```

注意: `--no-stdin` は必須。省略するとstdin待ちでハングする。

カスタムテーマ使用時は各コマンドに `--theme ~/.claude/commands/slides-theme.css` を追加。

生成後、`open slide.pdf` でプレビューを開く。
