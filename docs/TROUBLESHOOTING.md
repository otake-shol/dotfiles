# トラブルシューティング

zsh設定で問題が発生した場合の診断・解決ガイド。

> 一般的な問題（Homebrew、Oh My Zsh、フォント）は [README.md](../README.md#トラブルシューティング) を参照

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
⚠️  zsh: mise が見つかりません
```

#### 原因
miseがインストールされていない、またはPATHに含まれていない。

#### 対処
1. `brew install mise` を実行
2. シェルを再起動: `exec zsh`

---

## 診断コマンド一覧

```bash
# 全体的な状態確認
echo "CORRECT_IGNORE: $CORRECT_IGNORE"
echo "ZSH_CONFIG_DIR: $ZSH_CONFIG_DIR"
mise doctor

# シンボリンク確認
ls -la ~ | grep zsh

# 設定リロード
exec zsh

# 手動でモジュール読み込み
source ~/.zsh/lazy.zsh
```

## 予防策

1. **lefthook**: `unset` で保護された変数を削除するとコミット時にエラー
2. **起動時チェック**: 重要な関数が未定義の場合、警告を表示
3. **このドキュメント**: 問題発生時の手順を参照
