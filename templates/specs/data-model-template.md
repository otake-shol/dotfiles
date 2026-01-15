# データモデル: [エンティティ名]

**作成日**: YYYY-MM-DD
**データベース**: PostgreSQL / MySQL / MongoDB / [その他]

---

## 概要

[このエンティティの目的と役割を説明]

---

## エンティティ定義

### テーブル/コレクション名
`[table_name]`

### カラム定義

| カラム | 型 | NULL | デフォルト | 説明 |
|--------|-----|------|----------|------|
| id | UUID / SERIAL | No | gen_random_uuid() | 主キー |
| created_at | TIMESTAMP | No | NOW() | 作成日時 |
| updated_at | TIMESTAMP | No | NOW() | 更新日時 |
| deleted_at | TIMESTAMP | Yes | NULL | 論理削除日時（Soft Delete使用時） |
| [column] | [type] | [Yes/No] | [default] | [description] |

---

## リレーション

```
[Entity1] 1:N [Entity2]
[Entity1] N:N [Entity3] (via [join_table])
[Entity1] 1:1 [Entity4]
```

### 詳細

| リレーション | 外部キー | 参照先 | ON DELETE | ON UPDATE |
|-------------|---------|--------|-----------|-----------|
| [Entity2] | entity1_id | [Entity1].id | CASCADE | CASCADE |

---

## インデックス

| インデックス名 | カラム | タイプ | 説明 |
|---------------|--------|--------|------|
| idx_[table]_[column] | [column] | INDEX | [検索用途] |
| uk_[table]_[column] | [column] | UNIQUE | [一意性制約] |
| idx_[table]_composite | [col1, col2] | INDEX | [複合インデックス] |

---

## 制約

| 制約名 | タイプ | カラム | 条件 |
|--------|--------|--------|------|
| pk_[table] | PRIMARY KEY | id | - |
| uk_[table]_[column] | UNIQUE | [column] | - |
| fk_[table]_[ref] | FOREIGN KEY | [column] | REFERENCES [ref_table](id) |
| ck_[table]_[name] | CHECK | [column] | [condition] |

---

## バリデーションルール

| フィールド | ルール | エラーメッセージ |
|-----------|--------|----------------|
| email | 有効なメールアドレス形式 | "無効なメールアドレスです" |
| password | 8文字以上、英数字混在 | "パスワードは8文字以上で英数字を含めてください" |
| [field] | [rule] | [message] |

---

## ステータス/列挙型

### [EnumName]
| 値 | 説明 |
|-----|------|
| DRAFT | 下書き |
| PUBLISHED | 公開中 |
| ARCHIVED | アーカイブ済み |

---

## サンプルデータ

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "field1": "value1",
  "field2": 123,
  "created_at": "2026-01-15T00:00:00Z",
  "updated_at": "2026-01-15T00:00:00Z"
}
```

---

## マイグレーション

### 作成
```sql
CREATE TABLE [table_name] (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- カラム定義
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_[table]_[column] ON [table_name]([column]);
```

### 変更（例）
```sql
ALTER TABLE [table_name] ADD COLUMN [new_column] [type];
```

---

## クエリ例

### 基本的なCRUD

```sql
-- Create
INSERT INTO [table_name] ([columns]) VALUES ([values]);

-- Read
SELECT * FROM [table_name] WHERE id = $1;

-- Update
UPDATE [table_name] SET [column] = $1, updated_at = NOW() WHERE id = $2;

-- Delete (Soft)
UPDATE [table_name] SET deleted_at = NOW() WHERE id = $1;

-- Delete (Hard)
DELETE FROM [table_name] WHERE id = $1;
```

### 頻出クエリ

```sql
-- [クエリの説明]
SELECT ...
```

---

## パフォーマンス考慮事項

- **想定レコード数**: [例: 100万件]
- **アクセスパターン**: [例: 読み取り多、書き込み少]
- **パーティショニング**: [必要/不要、方式]
- **シャーディング**: [必要/不要、キー]

---

## 変更履歴

| 日付 | 変更者 | 変更内容 |
|------|--------|---------|
| YYYY-MM-DD | [名前] | 初版作成 |

---

## 備考

[その他の補足情報]
