# SOPS + age によるシークレット管理

このガイドでは、SOPS（Secrets OPerationS）と age を使用して、dotfiles内の機密情報を安全に暗号化する方法を説明します。

## 概要

- **SOPS**: Mozillaが開発した暗号化ツール。YAML/JSON/ENV/INI形式のファイルを暗号化
- **age**: シンプルで安全な暗号化ツール。GPGの代替として利用可能

## インストール

```bash
# macOS (Homebrew)
brew install sops age

# Linux (Debian/Ubuntu)
sudo apt-get install age
# SOPSは公式リリースからダウンロード
curl -LO https://github.com/getsops/sops/releases/latest/download/sops-v3.8.1.linux.amd64
sudo mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops
```

## セットアップ

### 1. age キーペアの生成

```bash
# キーディレクトリ作成
mkdir -p ~/.config/sops/age

# キーペア生成
age-keygen -o ~/.config/sops/age/keys.txt

# パーミッション設定
chmod 600 ~/.config/sops/age/keys.txt
```

生成されたファイルの内容例：
```
# created: 2024-01-01T00:00:00Z
# public key: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
AGE-SECRET-KEY-1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### 2. SOPS設定ファイルの作成

dotfilesルートに `.sops.yaml` を作成：

```yaml
# .sops.yaml
creation_rules:
  # 暗号化するファイルパターンと使用するキーを指定
  - path_regex: secrets/.*\.ya?ml$
    age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

  - path_regex: \.env\.encrypted$
    age: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 3. 環境変数の設定

```bash
# ~/.zshrc.local に追加
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
```

## 使用方法

### ファイルの暗号化

```bash
# 新規ファイルを暗号化して作成
sops secrets/api-keys.yaml

# 既存ファイルを暗号化
sops -e secrets/plaintext.yaml > secrets/encrypted.yaml

# インプレースで暗号化
sops -e -i secrets/config.yaml
```

### ファイルの復号

```bash
# エディタで開く（自動復号・保存時に暗号化）
sops secrets/api-keys.yaml

# 標準出力に復号
sops -d secrets/api-keys.yaml

# ファイルに復号
sops -d secrets/encrypted.yaml > secrets/decrypted.yaml
```

### 部分的な暗号化

SOPSはキーは平文のまま、値のみを暗号化します：

```yaml
# 元のファイル
api_key: sk-xxxxxxxx
database_url: postgres://user:pass@localhost/db

# 暗号化後
api_key: ENC[AES256_GCM,data:xxxxx,iv:xxxxx,tag:xxxxx,type:str]
database_url: ENC[AES256_GCM,data:xxxxx,iv:xxxxx,tag:xxxxx,type:str]
sops:
    age:
        - recipient: age1xxxxx
          enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            ...
```

## dotfilesでの活用例

### 1. API キーの管理

```yaml
# secrets/api-keys.yaml
github_token: ghp_xxxxxxxxxxxx
openai_key: sk-xxxxxxxxxxxx
anthropic_key: sk-ant-xxxxxxxxxxxx
```

### 2. .zshrc.local での読み込み

```bash
# ~/.zshrc.local

# SOPS暗号化ファイルから環境変数を読み込む
if command -v sops &>/dev/null && [[ -f ~/dotfiles/secrets/api-keys.yaml ]]; then
    eval "$(sops -d ~/dotfiles/secrets/api-keys.yaml | yq -o=shell)"
fi
```

### 3. Git設定

```bash
# secrets/ ディレクトリをgitignoreに追加しない
# （暗号化されているのでコミット可能）

# ただし、平文のキーファイルは絶対にコミットしない
echo "*.txt" >> ~/.config/sops/age/.gitignore
```

## セキュリティベストプラクティス

1. **キーファイルの保護**
   - `~/.config/sops/age/keys.txt` は絶対にコミットしない
   - パーミッションは 600 に設定
   - バックアップは安全な場所に保管

2. **複数マシンでの運用**
   - 各マシンで個別のキーペアを生成
   - `.sops.yaml` に複数の公開鍵を登録

3. **キーのローテーション**
   ```bash
   # 新しいキーで再暗号化
   sops updatekeys secrets/api-keys.yaml
   ```

4. **緊急時の対応**
   - キーが漏洩した場合は即座に新しいキーペアを生成
   - 全ての暗号化ファイルを新しいキーで再暗号化
   - 漏洩した認証情報は全て無効化

## トラブルシューティング

### エラー: "could not find age identity"

```bash
# SOPS_AGE_KEY_FILE が正しく設定されているか確認
echo $SOPS_AGE_KEY_FILE
cat $SOPS_AGE_KEY_FILE
```

### エラー: "no matching keys found"

`.sops.yaml` の公開鍵と、暗号化時に使用した公開鍵が一致しているか確認。

### ファイルが暗号化されない

`.sops.yaml` の `path_regex` パターンがファイルパスにマッチしているか確認。

## 参考リンク

- [SOPS GitHub](https://github.com/getsops/sops)
- [age GitHub](https://github.com/FiloSottile/age)
- [SOPS Documentation](https://getsops.io/)
