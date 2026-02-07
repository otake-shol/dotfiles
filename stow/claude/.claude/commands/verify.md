# /verify - 検証ループ

実装後の検証チェックリスト:

1. **型チェック**: `tsc --noEmit` または `npx tsc --noEmit`
2. **Lint**: `npm run lint` または `npx eslint .`
3. **テスト**: `npm test` または該当テストファイル
4. **UI確認**: Playwright MCPでスナップショット取得（必要時）

各ステップでエラーがあれば修正してから次へ進む。
