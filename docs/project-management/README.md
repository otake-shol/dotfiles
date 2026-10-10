# プロジェクト管理ツールの入口

目的に応じて既存のスキル・テンプレート・リポジトリを選ぶための一覧。確認日: 2026-10-08。
dotfilesで共通の手順と空の雛形を管理し、各プロジェクトで計画・課題・成果物を管理する。

## 集約先と正本

| 情報 | 正本 | この入口での管理 |
| --- | --- | --- |
| 共通スキル・ツール設定・空の雛形 | dotfiles | 用途、参照先、利用例 |
| プロジェクト計画・課題・進捗・成果物 | 各プロジェクトで選んだリポジトリや管理サービス | 参照先と役割 |
| 個人の判断・活動記録 | 個人のObsidian Vault | 記録先の説明 |
| 業務固有の情報・入力済み接続台帳 | 組織で許可された非公開の領域 | 共通の空の雛形のみ |

現時点ではdotfilesに入口を追加する。複数人での利用や独立した配布・更新が必要になった時点で、専用リポジトリへの分離を検討する。スキルやテーマの実体は既存の配置を維持し、一覧から参照する。

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

- 台帳の主要5件から現在使うツールを選び、対象案件の正本と既存設定を確認。
- 実際のプロジェクト計画でスキルを試し、必要だった項目だけを雛形へ反映。
- 計画、課題、意思決定、スライドそれぞれの正本と更新担当を案件ごとに決定。
- 独立した利用者・配布単位ができた場合に集約用リポジトリへの分離を判断。
