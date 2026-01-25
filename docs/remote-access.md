# リモートアクセス設定（iPhone → Mac）

外出先からiPhoneでMacにSSH接続し、Claude Code等を操作する設定。

## 参考記事

- [スマホからClaude Codeを操作する](https://zenn.dev/fuku_tech/articles/bba079706955fd)

## 必要なもの

- Tailscaleアカウント
- Termiusアプリ（iPhone）

## セットアップ手順

### 1. Tailscale（Mac）

```bash
# インストール（brew bundleで自動）
brew install --cask tailscale

# ログイン（GUIが反応しない場合はCLIで）
/Applications/Tailscale.app/Contents/MacOS/Tailscale login
# または
tailscale login  # エイリアス設定済みの場合
```

### 2. リモートログイン有効化（Mac）

**システム設定 → 一般 → 共有 → リモートログイン → ON**

### 3. Tailscale（iPhone）

1. App StoreからTailscaleをインストール
2. 同じアカウントでログイン

### 4. Termius設定（iPhone）

| 項目 | 値 |
|------|-----|
| Host | `tailscale ip -4` で確認したIP または Magic DNS名 |
| Port | `22` |
| Username | macOSユーザー名（`whoami`で確認） |
| Password | macOSログインパスワード |

## 確認コマンド

```bash
tailscale status      # 接続状況・デバイス一覧
tailscale ip -4       # 自分のIPv4アドレス
tailscale ping <host> # 疎通確認
```
