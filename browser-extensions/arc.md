# Arc ブラウザ拡張機能

Arcブラウザで使用している拡張機能の一覧です。

## 📝 現在インストール済み

### 生産性向上

#### Vimium
- **用途**: キーボードだけでブラウジング
- **インストール**: https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb
- **説明**: Vimキーバインドでページナビゲーション、タブ切り替え、リンク選択が可能

### プライバシー・セキュリティ

#### 1Password
- **用途**: パスワード管理
- **インストール**: https://chrome.google.com/webstore/detail/1password/aeblfdkhhhdcdjpifhhbdiojplfjncoa
- **説明**: パスワードの自動入力と管理

---

## 💡 推奨拡張機能

以下は必要に応じてインストールを検討できる拡張機能です：

### 開発ツール

- **React Developer Tools**: Reactコンポーネントのデバッグ
- **Redux DevTools**: Redux状態管理のデバッグ
- **Vue.js devtools**: Vue.jsアプリケーションのデバッグ

### 生産性

- **Grammarly**: 英文法チェック
- **Notion Web Clipper**: Webページをクリップ
- **Bitwarden**: オープンソースのパスワードマネージャー（1Password代替）

### ユーティリティ

- **uBlock Origin**: 広告ブロッカー
- **Dark Reader**: ダークモード変換
- **JSONView**: JSON整形表示

---

## 🔄 拡張機能の追加方法

1. このファイルに拡張機能情報を追記
2. 拡張機能をインストール
3. 変更をコミット

```bash
cd ~/dotfiles
git add browser-extensions/arc.md
git commit -m "Add [extension name] to Arc extensions"
git push
```

---

## 📌 メモ

- Arcは Chromium ベースのため、Chrome Web Store の拡張機能が使用可能
- Arc独自のスペース機能と拡張機能の相性を確認すること
- 拡張機能が多すぎるとブラウザが重くなるため、必要最小限に留める
