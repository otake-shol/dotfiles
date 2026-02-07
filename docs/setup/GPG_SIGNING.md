# Git コミット署名の設定

GPG署名でコミットの信頼性を担保する。GitHubで「Verified」バッジが表示される。

## 前提条件

```bash
brew install gnupg
```

## 1. GPGキーの確認

```bash
# 既存キーの確認
gpg --list-secret-keys --keyid-format=long

# 出力例:
# sec   ed25519/ABCD1234EFGH5678 2024-05-01 [SC]
#       ↑ このKEY_IDを使用
```

## 2. キーがない場合は生成

```bash
gpg --full-generate-key
```

推奨設定:
- 種類: `ECC (sign only)` または `RSA (4096)`
- 有効期限: 1-2年（定期的なローテーション推奨）

## 3. .gitconfig.local に追加

```ini
[user]
    signingkey = YOUR_KEY_ID
```

## 4. .gitconfig のGPG設定を有効化

`~/.gitconfig` の該当セクションをコメントアウト解除:

```ini
[gpg]
    program = /opt/homebrew/bin/gpg

[commit]
    gpgsign = true
```

## 5. GitHub に公開鍵を登録

```bash
# 公開鍵をクリップボードにコピー
gpg --armor --export YOUR_KEY_ID | pbcopy
```

GitHub → Settings → SSH and GPG keys → New GPG key に貼り付け。

## 6. pinentry設定（オプション）

TTYでパスフレーズ入力を有効化:

```bash
echo "pinentry-program /opt/homebrew/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
gpgconf --kill gpg-agent
```

## トラブルシューティング

### 署名エラー: "error: gpg failed to sign the data"

```bash
# GPGエージェント再起動
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# TTY設定確認
export GPG_TTY=$(tty)
```

### キャッシュ時間の延長

`~/.gnupg/gpg-agent.conf`:

```
default-cache-ttl 86400
max-cache-ttl 86400
```

## 参考

- [GitHub: Signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
- [GnuPG Documentation](https://gnupg.org/documentation/)
