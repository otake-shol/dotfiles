# Acceptance checklist

## Audit

対象アプリで次を確認する。

- `constants/theme.tokens.js` が色、文字、余白、角丸、影の正本か。
- `constants/theme.ts` と `tailwind.config.js` が同じトークンを参照しているか。
- ルートでNativeWindのテーマ変数が供給されているか。
- `constants/Colors.ts`、`dark:`、画面内HEXの旧経路が残っていないか。
- `components/ui/` のButton、Card、Chip、ListRow、EmptyStateなどが再利用されているか。
- `components/icons/` のアイコンが意味を持ち、既成セットだけに依存していないか。
- `docs/design-system.md` に未置換の `{{...}}` が無いか。
- QGuideの役割、登場箇所、非表示時の代替、Reduced Motionが定義されているか。
- 状態がラベルと視覚表現の2経路以上で伝わるか。
- ライト、ダーク、本文サイズ、iPad、アクセシビリティのテストがあるか。

代表的な探索:

```bash
rg -n 'dark:|#[0-9A-Fa-f]{6}' app components
rg -n 'Colors|theme\.tokens|useTheme|useThemeVars' app components constants hooks tailwind.config.js
rg -n '\{\{[^}]+\}\}' docs/design-system.md
rg --files components/ui components/icons components/character __tests__
```

検索結果は自動修正せず、SVG path、コメント、テストfixtureなどの誤検出を確認する。

## Required architecture

- [ ] 共通仕様とアプリ固有プロフィールが分離されている。
- [ ] `theme.tokens.js` が唯一の値の正本である。
- [ ] classNameとReact Native propsが同じトークンを参照する。
- [ ] light/darkでsemantic keyが一致する。
- [ ] 分野色と状態色の衝突をテストで禁止する。
- [ ] 本文サイズ設定が問題文・解説・補助本文だけへ適用される。
- [ ] 主要UIがプリミティブを通して一貫している。
- [ ] 状態が色や透明度だけに依存しない。
- [ ] QGuideを非表示にしても情報と操作が成立する。
- [ ] 共通素材の正本とアプリ固有素材の境界がプロフィールに記録されている。

## Verification

lockfileと `package.json` に従ってコマンドを選ぶ。最低限、次を確認する。

1. 型チェック
2. Lint
3. theme tokenとデザイン規約のユニットテスト
4. 変更したUIの関連テスト
5. 代表画面のlight/dark、本文サイズ、iPhone/iPadの目視
6. 動きがある場合はReduced Motion

教材図解を変更した場合は、対象アプリ固有のregistry生成、参照整合、
React Native非対応要素、ファイルサイズの検証も実行する。

## Completion evidence

完了は次の証拠が揃ったときだけ報告する。

- 実装ファイルとプロフィールの差分
- 残存する旧経路の検索結果、または意図的に残す理由
- 実行した検証コマンドの終了コード
- 代表画面の確認対象と結果
- 未移行項目の一覧と完了条件
