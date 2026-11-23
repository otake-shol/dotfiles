# シミュレーターによる提出用スクリーンショット

## 対応環境

Appleは [Xcode 27.1のiPhone Duoシミュレーター](https://developer.apple.com/iphone-duo/prepare/) を案内している。実機がなくても、対応するXcodeとランタイムで実アプリを動かして撮影できる。撮影できることと、App Storeで必須になる時期は別。[提出要件](submission-requirements.md)を参照する。

まず環境を実測する。

```bash
xcodebuild -version
xcode-select -p
xcrun simctl list runtimes
xcrun simctl list devicetypes
xcrun simctl list devices available
```

DuoがなければXcode 27.1以降のDuo対応版と対応ランタイムの追加が必要。iPhone Pro MaxやiPadの画像をDuo用に引き伸ばして代用しない。CoreSimulatorServiceへの接続失敗をランタイム未インストールと判断せず、実行権限・サービス状態を確認する。複数Xcodeの併用時はコマンド単位の `DEVELOPER_DIR` を優先し、全体の選択を不用意に切り替えない。

## 撮影対象の準備

- Simulator用 `.app` を使う。実機用IPAやApp Store版をそのままSimulatorへ入れない。
- 既存のローカルビルド手順か `ios.simulator: true` のEAS profileを使う。Expo Goでは独自ネイティブモジュールや購入UIを再現できない場合があるため、アプリ用ビルドを優先する。
- 本番と同じ画面、言語、テーマ、フォント、適切なサンプルデータを用意する。開発メニュー、エラー、デバッグ表示、個人情報を含めない。
- 外側・内側の切り替え、縦横、Safe Area、キーボード、主要画面の崩れを確認する。React Nativeでは固定の画面幅や端末種別判定がレイアウトを妨げていないかを見る。撮影だけの依頼で大規模なUI改修まで始めない。

## 撮影手順

1. XcodeのDevice HubでDuoシミュレーターを起動し、対象アプリを表示する。必要な外側・内側の状態と向きを選ぶ。
2. Device Hub/Simulatorのスクリーン保存機能か `simctl` で画面のピクセル画像を保存する。macOSのウィンドウキャプチャは枠や拡大率が混入するため提出用に使わない。
3. CLIでは対象UDIDを明示する。複数起動時に `booted` へ任せない。表示IDは `enumerate` と現在のXcodeのヘルプから取得し、`internal` / `external` をDuoの内側・外側に推測で対応付けない。

```bash
# 値は実際に取得したUDIDと表示IDへ置換する。
SIM_UDID='対象のUDID'
xcrun simctl io "$SIM_UDID" enumerate
xcrun simctl help io
SIM_DISPLAY_ID='取得した表示ID'

# 任意の見た目調整。撮影終了後にclearする。
xcrun simctl status_bar "$SIM_UDID" override \
  --time '9:41' --batteryState charged --batteryLevel 100

# 先にDevice Hubで外側画面を表示。JPEGはアルファを含まない。
mkdir -p assets/screenshots/raw/iphone-duo
xcrun simctl io "$SIM_UDID" screenshot --type=jpeg \
  --display="$SIM_DISPLAY_ID" --mask=ignored \
  assets/screenshots/raw/iphone-duo/outer-01.jpg

# 内側へ切り替え、enumerateし直して対応する表示IDで別名保存する。
xcrun simctl status_bar "$SIM_UDID" clear
sips -g pixelWidth -g pixelHeight -g hasAlpha \
  assets/screenshots/raw/iphone-duo/outer-01.jpg
```

保存先はリポジトリの既存規約に合わせる。上記はコマンド例であり、Duoの表示IDとCLI動作は利用中のXcodeで確認する。黒い画像や想定外サイズなら表示状態・対象IDを見直し、必要ならDevice Hubの保存機能を使う。

## 画像の検証

2026-10-18確認時点の [Apple公式仕様](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications)：

| 対象 | 画像サイズ |
| --- | --- |
| Duo外側 | 1398 × 2034 または 2034 × 1398 px |
| Duo内側 | 2007 × 2853 または 2853 × 2007 px |
| 通常iPhoneのDynamic Island・medium | 1179 × 2556 または1206 × 2622 px。横向きは縦横を交換 |

画像形式はJPEG/JPG/PNG、アルファチャンネル・透過なし、表示サイズごとに1〜10枚。iPad対応アプリでは13インチ枠の仕様も確認する。外側・内側のどの組合せが提出に必須かは現行ASCの入力欄と検証結果で確認し、上表だけから両方必須と断定しない。

保存後は実寸・アルファを検査し、画像を開いてアプリ内容、向き、切れ、余白、文字、開発用表示を確認する。画像を開かずに撮影成功としない。合成素材を作る場合も実際のDuo画面を使い、スクショと販促用Creative assetsを区別する。

## アップロード経路

既存の素材設定・同期スクリプト・fastlaneのサイズ判定を確認する。JPEGを撮影してもPNG限定の同期処理では送られないため、対応する形式と経路を選ぶ。新しい表示サイズを認識しないツールには架空のenumや別機種の接頭辞を渡さず、ASCのAsset Library等の対応する画面を使う。送信前に対象言語・外側/内側・順序・件数を確認し、送信後に処理完了とプレビューを確認する。

公式資料： [Simulatorの画面保存](https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/iOS_Simulator_Guide/InteractingwiththeiOSSimulator/InteractingwiththeiOSSimulator.html)、[App Store素材管理](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-your-app-store-assets)。旧Simulatorガイドのメニュー名は現行Device Hubと異なる場合がある。
