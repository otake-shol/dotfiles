# Attribution

`explain-visually` は以下から取得したものをそのまま配置している。

- Source: https://github.com/keitakn/engineering-skills (`.claude/skills/explain-visually`)
- License: MIT — Copyright (c) keitakn
- 取得日: 2026-08-30（`gh api` で main の内容を取得）

背景: <https://zenn.dev/avaintelligence/articles/dont-outsource-understanding-to-ai>
（AI開発における「理解負債」への対策として、実装計画・PR・Issue を図解1枚にして人間がレビューする工程）

`~/.claude/skills/` 配下に個人利用として設置。再配布はしない。

## このマシンでの前提（確認済み: 2026-08-30）

- Google Chrome: `/Applications/Google Chrome.app` あり
- python3: 3.9.6（`verify_page.py` は標準ライブラリのみ・`from __future__ import annotations` 済みで動作）
- Mermaid は CDN（jsdelivr）から読む。オフラインおよび Bash サンドボックス内では描画されない

## 上流からの改変

なし。上流の更新に追随しやすいよう無改変で置いている。改変する場合はこの節に差分を記録する。
