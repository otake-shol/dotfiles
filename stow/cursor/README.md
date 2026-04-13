# cursor

Cursor エディタ用の拡張機能リスト管理。

## 構成

- `.config/cursor/extensions.txt` — 管理下の拡張ID一覧（1行1ID、`#` でコメント）

## 使い方

```bash
# 現状との差分を確認
make cursor-diff

# リストに合わせて追加/削除を実行
make cursor-sync
```

`cursor-sync` は `extensions.txt` にない拡張を **アンインストール** し、足りないものをインストールする。追加・削除は `extensions.txt` を編集してコミット → `make cursor-sync` で反映。
