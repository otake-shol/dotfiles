#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title ユーザー辞書に登録
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 📚
# @raycast.argument1 { "type": "text", "placeholder": "読み（ひらがな）" }
# @raycast.argument2 { "type": "text", "placeholder": "単語" }

# Documentation:
# @raycast.description macOS日本語入力のユーザー辞書に単語を登録します
# @raycast.author otkshol
# @raycast.authorURL https://github.com/otkshol

YOMI="$1"
TANGO="$2"

# 辞書データベースのパスを検索
DB_PATH=$(find ~/Library/Dictionaries/CoreDataUbiquitySupport -name "UserDictionary.db" 2>/dev/null | head -1)

if [ -z "$DB_PATH" ]; then
    echo "辞書データベースが見つかりません"
    exit 1
fi

# 既存エントリの最大PKを取得
MAX_PK=$(sqlite3 "$DB_PATH" "SELECT COALESCE(MAX(Z_PK), 0) FROM ZUSERDICTIONARYENTRY;")
NEW_PK=$((MAX_PK + 1))

# タイムスタンプ（Core Data形式: 2001年1月1日からの秒数）
TIMESTAMP=$(python3 -c "import time; print(int(time.time() - 978307200))")

# 既存エントリを確認（重複チェック）
EXISTING=$(sqlite3 "$DB_PATH" "SELECT Z_PK FROM ZUSERDICTIONARYENTRY WHERE ZSHORTCUT = '$YOMI' AND ZPHRASE = '$TANGO';")

if [ -n "$EXISTING" ]; then
    echo "既に登録済み: $YOMI → $TANGO"
    exit 0
fi

# 辞書に登録
sqlite3 "$DB_PATH" <<EOF
INSERT INTO ZUSERDICTIONARYENTRY (Z_PK, Z_ENT, Z_OPT, ZAUXINTVALUE1, ZAUXINTVALUE2, ZAUXINTVALUE3, ZAUXINTVALUE4, ZTIMESTAMP, ZPARTOFSPEECH, ZPHRASE, ZSHORTCUT)
VALUES ($NEW_PK, 1, 1, 0, 0, 0, 0, $TIMESTAMP, NULL, '$TANGO', '$YOMI');
EOF

if [ $? -eq 0 ]; then
    # Z_PRIMARYKEYテーブルの更新
    sqlite3 "$DB_PATH" "UPDATE Z_PRIMARYKEY SET Z_MAX = $NEW_PK WHERE Z_ENT = 1;"

    echo "登録完了: $YOMI → $TANGO"
else
    echo "登録に失敗しました"
    exit 1
fi
