---
description: iOSアプリのリリース/アップデート手順を対話的に進める
allowed-tools: Bash, Read, Edit
---

# /release-ios - iOSリリース/アップデート

App Store へのiOSリリース/アップデートを対話的に進める。プロジェクトに `scripts/release-ios.sh` があれば優先実行し、無ければ手順を順番にガイドする。

## 前提条件チェック（最初に確認）

- プロジェクトに `app.json` / `eas.json` / `fastlane/` がある（Expo + fastlane 構成）
- `~/.config/fastlane/env` のプレースホルダーが解消されている（未解消なら `cd ~/dotfiles && make setup-fastlane-env` を案内）
- EAS CLI ログイン済み（`eas whoami` で確認）

## 手順

### 1. バージョン確認

- `app.json` の `version` を表示
- buildNumber は EAS の autoIncrement で自動採番されるため触らない
- バージョンを上げる必要があればユーザーに確認して `app.json` を編集

### 2. リリースノート確認

- `fastlane/templates/release_notes.md` を表示
- 内容が古ければユーザーに編集してもらう（または対話で書き換え）

### 3. メタデータ再生成

```bash
npm run fastlane:setup
```

### 4. EAS Build

```bash
eas build --platform ios --profile production
```

時間がかかるためユーザーに確認。既にビルド済みならスキップ可。

### 5. メタデータ送信

スクショ変更ありなら：
```bash
fastlane sync_store
```

メタデータのみなら：
```bash
fastlane sync_metadata
```

### 6. TestFlight・審査申請の案内

- TestFlight でビルド到着後、実機テスト
- App Store Connect で「Submit for Review」（**手動操作**、Claudeからは実行できない）

## スクリプト優先実行

プロジェクトルートに `scripts/release-ios.sh` がある場合は、それを実行する：

```bash
bash scripts/release-ios.sh
```

スクリプトが対話プロンプトで各ステップを確認しながら進める。Claudeは「実行中の出力をユーザーに見せる」役割。

## 注意点

- **同じ version で再アップロードは不可** — バージョンを上げ忘れないこと
- **IAP変更がある場合** — App Store Connect 側で先に商品を作成・承認してから ビルドを上げる
- **スクショ更新** — UI変更があれば `assets/screenshots/raw/v2/` を撮り直してから `npm run generate:screenshots`
- **審査申請は手動** — `Fastfile` は `submit_for_review: false` 固定

## 他アプリでの利用

同じ構成（Expo + fastlane + scripts/release-ios.sh）なら、どのアプリでも `/release-ios` で同じフローが動く。
