---
name: source-command-release-ios
description: iOSアプリのリリース準備、App Store Connect提出項目の確認、シミュレーターでの審査用スクリーンショット撮影、TestFlight・審査提出を進める。/release-iosや提出要件の変更対応に使う。
---

# iOSリリースとApp Store提出準備

Expo + EAS + fastlaneを中心に、対象リポジトリの構成に合わせて進める。要件調査やスキル更新だけの依頼をリリース実行に拡張しない。

## 作業範囲と最新要件

- ローカルの指示、README、差分、アプリ設定、`package.json`、lockfile、`eas.json`、`fastlane/Fastfile`、素材設定を先に読む。既存のユーザー変更を保持する。
- 提出準備では [提出項目と要件更新](references/submission-requirements.md) を読み、Apple公式の現行情報と対象アプリのApp Store Connect（ASC）表示を照合する。確認日・適用日・SDK条件を記録する。
- 撮影や端末サイズの相談では [シミュレーター撮影](references/simulator-screenshots.md) を読む。新しい機種名の入力欄があるだけで必須と判断しない。
- 調査・準備・撮影・ビルド・アップロード・審査提出・公開を区別し、依頼済みの範囲を進める。既存の承認を再取得しない。範囲外の外部更新が必要なら対象と差分を準備してから確認する。

## ローカル構成の確認

- `app.json` / `app.config.*` のversion、bundleIdentifier、対応端末、向き、privacy設定を確認する。動的設定の秘密値は出力しない。
- `eas.json` のprofile、environment、`ios.simulator`、`autoIncrement`、`appVersionSource`を確認する。撮影用・TestFlight用・本番用profileを混同しない。
- Xcode・SDK・Simulatorはローカルの実測を使う。クラウドビルドでは別途EASのビルドイメージとログのSDKを確認する。
- 既存の認証連携を利用する。`.env`、鍵、認証ファイルを開いたり値を表示したりしない。必要な段階でCLIのログイン状態やAPIの接続成否のみ確認する。
- `scripts/release-ios.sh` があっても先に内容を読み、依頼範囲を越えるビルド・送信・審査提出が含まれていないか確認する。存在しないnpm scriptやlaneを前提にしない。

## バージョンと提出素材

1. 公開済みversion、今回のversion、buildNumberを区別する。未公開versionのビルド差し替えでは同じversionで新しいbuildNumberを使える。公開済みversionの更新は新しいversionが必要。EAS管理ならbuildNumberを手で重複採番しない。[Appleのビルド識別](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/)
2. 差分に基づいてリリースノートと審査メモを整える。未実装の機能や未確認の購入導線を記載しない。
3. メタデータ生成は `package.json` に定義がある場合だけそのコマンドを使う。スクリプトを直接使う場合も先に実装を読む。生成元と生成物を揃える。
4. UI変更がある画面を対象端末で撮影し、素材設定が参照する配置と実寸を検証する。特定アプリの `raw/v2` や過去の画面サイズを固定手順にしない。
5. IAPは商品情報、価格、販売地域、審査用画像、アプリとの紐付けを確認する。初回IAPは新しいアプリversionと一緒に提出する。「先に全IAPの承認を取る」を一律条件にしない。[AppleのIAP設定](https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases/)

## ビルドとTestFlight

必要なテストとプロジェクトの検証を通してから、依頼されたprofileでビルドする。既存のビルドを使える場合はコミット・version・profile・SDKを照合する。

```bash
npx eas build --platform ios --profile production
```

上記はnpmプロジェクトの例。profile名と実行方法を実際の構成に合わせる。Expo Doctorのパッチ差分だけで検証済み依存を一括更新しない。差分内容と実機確認を記録し、メジャー・マイナー不整合や別の失敗は原因を判断する。

EAS無料枠を使い切った場合はXcode・fastlane・空き容量を確認してローカルへ切り替える。課金や枠のリセット待ちを第一案にしない。

```bash
npx eas build --platform ios --profile production --local \
  --non-interactive --output ./build-vX.Y.Z.ipa
npx eas submit --platform ios --profile production --path ./build-vX.Y.Z.ipa
```

`X.Y.Z` は確認したversionに置換する。Submitはアップロードが依頼範囲に含まれる場合だけ実行する。ローカルでも既存のリモート署名設定を利用できる。ローカルXcodeがSDK要件を満たすことを確認する。処理完了後にTestFlightで対象ビルドを確認し、起動・主要操作・購入/復元など変更に関係する実機テストを行う。

## 同期・審査提出・結果確認

- Gemfileがある場合は `bundle exec fastlane` を使い、存在するlaneと引数を選ぶ。`sync_metadata`、`sync_screenshots`、`sync_store` の更新範囲を実装で確認する。
- `overwrite_screenshots` や動画の上書きは既存素材を削除する場合がある。対象言語・表示サイズ・残す素材を含む差し替え一式を確認し、破壊的な置換の承認がない場合は送信直前に確認する。
- 新しいDuo区分やAsset Libraryが利用中のfastlane/APIに未対応なら、既存区分や架空のenumに割り当てない。公式UIなど対応する経路を使う。
- 年齢レーティング、デジタル商品・サービス質問票、プライバシー、輸出コンプライアンス、契約、審査情報などはメタデータ同期だけで完了したとみなさない。ASCの警告と保存後の値を確認する。
- 審査提出は実装済みlane/APIまたはASC画面で行える。`submit_for_review: false` 固定や手動限定と決めつけない。対象version・buildNumber・IAP・公開方式を確定し、審査提出まで依頼されている場合に実行する。
- コマンドの終了だけで成功を報告しない。素材の件数と処理状態、選択ビルド、審査ステータスを読み返す。状態が不明な送信を繰り返さず、履歴とASC側の状態を確認する。
- 最後に実施範囲、確認結果、未完了項目と理由を簡潔に示す。アカウントを見ていない項目は未確認とする。
