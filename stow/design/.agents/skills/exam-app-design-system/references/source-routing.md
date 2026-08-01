# Source routing

## Roots

作業開始時に次の3つを区別する。

| 変数 | 内容 | 解決方法 |
|---|---|---|
| `TARGET_APP_ROOT` | 変更対象のExpoアプリ | ユーザー指定を優先し、無ければ対象リポジトリのルート |
| `EXAM_APP_TEMPLATE_ROOT` | 共通仕様とQGuideの正本 | ユーザー指定または同じワークスペース内の `exam-app-template` |
| `OVS_ROOT` | 記事・スライド用図解の正本 | `${XDG_CONFIG_HOME:-$HOME/.config}/otake/visual-system` |

`EXAM_APP_TEMPLATE_ROOT` の候補が複数ある場合は更新日時で選ばず、ユーザーへ確認する。
見つからない場合は `shindanshi-app` から共通ファイルを推測してコピーしない。

## Authoritative sources

| 対象 | 正本 | 取り扱い |
|---|---|---|
| 共通原則 | `exam-app-template/DESIGN-SYSTEM.md` | 読み取り専用。アプリへコピーしない |
| アプリプロフィール | `templates/design/APP-DESIGN-PROFILE.template.md` | 対象アプリの `docs/design-system.md` へコピーして固有値を記入 |
| QGuide原画 | `templates/design/assets/q-guide.png` | 対象アプリへバンドルする。独自加工しない |
| QGuide実装 | `templates/design/components/character/` | 対象アプリへコピー後、公開propsを保って統合する |
| アプリのトークン | 対象アプリの `constants/theme.tokens.js` | 色・文字・余白・角丸・影の唯一の正 |
| 型付きテーマAPI | 対象アプリの `constants/theme.ts` | トークンを型付きで再公開する |
| NativeWind | 対象アプリの `tailwind.config.js` | 同じトークンをCSS変数経由で参照する |
| UIプリミティブ | 対象アプリの `components/ui/` | そのアプリの操作意味に合わせて管理する |
| アプリアイコン | 対象アプリの `components/icons/` | 科目・機能の意味体系をアプリ側で管理する |
| 学習図解 | 対象アプリの図解assetsとregistry | 教材データとReact Native表示制約に従う |
| 記事・スライド図解 | OVSのbrief、tokens、templates | `ovs` で生成し、生成SVGを直接編集しない |

## Asset decisions

- QGuideはシリーズ共通資産として再利用する。
- 科目アイコン、スプラッシュ、アプリアイコン、教材図解はアプリ固有とする。
- OVSの26アイコンと18図解パーツは記事・スライド用とする。アプリ操作アイコンへ
  自動転用しない。
- OVSの考え方を教材図解へ応用する場合も、対象アプリのviewBox、対応要素、
  ファイルサイズ、文字サイズ、registry検証を優先する。
- ライセンスや出典が不明な画像は共通素材へ昇格しない。

## Missing source handling

- 共通仕様が無い: 実装を推測せず、監査結果と不足パスを報告する。
- QGuideだけ無い: 外部画像や生成画像で代替せず、正本の所在を確認する。
- OVSが無い: アプリUIの作業は継続できる。記事用図解だけ未対応として分離する。
- アプリプロフィールが無い: テンプレートから作成し、プレースホルダーを残さない。
