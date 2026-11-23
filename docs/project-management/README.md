---
type: Guide
title: プロジェクト管理ツールの入口
description: 目的に応じて既存のスキル・テンプレート・リポジトリを選ぶための一覧。
tags: [project-management, skills]
---

# プロジェクト管理ツールの入口

目的に応じて既存のスキル・テンプレート・リポジトリを選ぶための一覧。初回確認日: 2026-10-08。成果物と保存先の対応を2026-10-12に更新。
dotfilesで共通の手順と空の雛形を管理し、各プロジェクトで計画・課題・成果物を管理する。

成果物の保存先は[成果物とリポジトリの対応](#成果物とリポジトリの対応)、変更時の更新先は[変更内容と更新先](#変更内容と更新先)、既存ツールの一覧は[リポジトリ台帳](#リポジトリ台帳)を参照する。

## 集約先と正本

| 情報 | 正本 | この入口での管理 |
| --- | --- | --- |
| 共通スキル・ツール設定・空の雛形 | dotfiles | 用途、参照先、利用例 |
| 既存ツールのコード・生成処理・専用雛形 | 各ツールのリポジトリ | 用途、更新先、利用手順への参照 |
| プロジェクト計画・課題・進捗・成果物 | 各プロジェクトで選んだリポジトリや管理サービス | 参照先と役割 |
| 個人の判断・活動記録 | 個人のObsidian Vault | 記録先の説明 |
| 業務固有の情報・入力済み接続台帳 | 組織で許可された非公開の領域 | 共通の空の雛形のみ |

採用方針: dotfilesを共通の入口にし、ツール本体は各リポジトリ、入力済みの案件データは各案件の保存先で管理する。共通の定義・手順を一元管理し、既存ツールの実体を参照する。複数人への一式の配布や独立した更新が必要になった時点で、共通スキル・雛形・ガイドを専用PMリポジトリへ切り出すことを検討する。

## 変更内容と更新先

| 変更するもの | 更新先 |
| --- | --- |
| ツールの用途・選び方・参照先 | この入口 |
| L0・L1・L2の共通定義と親IDの規則 | [スケジュール階層](../../stow/agents/.agents/skills/project-planning/references/schedule-levels.md) |
| 計画の作成手順・共通入力項目 | [計画スキル](../../stow/agents/.agents/skills/project-planning/SKILL.md)とその参照雛形 |
| WBSの検査規則（ID・親子・先行・日付・稼働日数） | [WBS検査の仕様](../../stow/agents/.agents/skills/project-planning/references/wbs-check.md)。判定を変えるときは仕様・`scripts/check-wbs.mjs`・テストを同時に更新 |
| 共通の計画スライド | [スライド雛形](../../templates/project-plan-slides/README.md) |
| Sheetsの生成処理・数式・専用雛形 | [project-portfolio-sheets](https://github.com/otake-shol/project-portfolio-sheets)。dotfilesには列対応と利用手順を記録 |
| Planbaseの機能・データ形式 | [project-plan-workspace](https://github.com/otake-shol/project-plan-workspace) |
| チーム運用ルール・半期計画ツール | [team-playbook](https://github.com/otake-shol/team-playbook) |
| 案件の担当・日程・進捗・意思決定 | 案件で採用した正本。説明用スライドには元のID・版・確認日を継承 |

共通ルールの変更時は利用先への影響と対応ガイドを確認する。参照先のツールに異なる定義がある場合はその差分を記録し、同期済みと推測しない。

## 成果物とリポジトリの対応

コード、入力済みデータ、説明用の出力を区別して更新先を選ぶ。ツール本体のリポジトリと、そのツールで作る案件データの保存先は別に定める。

| 成果物・資産 | 管理先 | 正本と出力の関係 |
| --- | --- | --- |
| 共通の計画手順・スキル・空の雛形 | [dotfiles](../../README.md) | 共通定義を管理し、案件側から参照する |
| Planbase本体・Schema・読込と出力の処理 | [project-plan-workspace](https://github.com/otake-shol/project-plan-workspace) | アプリとデータ形式の正本。入力済みの案件計画は各案件で管理する |
| Planbaseで扱う計画 | 各案件の保存先にある `*.project-plan.json` | JSONが正本。ボード・ガント・Overview・XLSXは表示や出力。ブラウザの下書きは一時保存 |
| Sheetsの生成コード・匿名サンプル・専用雛形 | [project-portfolio-sheets](https://github.com/otake-shol/project-portfolio-sheets) | 公開テンプレートの正本。実案件のデータや接続先は非公開側で管理する |
| Sheetsの実データ・ビルド設定・運用台帳 | 案件の非公開データリポジトリと運用中のGoogle Sheets | 再生成用の入力と日々の運用台帳を区別する。GitとSheetsの相互同期は前提にしない |
| GitHubのPM導入雛形 | [github-pm-baseline](https://github.com/otake-shol/github-pm-baseline) | 雛形を対象案件へ適用した後のIssue・Project・文書は対象リポジトリで管理する |
| チーム運用の雛形・半期計画ツール | [team-playbook](https://github.com/otake-shol/team-playbook) | 再利用するルールと雛形を管理し、入力済みのチーム計画は採用先で管理する |
| 登壇原稿・画像・閲覧用HTML・PDF | [slides](https://github.com/otake-shol/slides) | 各資料のMarkdownと画像を編集し、HTML・PDFを再生成する |
| Zenn用の原稿・記事画像 | [zenn-content](https://github.com/otake-shol/zenn-content) | `articles/` と `images/` を管理する。公開状態はリポジトリへの反映とZennのデプロイを別々に確認する |
| 個別の販売ツール・配布ファイル・販売記事 | 商品ごとに決める保存先 | ソース・配布版・記事を結び、対応する版と更新方法を残す |

PlanbaseのJSONをSheets用に変換する経路は両リポジトリのREADMEに記載されている。変換後に編集する場合は以後の正本をどちらに置くか決める。変換機能の存在と、個別案件での変換・登録・同期の実施状況を区別する。

### 端末内の集約台帳

この端末の具体的な配置、入力済み計画、非公開リポジトリとの対応は `output/project-management/inventory.md` に集約する。ローカル用の台帳として扱い、`output/` 全体と同じくGit管理対象外とする。新しいcloneには含まれない。

共通の入口には用途・公開リポジトリ・更新先を記録する。ローカル用の台帳には成果物ごとの実パス、管理リポジトリ、Git管理状態、実施済みの連携、未決の保存先、確認日を記録する。ローカル台帳にも認証情報を記載しない。

### 台帳の更新契機

1. 成果物の追加時に、編集する正本・生成物・公開先と管理リポジトリを記録する。
2. 移動やリポジトリ分割の際に参照先を更新し、仮置き・Git管理・反映済みの状態を区別する。
3. 読込・変換・公開を実行した後に実施日と結果を記録する。対応形式があるだけの状態を連携済みにしない。
4. 保存先が未決なら未決のまま記録し、決まった時点で正本と更新先を揃える。

## 用途別のツール一覧

以下はローカルのファイルとリポジトリのREADMEから確認した用途。サービスの最新機能・料金や接続成功を検証した一覧ではない。

| 場面 | ツール・資産 | 成果物・使い分け | 参照先・配置 |
| --- | --- | --- | --- |
| 着任・情報源の整理 | product-onboarding | 役割、接続先、人・仕様・実装・課題の関係表 | [キャッチアップキット](../../templates/product-onboarding/README.md) |
| プロジェクト計画 | project-planning | 目的、完了条件、範囲、担当、依存関係、リスク、次の確認点 | [計画スキル](../../stow/agents/.agents/skills/project-planning/SKILL.md) |
| 機能仕様 | source-command-spec | ユーザーストーリー、受け入れ基準、入出力、エラー | [仕様スキル](../../stow/agents/.agents/skills/source-command-spec/SKILL.md) |
| 計画の説明・合意形成 | create-story-slides | 計画・提案・振り返りの構成、Marp、PDF。目的に合うモードを選択 | [物語型スライド](../../stow/design/.agents/skills/create-story-slides/SKILL.md) |
| OVSテーマの資料制作 | source-command-slides | 共通OVSのMarkdown・Marp資料、描画検証 | [スライドスキル](../../stow/agents/.agents/skills/source-command-slides/SKILL.md) |
| 日程・ロードマップ・状況の可視化 | otake-visual / ovs | timeline、gantt、roadmap、status-board。図の元データも保持 | [OVSスキル](../../stow/design/.agents/skills/otake-visual/SKILL.md) |
| 技術構成・処理の可視化 | archify | アーキテクチャ、ワークフロー、シーケンス等のHTML図解 | [図解スキル](../../stow/agents/.agents/skills/archify/SKILL.md) |
| 開発作業の実行 | Orca | リポジトリ、worktree、エージェント、ターミナルの作業環境 | [dotfilesの導入手順](../../README.md#orcaの導入確認) |
| 開発状況の定期確認 | dev-triage | PR、CI失敗、次の一手の読み取り専用整理 | [Automation定義](../../orca/automations/dev-triage.md) |
| 個人の判断・振り返り | personal-agent | 個人Vaultを根拠に相談、明示的に依頼された記録、週次振り返り | [個人エージェント](../../stow/agents/.agents/skills/personal-agent/SKILL.md) |

共通スキルの配置には既存の `make install-agents` と `make install-design` を利用する。Orcaの登録状態やAutomationの有効化は各端末で確認する。

## サービス接続の候補

[接続台帳の雛形](../../templates/product-onboarding/connections.template.md)にGoogle Sheets、Asana、GitHub/GitLabなどの候補がある。実際に使うサービスについて対象組織、権限、検索・取得の動作確認を記録する。雛形への掲載だけでは接続済みと扱わない。

同じ課題や進捗を複数サービスへ手作業で複製する前に、課題・日程・意思決定それぞれの正本を選び、他の資料からリンクする。

## リポジトリ台帳

| リポジトリ | 役割 | 確認状況 | 次の確認 |
| --- | --- | --- | --- |
| [dotfiles](../../README.md) | 共通スキル・環境・雛形・この入口 | ローカルの関連ファイルを確認済み | 新しいツールと用途の追記 |
| otake-shol/obsidian | 個人VaultとObsidian設定 | dotfilesのREADMEに記載。本体は未調査 | 必要な時に個人記録の入口を確認 |
| [project-portfolio-sheets](https://github.com/otake-shol/project-portfolio-sheets) | Google Sheetsの単一案件・プロジェクト横断管理 | README確認済み。過去の利用相談も確認 | 既存シートと公開テンプレートの使い分け |
| [project-plan-workspace](https://github.com/otake-shol/project-plan-workspace)（Planbase） | 計画JSONをタスク・Scrumボード・依存関係・予測ガント・Overviewへ展開 | README確認済み。過去の関連履歴も確認 | 正本JSONと説明資料の接続 |
| [github-pm-baseline](https://github.com/otake-shol/github-pm-baseline) | Issue、ラベル、Project、Actions、PM文書の導入テンプレート | README確認済み。過去の共有候補にも掲載 | 対象リポジトリの現行設定との照合 |
| [team-playbook](https://github.com/otake-shol/team-playbook) | チーム開発ルール、PMテンプレート、半期計画ツール | READMEとPM・計画ツールのREADMEを確認済み。過去の共有候補にも掲載 | 共通スキルと既存テンプレートの使い分け |
| [ai-dev-flow](https://github.com/otake-shol/ai-dev-flow) | AIを前提にした責務分担、委譲、レビュー、開発フロー | README確認済み。過去の制作履歴も確認 | 計画から実行への委譲項目の再利用 |
| [knowledge-base](https://github.com/otake-shol/knowledge-base) | PM・チーム管理・開発プロセスの心得と雛形 | README確認済み。今回の共有対象との一致は未確認 | 現在も使う雛形と正本の確認 |
| [slides](https://github.com/otake-shol/slides) | Marp原稿・テーマ・書き出しの成果物管理 | README確認済み。今回の共有対象との一致は未確認 | 汎用資料と案件内の資料の保存先の選択 |
| [zenn-content](https://github.com/otake-shol/zenn-content) | Zenn記事の原稿・画像とGitHub連携 | ローカルのorigin・原稿・公開作業記録を2026-10-12に確認 | 更新時に公開版とローカル原稿の差分を照合 |

2026-10-08に本人のGitHubリポジトリ一覧と過去のやり取りを照合した。主要5件には関連履歴がある。確認済みの範囲は上表の文書までで、各ツールのビルド・動作・現在の接続状態は未検証。会話ログの原文はこの入口へ転記しない。

追加時の項目: リポジトリ名・URL、解決する課題、再利用できる資産、その資産の正本、利用条件、最終確認日。個別案件の原文や非公開の情報をこの一覧へ転記しない。

## 既存資産の使い分け

| やりたいこと | 第一候補 | 計画・進捗の正本 |
| --- | --- | --- |
| 複数案件の健康度・リスク・依存関係を一覧管理 | project-portfolio-sheetsのPortfolio版 | 運用中のGoogle Sheets。再生成用の実データは非公開側 |
| 単一案件の憲章・WBS・工数・RAID・変更を管理 | project-portfolio-sheetsのSingle版 | 運用中のGoogle Sheets。WBSを日程・作業の入力元に使用 |
| 計画をGitで管理し、ボード・ガント・Overviewへ展開 | project-plan-workspace | `*.project-plan.json`。ブラウザの下書きは一時保存 |
| GitHubで課題・進捗・PM運用を整備 | github-pm-baseline | 対象リポジトリのIssue・Project・文書 |
| 半期のチーム計画・会議・スクラムの雛形を利用 | team-playbook | チームが採用した計画書・課題管理 |
| 計画した仕事をAIへ委譲し、レビューして進める | ai-dev-flow | 対象プロジェクトの委譲パッケージと実行記録 |

特に計画スライドには既存の [team-playbook / planning-toolkit](https://github.com/otake-shol/team-playbook/tree/main/planning-toolkit) がある。振り返り・事業状況・OKR・体制・文化の半期計画をMarpで作るツール。既存形式を継続する場合はこちらを使い、新しい計画資料の構成・表現にはdotfilesの `project-planning` と `create-story-slides` を組み合わせる。動作確認やテンプレートの移植は別途必要。

PlanbaseやSheetsを採用済みなら、同じ内容のMarkdown計画を別の正本として追加しない。スライド用に要約する際は元のID・版・確認日・未決事項を引き継ぐ。各リポジトリのコード・テンプレートを集約先へコピーする前に、既存の利用先と更新方法を確認する。

## 計画からスライドまでの流れ

[プロジェクト計画スライドの雛形](../../templates/project-plan-slides/README.md)に、目的・範囲・実行条件・判断・運用をつなぐ18枚のMarp原稿を用意している。入力済みの計画は各案件で管理し、既存の正本から要約する。

[L0・L1・L2の整理](../../stow/agents/.agents/skills/project-planning/references/schedule-levels.md)に、L0の全体計画1枚、L1の工程管理、L2の実行計画をまとめている。スライドの9〜11枚目にも対応し、親ID・依存関係・変更理由で階層をつなぐ。

L1・L2のスプレッドシートには既存の [単一プロジェクト管理｜公開テンプレート](https://docs.google.com/spreadsheets/d/1CFKVIIpwmEBr49hhlaEwsajoBLPVZlGvLQTtV5fjT3I/edit)を使う。[Sheetsへの対応ガイド](../../stow/agents/.agents/skills/project-planning/references/sheets-schedule.md)にWBSの列対応、工程・詳細作業の抽出、ガント、スライドへの展開をまとめた。2026-10-10に実シートの構成・数式・入力規則を確認済み。公開ブックへの書き込みは未実施。

1. 対象プロジェクトの資料と課題を確認し、目的・制約・未決事項を整理する。
2. `project-planning` で計画を作る。日付や担当者が未決なら未決と記載し、確定に必要な判断を残す。
3. 計画の正本を対象プロジェクトに保存する。既存の計画書があれば更新を優先する。
4. スライドが必要な場合だけ `create-story-slides` に計画を渡す。合意形成には計画モード、承認・選択が目的なら提案モードを使う。
5. 実行中は課題の正本と計画を更新する。発表資料の要約を独立した進捗台帳にしない。

```text
$project-planning このプロジェクトの資料から計画を作って。
目的、完了条件、優先順位、担当、依存関係、リスク、次の確認点を整理して。

$project-planning この計画をチームの合意形成用スライドにして。
計画の正本への参照と未決事項を保ち、create-story-slidesを使って。
```

## 整理の継続項目

2026-10-12に計画スキル・計画書雛形・スライド・Sheets対応ガイドへ3点を反映。継続・縮小・中止の再判断条件、決定の前提と見直し条件、受け手による実行確認と残件の引受先を扱う。参照章は [計画書雛形の出典](../../stow/agents/.agents/skills/project-planning/references/project-plan.md#出典と変更記録)に記載。既存のGoogle Sheets本体は未変更。

- 台帳の主要5件から現在使うツールを選び、対象案件の正本と既存設定を確認。
- 実際のプロジェクト計画でスキルを試し、必要だった項目だけを雛形へ反映。
- 計画、課題、意思決定、スライドそれぞれの正本と更新担当を案件ごとに決定。
- 独立した利用者・配布単位ができた場合に集約用リポジトリへの分離を判断。
