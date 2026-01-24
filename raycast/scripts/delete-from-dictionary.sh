#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ユーザー辞書から削除
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🗑️
# @raycast.argument1 { "type": "text", "placeholder": "読み（ひらがな）" }

# Documentation:
# @raycast.description macOS日本語入力のユーザー辞書から単語を削除します
# @raycast.author otkshol
# @raycast.authorURL https://github.com/otkshol

YOMI="$1"

DB_PATH=$(find ~/Library/Dictionaries/CoreDataUbiquitySupport -name "UserDictionary.db" 2>/dev/null | head -1)

if [ -z "$DB_PATH" ]; then
    echo "辞書データベースが見つかりません"
    exit 1
fi

# 削除対象を確認
ENTRIES=$(sqlite3 -separator " → " "$DB_PATH" "SELECT ZSHORTCUT, ZPHRASE FROM ZUSERDICTIONARYENTRY WHERE ZSHORTCUT = '$YOMI';")

if [ -z "$ENTRIES" ]; then
    echo "該当するエントリがありません: $YOMI"
    exit 0
fi

# 削除実行
if sqlite3 "$DB_PATH" "DELETE FROM ZUSERDICTIONARYENTRY WHERE ZSHORTCUT = '$YOMI';"; then
    echo "削除完了: $YOMI"
else
    echo "削除に失敗しました"
    exit 1
fi
