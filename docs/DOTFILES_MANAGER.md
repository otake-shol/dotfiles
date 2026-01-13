# Dotfiles Manager Agent

アプリケーションをdotfilesに追加する作業を自動化するClaude Code Agentです。

## 🎯 機能

このエージェントは、新しいアプリケーションをdotfilesに追加する際に必要なすべての作業を自動で行います：

1. **Brewfileへの追加** - 適切なセクションにアプリを追加
2. **ドキュメント更新** - `docs/APPS.md` に詳細情報を追加
3. **設定ファイル管理** - 必要に応じてシンボリックリンク設定を追加
4. **自動コミット** - 変更を適切なコミットメッセージでコミット

## 📝 使い方

### 基本的な使い方

Claude Codeのチャットで、以下のように指示するだけです：

```
Ice というアプリを dotfiles に追加して
```

```
htop を必須ツールとして追加
```

```
Docker Desktop を Brewfile に追加して
```

### エージェントの呼び出し方

エージェントは自動的に起動しますが、明示的に呼び出すこともできます：

```
@dotfiles-manager を使って Alacritty を追加
```

## 🔄 動作フロー

### Step 1: 情報収集

エージェントはアプリケーションについて必要な情報を収集します：

- アプリケーション名
- インストール方法（brew cask / brew formula）
- カテゴリ（必須 / オプション）
- 用途・説明

不足している情報があれば、エージェントが質問します。

### Step 2: 既存確認

既にBrewfileに含まれているか確認します。

```bash
# 自動で実行されます
grep -i "app-name" ~/dotfiles/Brewfile ~/dotfiles/Brewfile.full
```

既に存在する場合は、その旨を報告します。

### Step 3: ファイル更新

#### Brewfile への追加

必須ツールの場合は `Brewfile` に、オプションの場合は `Brewfile.full` に追加します：

```ruby
# === GUI Applications ===
cask "jordanbaird-ice"    # メニューバー管理

# === CLI Tools ===
brew "htop"               # インタラクティブなプロセスビューワー
```

#### docs/APPS.md への追加

適切なセクションに詳細情報を追加：

```markdown
#### Ice (jordanbaird-ice)
- **用途**: macOSのメニューバーアイコンを管理・非表示にする
- **インストール**: `brew install --cask jordanbaird-ice`
- **公式**: https://github.com/jordanbaird/Ice
```

### Step 4: コミット

すべての変更を適切なコミットメッセージでコミット：

```
Add Ice to dotfiles

- Add jordanbaird-ice to Brewfile
- Add Ice documentation to docs/APPS.md

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

## 💡 使用例

### 例1: シンプルなCLIツールの追加

**ユーザー：**
```
htop を追加して
```

**エージェントの動作：**
1. htop を検索して CLI ツールであることを確認
2. `Brewfile` の CLI Tools セクションに追加
3. `docs/APPS.md` のユーティリティセクションに詳細を追加
4. コミット

**結果：**
```
✅ htop を dotfiles に追加しました

更新ファイル:
- Brewfile
- docs/APPS.md

次のステップ:
- brew bundle --file=Brewfile でインストール
```

### 例2: GUIアプリケーションの追加

**ユーザー：**
```
Raycast を必須ツールとして追加
```

**エージェントの動作：**
1. Raycast が GUI アプリ（cask）であることを確認
2. カテゴリを確認（必須ツール）
3. `Brewfile` の GUI Applications セクションに追加
4. `docs/APPS.md` に詳細情報を追加
5. コミット

### 例3: 設定ファイル付きアプリの追加

**ユーザー：**
```
Alacritty を追加して、設定ファイルも管理したい
```

**エージェントの動作：**
1. Alacritty を Brewfile に追加
2. docs/APPS.md に追加
3. 設定ファイルの配置について質問
4. `bootstrap.sh` にシンボリックリンク設定を追加
5. `docs/SETUP.md` に手順を追加
6. コミット

### 例4: 既存アプリの確認

**ユーザー：**
```
Ice が既に追加されているか確認して
```

**エージェントの動作：**
1. Brewfile を検索
2. 発見した情報を報告

```
✅ Ice は既に追加されています

Brewfile: cask "jordanbaird-ice" # メニューバー管理
Brewfile.full: cask "jordanbaird-ice"
```

## 🎨 カスタマイズ

### カテゴリの指定

アプリを追加する際にカテゴリを指定できます：

```
Docker を必須ツールとして追加
```

```
Figma をオプションアプリとして追加
```

### 詳細な説明を含める

アプリの用途を明確に指示：

```
htop を追加して。これはシステムモニタリング用のツールです
```

### 設定ファイルの管理

```
Kitty ターミナルを追加して、設定ファイルも dotfiles で管理したい
```

## ⚙️ エージェントの設定

エージェントの定義ファイル：
```
~/dotfiles/.claude/agents/dotfiles-manager.md
```

設定を変更したい場合は、このファイルを編集してください。

## 🔍 トラブルシューティング

### エージェントが起動しない

1. エージェントファイルが存在するか確認：
   ```bash
   ls -la ~/dotfiles/.claude/agents/dotfiles-manager.md
   ```

2. シンボリックリンクが正しいか確認：
   ```bash
   ls -la ~/.claude/agents/
   ```

3. Claude Code を再起動

### アプリが見つからない

Homebrew に存在しないアプリの場合、手動でのインストール方法を案内します。

### 重複エラー

既に追加済みのアプリを追加しようとした場合、エージェントが検出して報告します。

## 📚 関連ドキュメント

- [APPS.md](APPS.md) - アプリケーション一覧
- [SETUP.md](SETUP.md) - セットアップ手順
- [README.md](../README.md) - dotfiles全般のドキュメント

## 🤝 貢献

エージェントの改善提案があれば、以下のファイルを編集してください：

```
~/dotfiles/.claude/agents/dotfiles-manager.md
```

変更後はコミット＆プッシュしてください。

## 📝 TODO

将来的な機能拡張：

- [ ] App Store アプリのサポート（mas経由）
- [ ] VSCode/Cursor 拡張機能の追加サポート
- [ ] アプリの削除機能
- [ ] Brewfile のアルファベット順自動ソート
- [ ] アプリの依存関係チェック
