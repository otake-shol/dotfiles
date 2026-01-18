# ブラウザ拡張機能管理

dotfilesでブラウザ拡張機能を管理する方法を説明します。

## 📂 ファイル構成

```
dotfiles/
├── browser-extensions/
│   ├── arc.md       # Arc ブラウザの拡張機能
│   ├── chrome.md    # Google Chrome の拡張機能
│   └── firefox.md   # Firefox の拡張機能
└── docs/
    └── BROWSER_EXTENSIONS.md  # このファイル
```

## 🎯 管理方針

ブラウザ拡張機能は以下の理由から、Homebrewのような自動インストールには対応していません：

1. **ブラウザごとに異なるストア**: Chrome Web Store、Firefox Add-ons など
2. **手動承認が必要**: ブラウザで個別に承認・インストールが必要
3. **アカウント同期**: ブラウザのアカウント同期機能で管理可能

そのため、dotfilesでは **ドキュメント管理** のアプローチを採用しています。

## 📝 使い方

### 1. 現在の拡張機能を確認

```bash
# Arc の場合
cat ~/dotfiles/browser-extensions/arc.md

# Chrome の場合
cat ~/dotfiles/browser-extensions/chrome.md

# Firefox の場合
cat ~/dotfiles/browser-extensions/firefox.md
```

### 2. 新しい拡張機能の追加

**ステップ 1: ブラウザに拡張機能をインストール**

各ブラウザのストアから拡張機能をインストールします：

- **Arc / Chrome**: [Chrome Web Store](https://chrome.google.com/webstore)
- **Firefox**: [Firefox Add-ons](https://addons.mozilla.org/)

**ステップ 2: dotfilesに記録**

該当するブラウザのファイル（`arc.md`, `chrome.md`, `firefox.md`）を編集：

```markdown
#### [拡張機能名]
- **用途**: [何に使うか]
- **インストール**: [ストアのURL]
- **説明**: [簡単な説明]
```

**ステップ 3: コミット**

```bash
cd ~/dotfiles
git add browser-extensions/
git commit -m "Add [extension name] to [browser] extensions"
git push
```

### 3. 新しいPCでのセットアップ

新しいMacをセットアップする際：

```bash
# 1. dotfilesをクローン
git clone https://github.com/otake-shol/dotfiles.git ~/dotfiles

# 2. ブラウザ拡張リストを確認
cat ~/dotfiles/browser-extensions/arc.md

# 3. リストを見ながら手動でインストール
```

## 💡 ベストプラクティス

### 拡張機能の選び方

- **最小限に留める**: 拡張機能が多すぎるとブラウザが重くなる
- **信頼できる開発者**: レビューと評価を確認
- **定期的に見直す**: 使わない拡張機能は削除

### カテゴリ分け

拡張機能は以下のカテゴリで分類することを推奨：

1. **生産性向上**: Vimium, Grammarly など
2. **プライバシー・セキュリティ**: 1Password, uBlock Origin など
3. **開発ツール**: React DevTools, Redux DevTools など
4. **ユーティリティ**: Dark Reader, JSONView など

### ドキュメントの書き方

```markdown
#### 拡張機能名
- **用途**: 一言で何に使うか
- **インストール**: ストアのURL
- **説明**: 詳細な説明（オプション）
- **設定**: 特別な設定が必要な場合
```

## 🔧 自動化の可能性

将来的に以下のような自動化が検討できます：

### ブラウザの拡張機能エクスポート

**Chrome系（Arc含む）:**

```bash
# 拡張機能リストをエクスポート（手動）
# chrome://extensions/ にアクセスして一覧をコピー
```

**Firefox:**

```bash
# about:debugging#/runtime/this-firefox にアクセスして一覧を確認
```

### スクリプトでの管理（参考）

```bash
#!/bin/bash
# generate_extension_list.sh（将来の拡張用）

echo "# 現在インストール済みの拡張機能"
echo ""
echo "このスクリプトは参考用です。"
echo "ブラウザから手動で確認してください："
echo "- Chrome/Arc: chrome://extensions/"
echo "- Firefox: about:addons"
```

## 📚 関連ドキュメント

- [APPS.md](APPS.md) - インストール済みアプリケーション一覧
- [README.md](../README.md) - dotfiles全体のドキュメント
- [SETUP.md](SETUP.md) - 詳細セットアップ手順

## 🌐 公式ストアリンク

- **Chrome Web Store**: https://chrome.google.com/webstore
- **Firefox Add-ons**: https://addons.mozilla.org/
- **Microsoft Edge Add-ons**: https://microsoftedge.microsoft.com/addons

## ❓ FAQ

### Q: なぜ自動インストールしないの？

A: ブラウザ拡張機能は以下の理由から手動インストールが必要です：

1. セキュリティ上、ブラウザが個別に承認を求める
2. コマンドラインからの一括インストールAPIが存在しない
3. ブラウザのアカウント同期機能で十分に管理可能

### Q: ブラウザを変更した場合は？

A: 新しいブラウザ用のファイル（例：`edge.md`）を作成してください：

```bash
cp ~/dotfiles/browser-extensions/chrome.md ~/dotfiles/browser-extensions/edge.md
# edge.md を編集
```

### Q: プライベートな拡張機能は？

A: 社内専用などプライベートな拡張機能は、別のプライベートリポジトリで管理することを推奨します。

---

**Note**: このドキュメントは `~/dotfiles/docs/BROWSER_EXTENSIONS.md` にあります。
