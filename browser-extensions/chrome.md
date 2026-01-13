# Chrome ブラウザ拡張機能

Google Chromeで使用している拡張機能の一覧です。

## 📝 現在インストール済み

### 生産性向上

#### Vimium
- **用途**: キーボードだけでブラウジング
- **インストール**: https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb
- **説明**: Vimキーバインドでページナビゲーション、タブ切り替え、リンク選択が可能

---

## 💡 推奨拡張機能

以下は必要に応じてインストールを検討できる拡張機能です：

### プライバシー・セキュリティ

- **1Password**: パスワード管理
- **Bitwarden**: オープンソースのパスワードマネージャー
- **uBlock Origin**: 広告ブロッカー

### 開発ツール

- **React Developer Tools**: Reactコンポーネントのデバッグ
- **Redux DevTools**: Redux状態管理のデバッグ
- **Vue.js devtools**: Vue.jsアプリケーションのデバッグ
- **Lighthouse**: パフォーマンス測定

### 生産性

- **Grammarly**: 英文法チェック
- **Notion Web Clipper**: Webページをクリップ
- **Raindrop.io**: ブックマーク管理

### ユーティリティ

- **Dark Reader**: ダークモード変換
- **JSONView**: JSON整形表示
- **Octotree**: GitHubコードツリー表示

---

## 🔄 拡張機能の追加方法

1. このファイルに拡張機能情報を追記
2. Chrome Web Store から拡張機能をインストール
3. 変更をコミット

```bash
cd ~/dotfiles
git add browser-extensions/chrome.md
git commit -m "Add [extension name] to Chrome extensions"
git push
```

---

## 📌 メモ

- 拡張機能のインストール先: Chrome Web Store (https://chrome.google.com/webstore)
- 拡張機能が多すぎるとブラウザが重くなるため、必要最小限に留める
- 定期的に使わない拡張機能を無効化・削除すること
