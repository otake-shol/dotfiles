# App Store提出項目と要件更新

## 確認方法

以下は2026-10-18確認時点の目安。リリース時に [Upcoming Requirements](https://developer.apple.com/news/upcoming-requirements/)、[ASC更新履歴](https://developer.apple.com/help/app-store-connect/release-notes/)、[必須プロパティ](https://developer.apple.com/help/app-store-connect/reference/app-information/required-localizable-and-editable-properties/) と対象アプリの提出画面を読み直す。日本語版の反映が遅い場合は英語版と発表日を比較する。

「必須」「条件付き」「任意」「将来適用」を分ける。さらに各項目の状態を「確認済み」「未対応」「該当なし」「未確認」で記録する。公式情報同士の適用条件が違う場合は両方の出典を残し、対象SDKとASCの実際の警告を確認する。

## 直近の変更

| 項目 | 区分・適用時期 | 確認内容・根拠 |
| --- | --- | --- |
| iPhone Duoスクリーンショット | 将来適用。2027年4月からの必須化案内 | [仕様](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications) はiOS 27.1 SDK以降のアプリが対象と記載。[2026-10-05の発表](https://developer.apple.com/news/?id=kkphp5qo) とASC更新履歴は提出アプリ全般と表現。対象範囲を再確認し、2026年10月時点ですべての更新に必須とは案内しない |
| 通常のiPhone・iPad画像 | 必須・対応端末による | 英語版仕様のRequired device sizesはiPhoneのDynamic Island・mediumと、iPad対応時の13インチを指定。別欄にlargeの代替・縮小規定もあるため、既存の6.5/6.7/6.9インチ画像で充足するかをASCで確認。欄の存在だけで全サイズ撮影を要求しない |
| 年齢レーティングの追加質問 | 必須。2026-01-31から | 更新済み質問票への回答を確認。[Age Rating Updates](https://developer.apple.com/news/upcoming-requirements/?id=07242025a) |
| ソーシャルメディア機能の質問 | 必須。2026年9月から新規・更新提出時 | UGCをフィード等で再配信・拡散・交流する機能の有無を確認。教育カテゴリでも回答対象。該当時は13歳未満への提供制限など後続質問を確認。機能を見ずに回答を決めない。[2026-07-09の発表](https://developer.apple.com/news/?id=tlur8uvi) |
| デジタル商品・サービス質問票 | 条件付き。ASCに質問票が表示される場合 | デジタル教材・機能・サブスク等を利用できるか、Apple IAPのみか、地域別に外部決済等があるかを実装と配信地域から確認。非表示なら対応不要。EU向け選択は保存後12か月変更できないため、該当時は回答案と影響を提示し、具体的回答が承認済みか確認して保存する。[質問票の公式手順](https://developer.apple.com/help/app-store-connect/manage-app-information/complete-the-digital-goods-and-services-questionnaire) |
| ビルドSDK | 必須。2026-04-28から | Xcode 26以降とiOS/iPadOS 26 SDK以降。Duoシミュレーターには別途Xcode 27.1が必要。[SDK最低要件](https://developer.apple.com/news/upcoming-requirements/?id=04282026a) |
| 最低対応OS | 必須。2026-09-09から | iOS/iPadOSアプリのdeployment targetは13以降。ビルドSDKの最低要件とは別。[Upcoming Requirements](https://developer.apple.com/news/upcoming-requirements/) |
| Asset Library・Creative assets | 任意素材を含む新しい管理画面 | 2026-10-05に提供開始。商品ページヘッダー・検索結果向け画像等のCreative assetsは任意。必須スクショやIAP審査画像を代替しない。[素材管理](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-your-app-store-assets) |
| アクセシビリティラベル | 任意の申告 | 対応端末ごとに主要操作を検証して回答する。未申告と対応なしを区別し、未検証のVoiceOver等を対応済みにしない。[Accessibility Nutrition Labels](https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels/) |

## 毎回の提出確認

新設項目とは別に、既存の提出条件も確認する。

| 項目 | 確認内容 |
| --- | --- |
| アプリ・version情報 | 名前、カテゴリ、コンテンツの権利、説明、キーワード、サポートURL、著作権、更新内容、公開方式。入力要否は[必須プロパティ](https://developer.apple.com/help/app-store-connect/reference/app-information/required-localizable-and-editable-properties/) と画面の警告で確認 |
| スクショ | 対応端末・言語ごとの枚数と実寸、実アプリとの一致、アルファなし、処理完了。撮影は[別手順](simulator-screenshots.md)を参照 |
| プライバシー | URLとデータ収集回答を確認。解析・課金等の第三者SDKも含める。Privacy ManifestやRequired Reason APIの設定はASC回答と別に確認。[App Privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy)、[Privacy Manifest](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files) |
| 暗号化・輸出コンプライアンス | 実装と対象地域に基づいて判断し、Missing Complianceを解消。`ITSAppUsesNonExemptEncryption=false` を暗号化未使用と同一視しない。lane内の固定回答も検証。[輸出確認手順](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/) |
| ビルド | bundle ID、version、buildNumber、SDK、処理完了、選択ビルド、リリース用設定の一致。[ビルド選択](https://developer.apple.com/help/app-store-connect/manage-builds/choose-a-build-to-submit/) |
| App Review情報 | 連絡先、ログインが必要な場合の審査アカウント、機能への到達手順、IAPや外部連携の補足。認証情報をログや成果物に複製しない |
| IAP・サブスクリプション | 商品の準備状況、価格・地域、ローカライズ、審査用画像、versionへの紐付け、購入・復元。初回はアプリversionと同時提出。[IAP設定](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases/) |
| デジタル商品・サービスの申告 | App Informationの質問票の表示有無と回答状況を確認。適用条件と保存前の確認は上表を参照 |
| 契約・価格・配信地域 | 未同意契約や税務・銀行情報の警告、有料契約の状態、意図した販売地域と価格を確認。法的同意や地域変更を準備作業として勝手に実行しない |
| 地域・機能固有の申告 | EU配信時のDSA事業者情報、地域の許認可、規制対象カテゴリ等を適用対象だけ確認。日本限定配信にEU専用書類を一律要求しない。[DSA](https://developer.apple.com/help/app-store-connect/manage-compliance-information/manage-european-union-digital-services-act-trader-requirements) |

## 完了判定

ASC上で警告が解消され、素材の処理・必須回答・ビルド紐付けが完了していることを確認する。画面/APIにアクセスしていない場合はローカル確認と公式調査の結果までを報告し、提出可能とは断定しない。未回答項目については必要な事実をユーザーに確認する。
