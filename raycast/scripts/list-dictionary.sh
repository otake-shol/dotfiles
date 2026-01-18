#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ユーザー辞書一覧
# @raycast.mode fullOutput

# Optional parameters:
# @raycast.icon 📖

# Documentation:
# @raycast.description macOS日本語入力のユーザー辞書一覧を表示します
# @raycast.author otkshol
# @raycast.authorURL https://github.com/otkshol

DB_PATH=$(find ~/Library/Dictionaries/CoreDataUbiquitySupport -name "UserDictionary.db" 2>/dev/null | head -1)

if [ -z "$DB_PATH" ]; then
    echo "辞書データベースが見つかりません"
    exit 1
fi

echo "=== ユーザー辞書一覧 ==="
echo ""

sqlite3 -separator " → " "$DB_PATH" "SELECT ZSHORTCUT, ZPHRASE FROM ZUSERDICTIONARYENTRY ORDER BY ZSHORTCUT;"

COUNT=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM ZUSERDICTIONARYENTRY;")
echo ""
echo "合計: ${COUNT}件"
