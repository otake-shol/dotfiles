# /verify - 検証ループ

Boris Cherny推奨の「品質2-3倍向上」検証ループを実行します。

## 自動実行

```bash
~/.claude/hooks/verify.sh [project_path]
```

## 手動チェックリスト

1. **型チェック**: `tsc --noEmit` または `npx tsc --noEmit`
2. **Lint**: `npm run lint` または `npx eslint .`
3. **テスト**: `npm test` または該当テストファイル
4. **UI確認**: Playwright MCPでスナップショット取得（必要時）

## 検証フロー

```
実装完了
   ↓
型チェック → エラー → 修正 → 再実行
   ↓ OK
Lint → エラー → 修正 → 再実行
   ↓ OK
テスト → エラー → 修正 → 再実行
   ↓ OK
完了（コミット可能）
```

各ステップでエラーがあれば**修正してから次へ進む**。
ループを回すことで品質が2-3倍向上する。
