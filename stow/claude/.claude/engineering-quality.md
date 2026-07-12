# AI開発の品質ゲート（全プロダクト共通）

AI駆動開発の前提: **バグ・回帰は「気をつける」ではなく「仕組み」で防ぐ。** AIは高速に書き換えるので、自動の安全網が無いとデグレが静かに混入する（例: テンプレ文字列内のクライアントJSが壊れても `node --check` は通る → 実ブラウザのスモークでしか検出できない）。

## どのプロダクトでも最低限そろえる安全網
1. **ユニットテスト**: 純粋関数（パーサ/正規化/直列化/計算）を必ずテスト下に置く。依存を増やしたくなければ `node:test`（標準）、DX重視なら Vitest。
2. **Lint**: 未定義参照・重複キー等の“動かない系”を実行前に検出（ESLint）。整形は Prettier に分離。
3. **UIスモーク**: UIがあるなら実ブラウザで起動→JSエラー無し＋主要要素描画を Playwright で検証。`node --check`/型チェックでは拾えない領域。
4. **`verify` スクリプト**: `check + lint + test` を1コマンドに。これが完了前の必須ゲート。
5. **CI**: push / PR で `verify`（＋smoke）を自動実行（GitHub Actions）。**人が忘れても止まる**ハードゲート。
6. **再現性**: lockfileをコミット、`engines`/`.nvmrc` でNode固定。ランタイム依存は最小に。
7. **データ保全**: ユーザーデータ（git管理外）があるならバックアップ方針を明記。

## どこに記録すると“漏れなく読み込まれる”か（3層）
- **常に読まれる**: グローバル `~/.claude/CLAUDE.md` から本ファイルを `@import`（= 全セッションで自動ロード）。プロジェクト固有は `<repo>/CLAUDE.md` の「Quality Gate / Definition of Done」章＋ `docs/quality.md` へのポインタ。
- **必ず実行される（読む≠やる）**: `settings.json` の **hooks**。Stop hook で変更時に `npm test`/`verify` を回し、失敗時のみ警告。ハーネスが実行するのでモデルの記憶に依存しない。
- **使い回す**: スキル `/quality-bootstrap`（新規/既存リポに安全網を一括導入）。

## Definition of Done（完了の定義）
コード変更を「完了」と言う前に **`npm run verify` が緑**。UIに触れたら **`npm run smoke` も**。純粋関数を変えたら対応するテストを追加/更新。

## 参照実装
`catchup-studio`（node:test + ESLint/Prettier + Playwrightスモーク + GitHub Actions + Stop hook）。同じ型を他プロダクトへ展開する雛形。
