# Firefox ブラウザ拡張機能

Firefoxで使用している拡張機能の一覧です。

## 📝 現在インストール済み

### 生産性向上

#### Vimium-FF
- **用途**: キーボードだけでブラウジング
- **インストール**: https://addons.mozilla.org/firefox/addon/vimium-ff/
- **説明**: Vimキーバインドでページナビゲーション、タブ切り替え、リンク選択が可能（Firefox版）

---

## 💡 推奨拡張機能

以下は必要に応じてインストールを検討できる拡張機能です：

### プライバシー・セキュリティ

- **1Password**: パスワード管理
- **Bitwarden**: オープンソースのパスワードマネージャー
- **uBlock Origin**: 広告ブロッカー
- **Privacy Badger**: トラッキング防止

### 開発ツール

- **React Developer Tools**: Reactコンポーネントのデバッグ
- **Redux DevTools**: Redux状態管理のデバッグ
- **Vue.js devtools**: Vue.jsアプリケーションのデバッグ

### 生産性

- **Grammarly**: 英文法チェック
- **Notion Web Clipper**: Webページをクリップ
- **Raindrop.io**: ブックマーク管理

### ユーティリティ

- **Dark Reader**: ダークモード変換
- **JSONView**: JSON整形表示

---

## 🔄 拡張機能の追加方法

1. このファイルに拡張機能情報を追記
2. Firefox Add-ons から拡張機能をインストール
3. 変更をコミット

```bash
cd ~/dotfiles
git add browser-extensions/firefox.md
git commit -m "Add [extension name] to Firefox extensions"
git push
```

---

## 📌 メモ

- 拡張機能のインストール先: Firefox Add-ons (https://addons.mozilla.org/)
- Firefox は Chrome/Edge と異なり、独自のアドオンシステムを使用
- プライバシー保護機能が強力なため、セキュリティ系拡張との相性が良い
- 定期的に使わない拡張機能を無効化・削除すること
