# GPG コミット署名セットアップガイド

このガイドでは、GPG（GNU Privacy Guard）を使用してGitコミットに署名し、コミットの真正性を証明する方法を説明します。

## 概要

- **GPG署名の目的**: コミットが本人によるものであることを暗号学的に証明
- **GitHub Verified バッジ**: 署名付きコミットには緑色の「Verified」バッジが表示される
- **セキュリティ向上**: なりすましコミットの防止

## 前提条件

```bash
# macOS (Homebrew)
brew install gnupg

# Linux (Debian/Ubuntu)
sudo apt-get install gnupg

# バージョン確認
gpg --version
```

## セットアップ

### 1. GPGキーペアの生成

```bash
# 対話式でキーペアを生成
gpg --full-generate-key
```

以下を選択：
- **鍵の種類**: `RSA and RSA` または `ECC (sign and encrypt)` を推奨
- **鍵長**: RSAなら `4096`、ECCなら `Curve 25519`
- **有効期限**: `1y`（1年）を推奨（後で延長可能）
- **名前**: GitHubアカウントと同じ名前
- **メール**: GitHubに登録しているメールアドレス
- **パスフレーズ**: 強力なパスフレーズを設定

### 2. キーIDの確認

```bash
# 生成したキーを確認
gpg --list-secret-keys --keyid-format=long

# 出力例：
# sec   ed25519/ABC123DEF456GHI7 2024-01-01 [SC] [expires: 2025-01-01]
#       XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# uid                 [ultimate] Your Name <your@email.com>
# ssb   cv25519/XYZ789 2024-01-01 [E] [expires: 2025-01-01]

# キーID は「ed25519/」の後の部分（ABC123DEF456GHI7）
```

### 3. Gitの設定

```bash
# 署名に使用するキーを設定
git config --global user.signingkey ABC123DEF456GHI7

# コミット時に自動で署名
git config --global commit.gpgsign true

# タグにも署名
git config --global tag.gpgsign true

# GPGプログラムのパス指定（必要な場合）
git config --global gpg.program gpg
```

### 4. 公開鍵のエクスポート

```bash
# 公開鍵を表示（GitHubに登録用）
gpg --armor --export ABC123DEF456GHI7
```

### 5. GitHubへの登録

1. **Settings** → **SSH and GPG keys** に移動
2. **New GPG key** をクリック
3. エクスポートした公開鍵（`-----BEGIN PGP PUBLIC KEY BLOCK-----`から`-----END PGP PUBLIC KEY BLOCK-----`まで）を貼り付け
4. **Add GPG key** をクリック

## dotfilesでの設定

このdotfilesには、GPG署名用の設定テンプレートが含まれています。

### git/.gitconfig の設定

```ini
[gpg]
    program = gpg

[commit]
    gpgsign = true

[tag]
    gpgSign = true

[user]
    signingkey = YOUR_KEY_ID
```

### 有効化方法

```bash
# dotfiles/git/.gitconfig を編集して、
# GPG関連の設定のコメントアウトを外す

# または、個別に設定
git config --global commit.gpgsign true
git config --global user.signingkey YOUR_KEY_ID
```

## macOS固有の設定

### GPG Agentとpinentryの設定

```bash
# pinentry-macのインストール
brew install pinentry-mac

# GPG Agentの設定
mkdir -p ~/.gnupg
echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf

# エージェントの再起動
gpgconf --kill gpg-agent
```

### キーチェーンとの連携

パスフレーズをmacOSキーチェーンに保存するには：

```bash
# ~/.gnupg/gpg-agent.conf に追加
default-cache-ttl 600
max-cache-ttl 7200
```

## 使用方法

### 署名付きコミット

```bash
# 自動署名が有効な場合（推奨）
git commit -m "feat: add new feature"

# 手動で署名を指定
git commit -S -m "feat: add new feature"

# 署名を確認
git log --show-signature -1
```

### 署名付きタグ

```bash
# 署名付きタグを作成
git tag -s v1.0.0 -m "Release version 1.0.0"

# タグの署名を確認
git tag -v v1.0.0
```

## トラブルシューティング

### エラー: "gpg failed to sign the data"

```bash
# GPG Agentが正しく動作しているか確認
echo "test" | gpg --clearsign

# TTYの設定を追加（~/.zshrc）
export GPG_TTY=$(tty)
```

### エラー: "secret key not available"

```bash
# キーが正しく設定されているか確認
git config --global user.signingkey

# 秘密鍵が存在するか確認
gpg --list-secret-keys --keyid-format=long
```

### macOSでパスフレーズ入力画面が表示されない

```bash
# pinentry-macが正しく設定されているか確認
cat ~/.gnupg/gpg-agent.conf

# GPG Agentを再起動
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

### SSH経由でのGPG署名

リモートサーバーでGPG署名を使用する場合：

```bash
# エージェント転送を有効化（~/.ssh/config）
Host *
    ForwardAgent yes
```

## キーの管理

### バックアップ

```bash
# 秘密鍵のバックアップ（安全な場所に保管）
gpg --export-secret-keys --armor ABC123DEF456GHI7 > private-key-backup.asc

# 公開鍵のバックアップ
gpg --export --armor ABC123DEF456GHI7 > public-key-backup.asc

# 信頼データベースのバックアップ
gpg --export-ownertrust > trustdb-backup.txt
```

### 有効期限の延長

```bash
# キーの編集
gpg --edit-key ABC123DEF456GHI7

# gpgプロンプトで
gpg> expire
# 新しい有効期限を入力
gpg> save
```

### 失効証明書の作成

キーが漏洩した場合に備えて、事前に失効証明書を作成しておく：

```bash
gpg --gen-revoke ABC123DEF456GHI7 > revoke-cert.asc
# 安全な場所（オフライン）に保管
```

## セキュリティベストプラクティス

1. **パスフレーズの強度**: 20文字以上のランダムな文字列を推奨
2. **有効期限の設定**: 無期限にせず、1〜2年の有効期限を設定
3. **バックアップ**: 秘密鍵と失効証明書をオフラインで安全に保管
4. **サブキーの使用**: 日常使用にはサブキーを使用し、マスターキーはオフラインに保管
5. **キーの分離**: 署名用と暗号化用でサブキーを分ける

## 参考リンク

- [GitHub: Signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
- [GnuPG Documentation](https://www.gnupg.org/documentation/)
- [Git: Signing Your Work](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
