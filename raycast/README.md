# Raycast Scripts

macOS日本語入力のユーザー辞書を管理するRaycast Script Commands。

## スクリプト一覧

| スクリプト | 説明 |
|-----------|------|
| `add-to-dictionary.sh` | ユーザー辞書に単語を登録 |
| `list-dictionary.sh` | ユーザー辞書一覧を表示 |
| `delete-from-dictionary.sh` | ユーザー辞書から単語を削除 |

## Raycastへの登録方法

1. Raycastを開く
2. `Import Script Command` と入力
3. `~/dotfiles/raycast/scripts/` ディレクトリを選択
4. 全てのスクリプトを選択してインポート

または、Raycast設定から：
1. `Raycast Settings` → `Extensions` → `Script Commands`
2. `Add Directories` をクリック
3. `~/dotfiles/raycast/scripts/` を追加

## 使い方

### 辞書に登録
Raycastで「ユーザー辞書に登録」と入力し、読みと単語を入力。

### 辞書一覧
Raycastで「ユーザー辞書一覧」と入力。

### 辞書から削除
Raycastで「ユーザー辞書から削除」と入力し、削除したい読みを入力。

## 注意事項

- 辞書への反映はほぼ即時ですが、変換候補に表示されるまで少し時間がかかる場合があります
- macOSの日本語入力を再起動すると確実に反映されます
