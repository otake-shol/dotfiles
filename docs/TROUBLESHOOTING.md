# トラブルシューティング

zsh設定で問題が発生した場合の診断・解決ガイド。

## よくある問題

### 1. コマンドが見つからない（command not found）

#### 症状
```
zsh: command not found: claude
```

#### 診断手順

```bash
# 1. 関数が定義されているか確認
functions claude

# 2. 未定義の場合、lazy.zsh が読み込まれているか確認
echo "ZSH_CONFIG_DIR: $ZSH_CONFIG_DIR"

# 3. 手動で読み込んで動作確認
source ~/.zsh/lazy.zsh
functions claude
```

#### 原因と対処

| 原因 | 対処 |
|------|------|
| `ZSH_CONFIG_DIR` が unset されている | `.aliases` 等で誤って unset していないか確認 |
| lazy.zsh が読み込まれていない | `.zshrc` の読み込み順序を確認 |
| シンボリンクが壊れている | `stow --restow zsh` を実行 |

---

### 2. スペル修正を提案される（correct to ...）

#### 症状
```
zsh: correct 'claude' to '.claude' [nyae]?
```

#### 原因
- `setopt correct` が有効
- コマンド/関数が見つからない

#### 対処

```bash
# 1. 関数が定義されているか確認
functions claude

# 2. 未定義なら lazy.zsh を確認（上記参照）

# 3. 特定コマンドを除外する場合
# ~/.zsh/core.zsh に追加:
CORRECT_IGNORE='_*|claude|mycommand'
```

---

### 3. シンボリンクの問題

#### 診断

```bash
# シンボリンク状態を確認
ls -la ~ | grep -E '\.(zsh|zshrc)'

# 期待される出力（-> で dotfiles を指している）
# .zsh -> dotfiles/stow/zsh/.zsh
# .zshrc -> dotfiles/stow/zsh/.zshrc
```

#### 修復

```bash
cd ~/dotfiles
stow --restow --target=$HOME --dir=stow zsh
```

---

### 4. 起動時に警告が出る

#### 症状
```
⚠️  zsh: 重要な関数が未定義: _asdf_init claude
```

#### 原因
lazy.zsh が正しく読み込まれていない。

#### 対処
1. 上記「コマンドが見つからない」の診断手順を実行
2. `.aliases` で `ZSH_CONFIG_DIR` を unset していないか確認

---

### 5. macOS アップデート後に Apple Watch / Touch ID の sudo 認証が効かない

#### 原因
macOS のアップデートで `/etc/pam.d/sudo` が初期化される場合がある。
`/etc/pam.d/sudo_local` は通常保持されるが、メジャーアップデートでは消える可能性がある。

#### 対処

```bash
# 1. sudo_local の状態を確認
cat /etc/pam.d/sudo_local

# 2. 設定が消えていたら再セットアップ
bash ~/dotfiles/scripts/pam-watchid.sh

# 3. pam_watchid.so 自体が消えている場合もスクリプトが再ビルドする
```

---

## 診断コマンド一覧

```bash
# 全体的な状態確認
echo "CORRECT_IGNORE: $CORRECT_IGNORE"
echo "ZSH_CONFIG_DIR: $ZSH_CONFIG_DIR"
functions claude
functions _asdf_init

# シンボリンク確認
ls -la ~ | grep zsh

# 設定リロード
exec zsh

# 手動でモジュール読み込み
source ~/.zsh/lazy.zsh
```

## 予防策

1. **起動時チェック**: 重要な関数が未定義の場合、警告を表示
2. **このドキュメント**: 問題発生時の手順を参照
