# API仕様: [API名]

**作成日**: YYYY-MM-DD
**バージョン**: v1.0.0
**ベースURL**: `https://api.example.com/v1`

---

## 概要

[このAPIの目的と機能を説明]

---

## 認証

| 方式 | ヘッダー | 形式 |
|------|---------|------|
| Bearer Token | Authorization | `Bearer {token}` |
| API Key | X-API-Key | `{api_key}` |

---

## エンドポイント一覧

| メソッド | パス | 説明 |
|---------|------|------|
| GET | /resources | リソース一覧取得 |
| GET | /resources/:id | リソース詳細取得 |
| POST | /resources | リソース作成 |
| PUT | /resources/:id | リソース更新 |
| DELETE | /resources/:id | リソース削除 |

---

## エンドポイント詳細

### GET /resources

リソースの一覧を取得します。

#### リクエスト

**パラメータ（Query）**
| パラメータ | 型 | 必須 | デフォルト | 説明 |
|-----------|-----|------|----------|------|
| page | integer | No | 1 | ページ番号 |
| limit | integer | No | 20 | 1ページあたりの件数（最大100） |
| sort | string | No | created_at | ソートキー |
| order | string | No | desc | ソート順（asc/desc） |
| filter | string | No | - | フィルター条件 |

**リクエスト例**
```bash
curl -X GET "https://api.example.com/v1/resources?page=1&limit=20" \
  -H "Authorization: Bearer {token}"
```

#### レスポンス

**成功（200 OK）**
```json
{
  "data": [
    {
      "id": "uuid",
      "name": "string",
      "created_at": "2026-01-15T00:00:00Z"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5
  }
}
```

---

### GET /resources/:id

指定されたIDのリソースを取得します。

#### リクエスト

**パラメータ（Path）**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | string (UUID) | Yes | リソースID |

**リクエスト例**
```bash
curl -X GET "https://api.example.com/v1/resources/{id}" \
  -H "Authorization: Bearer {token}"
```

#### レスポンス

**成功（200 OK）**
```json
{
  "data": {
    "id": "uuid",
    "name": "string",
    "description": "string",
    "created_at": "2026-01-15T00:00:00Z",
    "updated_at": "2026-01-15T00:00:00Z"
  }
}
```

**エラー（404 Not Found）**
```json
{
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "指定されたリソースが見つかりません"
  }
}
```

---

### POST /resources

新しいリソースを作成します。

#### リクエスト

**ボディ（JSON）**
| フィールド | 型 | 必須 | バリデーション | 説明 |
|-----------|-----|------|--------------|------|
| name | string | Yes | 1-100文字 | リソース名 |
| description | string | No | 最大1000文字 | 説明 |

**リクエスト例**
```bash
curl -X POST "https://api.example.com/v1/resources" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "新しいリソース",
    "description": "説明文"
  }'
```

#### レスポンス

**成功（201 Created）**
```json
{
  "data": {
    "id": "uuid",
    "name": "新しいリソース",
    "description": "説明文",
    "created_at": "2026-01-15T00:00:00Z"
  }
}
```

**エラー（400 Bad Request）**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "入力値が不正です",
    "details": [
      {
        "field": "name",
        "message": "名前は必須です"
      }
    ]
  }
}
```

---

### PUT /resources/:id

既存のリソースを更新します。

#### リクエスト

**パラメータ（Path）**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | string (UUID) | Yes | リソースID |

**ボディ（JSON）**
| フィールド | 型 | 必須 | バリデーション | 説明 |
|-----------|-----|------|--------------|------|
| name | string | No | 1-100文字 | リソース名 |
| description | string | No | 最大1000文字 | 説明 |

**リクエスト例**
```bash
curl -X PUT "https://api.example.com/v1/resources/{id}" \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "更新後の名前"
  }'
```

#### レスポンス

**成功（200 OK）**
```json
{
  "data": {
    "id": "uuid",
    "name": "更新後の名前",
    "updated_at": "2026-01-15T00:00:00Z"
  }
}
```

---

### DELETE /resources/:id

指定されたリソースを削除します。

#### リクエスト

**パラメータ（Path）**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| id | string (UUID) | Yes | リソースID |

**リクエスト例**
```bash
curl -X DELETE "https://api.example.com/v1/resources/{id}" \
  -H "Authorization: Bearer {token}"
```

#### レスポンス

**成功（204 No Content）**
レスポンスボディなし

---

## エラーコード一覧

| HTTPステータス | エラーコード | 説明 |
|--------------|-------------|------|
| 400 | VALIDATION_ERROR | 入力値バリデーションエラー |
| 400 | INVALID_REQUEST | リクエスト形式が不正 |
| 401 | UNAUTHORIZED | 認証が必要 |
| 401 | INVALID_TOKEN | トークンが無効 |
| 403 | FORBIDDEN | アクセス権限がない |
| 404 | RESOURCE_NOT_FOUND | リソースが見つからない |
| 409 | CONFLICT | リソースの競合 |
| 429 | RATE_LIMIT_EXCEEDED | レート制限超過 |
| 500 | INTERNAL_ERROR | サーバー内部エラー |

---

## レート制限

| プラン | リクエスト/分 | リクエスト/日 |
|--------|-------------|-------------|
| Free | 60 | 1,000 |
| Pro | 600 | 10,000 |
| Enterprise | 6,000 | 100,000 |

**レスポンスヘッダー**
```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
X-RateLimit-Reset: 1640000000
```

---

## ページネーション

カーソルベースまたはオフセットベースのページネーションをサポート。

**オフセットベース**
```
GET /resources?page=2&limit=20
```

**カーソルベース**
```
GET /resources?cursor=abc123&limit=20
```

---

## 変更履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|---------|
| v1.0.0 | YYYY-MM-DD | 初版リリース |

---

## 備考

[その他の補足情報]
