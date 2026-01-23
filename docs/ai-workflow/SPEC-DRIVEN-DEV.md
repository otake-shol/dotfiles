# Claude Codeによる仕様駆動開発ガイド

**最終更新**: 2026-01-15

仕様駆動開発（Spec-Driven Development）をClaude Codeで効果的に進めるためのノウハウをまとめています。

---

## 概要

仕様駆動開発とは、実装前に仕様を明確に定義し、その仕様に基づいてテストと実装を進めるアプローチです。Claude Codeを活用することで、以下のメリットが得られます：

- 仕様の曖昧さを早期に発見
- 仕様からテストケースを自動生成
- 仕様と実装の一貫性を維持
- 変更時の影響範囲を把握

---

## 1. プロジェクト構成

### 1.1 推奨ディレクトリ構造

```
project/
├── .claude/
│   └── CLAUDE.md          # プロジェクト固有の指示
├── specs/                  # 仕様ドキュメント
│   ├── README.md          # 仕様の概要・索引
│   ├── features/          # 機能仕様
│   │   ├── auth.md
│   │   └── payment.md
│   ├── api/               # API仕様
│   │   └── openapi.yaml
│   └── data-models/       # データモデル仕様
│       └── entities.md
├── tests/                  # テストコード
└── src/                    # 実装コード
```

### 1.2 プロジェクト固有のCLAUDE.md

各プロジェクトのルートに `.claude/CLAUDE.md` を配置し、プロジェクト固有のルールを定義します。

```markdown
# プロジェクト仕様

## 概要
[プロジェクトの目的・背景]

## 技術スタック
- フロントエンド: React + TypeScript
- バックエンド: Node.js + Express
- データベース: PostgreSQL
- テスト: Vitest

## コーディング規約
- [プロジェクト固有のルール]

## 仕様ドキュメント参照
実装前に必ず `specs/` ディレクトリの仕様を確認すること。
仕様に記載のない機能は実装前に確認を求めること。
```

---

## 2. 仕様定義フェーズ

### 2.1 機能仕様の書き方

機能仕様は以下の構造で記述します：

```markdown
# 機能名: ユーザー認証

## 概要
ユーザーがメールアドレスとパスワードでログインできる機能。

## ユーザーストーリー
- ユーザーとして、メールアドレスとパスワードでログインしたい
- ユーザーとして、ログイン状態を維持したい
- ユーザーとして、安全にログアウトしたい

## 受け入れ基準
- [ ] 有効な認証情報でログインできる
- [ ] 無効なパスワードでエラーメッセージが表示される
- [ ] 存在しないユーザーでエラーメッセージが表示される
- [ ] ログイン後、セッションが24時間維持される
- [ ] ログアウト後、セッションが無効化される

## 入力
| フィールド | 型 | 必須 | バリデーション |
|-----------|-----|------|--------------|
| email | string | Yes | 有効なメール形式 |
| password | string | Yes | 8文字以上 |

## 出力
### 成功時
```json
{
  "token": "jwt_token",
  "user": { "id": "...", "email": "..." }
}
```

### エラー時
```json
{
  "error": "INVALID_CREDENTIALS",
  "message": "メールアドレスまたはパスワードが正しくありません"
}
```

## エッジケース
- 連続ログイン失敗時のアカウントロック（5回）
- パスワードリセット中のログイン試行
- 同時セッション数の制限（最大3デバイス）

## セキュリティ考慮事項
- パスワードはbcryptでハッシュ化
- JWTの有効期限は24時間
- リフレッシュトークンは7日間
```

### 2.2 API仕様（OpenAPI）

```yaml
# specs/api/openapi.yaml
openapi: 3.0.0
info:
  title: Project API
  version: 1.0.0

paths:
  /auth/login:
    post:
      summary: ユーザーログイン
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required: [email, password]
              properties:
                email:
                  type: string
                  format: email
                password:
                  type: string
                  minLength: 8
      responses:
        '200':
          description: ログイン成功
        '401':
          description: 認証失敗
```

### 2.3 データモデル仕様

```markdown
# データモデル: User

## エンティティ定義

| カラム | 型 | NULL | デフォルト | 説明 |
|--------|-----|------|----------|------|
| id | UUID | No | gen_random_uuid() | 主キー |
| email | VARCHAR(255) | No | - | ユニーク |
| password_hash | VARCHAR(255) | No | - | bcryptハッシュ |
| created_at | TIMESTAMP | No | NOW() | 作成日時 |
| updated_at | TIMESTAMP | No | NOW() | 更新日時 |

## リレーション
- User 1:N Session
- User 1:N Order

## インデックス
- UNIQUE(email)
- INDEX(created_at)
```

---

## 3. Claude Codeでの仕様活用

### 3.1 仕様を読み込ませる

```
specs/features/auth.md の仕様に基づいて、ログイン機能を実装してください。
```

### 3.2 仕様の曖昧さを検出

```
specs/features/payment.md の仕様をレビューし、
曖昧な点や不足している情報を指摘してください。
```

### 3.3 Sequential Thinking MCPの活用

複雑な仕様の検討には、Sequential Thinking MCPを活用します：

```
Sequential Thinkingを使って、以下の要件を段階的に分析し、
仕様を設計してください：

要件：ユーザーが商品を購入できるECサイトの決済機能
```

### 3.4 仕様からテストケース生成

```
specs/features/auth.md の受け入れ基準に基づいて、
Vitestのテストケースを生成してください。
各テストケースは具体的な入力と期待出力を含めてください。
```

---

## 4. テスト駆動フェーズ（TDD）

### 4.1 Red-Green-Refactorサイクル

1. **Red**: 仕様に基づいてテストを書く（失敗する）
2. **Green**: テストが通る最小限の実装
3. **Refactor**: コードを改善

```
以下の仕様に対してTDDで実装を進めます。
まず失敗するテストケースを作成してください。

仕様：[仕様を貼り付け]
```

### 4.2 BDD（振る舞い駆動開発）

Gherkin形式で仕様を記述し、テストに変換：

```gherkin
# specs/features/auth.feature
Feature: ユーザー認証
  Scenario: 有効な認証情報でログイン
    Given ユーザー "test@example.com" が登録されている
    When パスワード "password123" でログインする
    Then ログインが成功する
    And JWTトークンが返される

  Scenario: 無効なパスワードでログイン
    Given ユーザー "test@example.com" が登録されている
    When パスワード "wrongpassword" でログインする
    Then エラー "INVALID_CREDENTIALS" が返される
```

```
上記のGherkin仕様をVitest + Playwrightのテストコードに変換してください。
```

---

## 5. 実装フェーズ

### 5.1 仕様に忠実な実装

```
specs/features/auth.md の仕様と、
tests/auth.test.ts のテストケースに基づいて、
src/services/auth.ts を実装してください。

仕様に記載のない動作は実装せず、確認を求めてください。
```

### 5.2 仕様との整合性チェック

```
src/services/auth.ts の実装が specs/features/auth.md の仕様と
整合しているか確認してください。差異があれば報告してください。
```

---

## 6. 仕様管理・変更追跡

### 6.1 仕様のバージョン管理

仕様ドキュメントは必ずGitで管理し、変更履歴を追跡します。

```markdown
# 変更履歴

## v1.1.0 (2026-01-15)
- セッション有効期限を12時間から24時間に変更
- 同時セッション数制限を追加（最大3デバイス）

## v1.0.0 (2026-01-01)
- 初版リリース
```

### 6.2 仕様変更時のワークフロー

1. 仕様ドキュメントを更新
2. 影響を受けるテストを更新
3. 実装を修正
4. 全テストがパスすることを確認

```
specs/features/auth.md の「セッション有効期限」が
12時間から24時間に変更されました。

影響を受けるテストと実装を特定し、更新してください。
```

### 6.3 トレーサビリティマトリクス

仕様・テスト・実装の対応関係を管理：

```markdown
# トレーサビリティマトリクス

| 仕様ID | 仕様 | テスト | 実装 |
|--------|------|--------|------|
| AUTH-001 | 有効な認証情報でログイン | auth.test.ts:12 | auth.ts:login() |
| AUTH-002 | 無効なパスワードでエラー | auth.test.ts:28 | auth.ts:login() |
| AUTH-003 | セッション維持 | auth.test.ts:45 | session.ts:create() |
```

---

## 7. エージェントの活用

### 7.1 仕様アナリストエージェント

`.claude/agents/spec-analyst.md` を配置：

```markdown
あなたは仕様アナリストです。以下の責務を持ちます：

1. 仕様の曖昧さ・矛盾の検出
2. エッジケースの洗い出し
3. 非機能要件（パフォーマンス、セキュリティ）の確認
4. 仕様の完全性チェック

仕様をレビューする際は以下の観点でフィードバックを提供してください：
- 入力と出力が明確か
- エラーケースが網羅されているか
- セキュリティ上の考慮事項があるか
- パフォーマンス要件が定義されているか
```

### 7.2 アーキテクチャレビュアーエージェント

```markdown
あなたはアーキテクチャレビュアーです。以下の責務を持ちます：

1. 設計の妥当性評価
2. スケーラビリティの検証
3. 技術的負債のリスク評価
4. ベストプラクティスとの整合性確認
```

---

## 8. ツール・テンプレート

### 8.1 Claude Codeコマンド

`.claude/commands/` にカスタムコマンドを配置：

```markdown
# /spec-review
specs/ディレクトリの仕様をレビューし、以下を報告してください：
- 曖昧な点
- 不足している情報
- セキュリティ上の懸念
- 提案される改善点
```

```markdown
# /spec-to-test
指定された仕様ファイルから、テストケースを生成してください。
正常系、異常系、境界値テストを含めてください。
```

---

## 9. ベストプラクティス

### 9.1 仕様ファースト

- 実装前に必ず仕様を書く
- 仕様が曖昧な場合は実装を始めない
- 仕様の変更は必ずドキュメントを先に更新

### 9.2 テストを仕様の検証手段に

- 受け入れ基準 = テストケース
- テストが通る = 仕様を満たす
- テストコードも仕様の一部として扱う

### 9.3 小さく始める

- 大きな機能は小さな仕様に分割
- 1つの仕様 = 1つのPR
- 段階的にリリース

### 9.4 継続的な仕様の改善

- 実装中に発見した問題は仕様にフィードバック
- 運用で発見したエッジケースを追記
- 定期的に仕様の棚卸し

---

## 10. プロンプト例

### 仕様設計支援
```
以下の要件に対する機能仕様を作成してください。
specs/templates/feature-spec-template.md の形式に従ってください。

要件：[要件を記述]
```

### 仕様レビュー
```
specs/features/payment.md の仕様をレビューしてください。
- 曖昧な点
- 不足している情報
- エッジケースの漏れ
- セキュリティ上の懸念
を指摘してください。
```

### 仕様からテスト生成
```
specs/features/auth.md の仕様に基づいて、
包括的なテストケースを生成してください。

テストフレームワーク: Vitest
カバーすべき観点:
- 正常系（Happy path）
- 異常系（Error cases）
- 境界値（Boundary conditions）
- セキュリティ（Security）
```

### 仕様と実装の整合性確認
```
以下のファイルが仕様と整合しているか確認してください：
- 仕様: specs/features/auth.md
- テスト: tests/auth.test.ts
- 実装: src/services/auth.ts

差異があれば報告し、修正案を提示してください。
```

---

## 参考リンク

- [Specification by Example](https://gojko.net/books/specification-by-example/)
- [BDD in Action](https://www.manning.com/books/bdd-in-action)
- [OpenAPI Specification](https://swagger.io/specification/)
- [Gherkin Reference](https://cucumber.io/docs/gherkin/reference/)
