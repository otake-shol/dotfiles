# Raycast Snippets

## ファイル構成

| ファイル | 用途 | Git管理 |
|---------|------|---------|
| `snippets.json` | 公開可能なスニペット | Yes |
| `snippets.local.json` | 個人情報を含むスニペット | **No** |
| `snippets.local.json.example` | ローカル用の雛形 | Yes |

## 注意事項

**個人情報・機密情報は `snippets.local.json` に記載してください。**

以下の情報は `snippets.json` に含めないでください：
- メールアドレス
- 電話番号
- 住所
- APIキー・トークン
- パスワード
- その他の機密情報

## セットアップ

```bash
# 雛形をコピーしてローカルファイルを作成
cp snippets.local.json.example snippets.local.json

# snippets.local.json を編集して個人情報を追加
```

## Raycastへのインポート

1. Raycast を開く
2. Settings > Extensions > Snippets
3. Import Snippets から JSON ファイルをインポート
