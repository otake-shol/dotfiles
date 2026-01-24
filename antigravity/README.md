# Antigravity Configuration

Antigravity（Google製VSCode互換エディタ）の設定ファイル。

## ファイル構成

| ファイル | 説明 |
|----------|------|
| `settings.json` | エディタ設定 |
| `keybindings.json` | キーバインド設定 |
| `extensions.txt` | 拡張機能リスト |

## 拡張機能の管理

```bash
# エクスポート（現在の拡張機能をextensions.txtに保存）
./export-extensions.sh

# インストール（extensions.txtから一括インストール）
./install-extensions.sh
```

## 新しいMacへの移行

1. Antigravityをインストール
2. `./install-extensions.sh` を実行
3. `settings.json` と `keybindings.json` を `~/.config/Antigravity/User/` にコピー
