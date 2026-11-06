# Obsidian Vault での OKF の扱い

Obsidian Vault は既に「1ノート1ファイル＋frontmatter の `type` 必須」で運用しているため、OKF とほぼ互換になっている。Obsidian の操作性（wikilink、Bases のクエリ）を崩さないことを優先し、OKF に完全に合わせる書き換えはしない。

Vault 側の正は Vault の `00_meta/properties-schema.md`（「OKF 互換」節）。このファイルはスキルから見た要点だけを持つ。

## 対応表

| OKF | Vault の扱い | 理由 |
| --- | --- | --- |
| `type`（必須） | そのまま。値は Vault のスキーマの値域（`evergreen` など） | Bases の主キーで、OKF は type の値を問わない |
| `description`（推奨） | 新規ノートで書く（任意フィールドとして追加） | エージェントが本文を開かずに要否を判断できる |
| `title` | 書かない（ファイル名が見出しを兼ねる） | OKF はファイル名から導いてよい |
| `status` | Vault の値（`active` / `waiting` / `done` / `archived`）を維持 | 週次レビューと Bases が依存している。検査器の警告は無視してよい |
| `sources` | 既存の `source`（URL 1件）を維持。複数の出典が要るときだけ `sources` を使う | 既存の記事クリッピングと Web Clipper の出力が `source` |
| リンク | `[[wikilink]]` を維持 | Obsidian のリンク解決・名前変更追従が効かなくなる |
| `index.md` | 既存の `_MOC.md` を維持 | `_MOC.md` は概念ファイルとして扱われ、OKF の適合を崩さない |

## 検査

```bash
node ~/.agents/skills/okf/scripts/check-okf.mjs "<Vault のパス>" --errors-only --ignore 00_templates
```

- エラーは `type` の欠落など適合性の違反。既存ノートは「触ったタイミングで漸進的に揃える」方針（スキーマの設計原則）に従い、一括では直さない
- 警告（`status` の値、wikilink 以外のリンク切れ）は上の対応表で許容しているものが大半
