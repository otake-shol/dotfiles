#!/bin/bash
# pmbok-spreadsheet.sh - PMBOK準拠プロジェクト管理スプレッドシート自動生成
# 使用方法: bash scripts/setup/pmbok-spreadsheet.sh [--phase 1|2|3] [--title "プロジェクト名"]
#
# 前提条件:
#   - gws CLI インストール済み (npm install -g @anthropic-ai/gws)
#   - gws auth login 完了済み
#   - Google Sheets API 有効化済み

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 共通ライブラリ読み込み
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# ========================================
# デフォルト設定
# ========================================
PHASE=1
PROJECT_TITLE="新規プロジェクト"
SPREADSHEET_ID=""
DRY_RUN=false

# ========================================
# ヘルプ表示
# ========================================
show_help() {
    cat << 'EOF'
PMBOK準拠プロジェクト管理スプレッドシート自動生成

Usage:
  bash scripts/setup/pmbok-spreadsheet.sh [OPTIONS]

Options:
  --phase 1|2|3      導入フェーズ (デフォルト: 1)
  --title "名前"     プロジェクト名 (デフォルト: "新規プロジェクト")
  --id SPREADSHEET_ID 既存スプレッドシートにシートを追加
  -h, --help         このヘルプを表示

Phases:
  1  最小構成 (4シート): ダッシュボード, WBS, 課題管理, リスク管理
  2  標準構成 (7シート): Phase1 + プロジェクト憲章, RACI, 予算管理
  3  フル構成 (10シート): Phase2 + ステークホルダー, コミュニケーション計画, 変更管理

Examples:
  bash scripts/setup/pmbok-spreadsheet.sh --phase 1 --title "MVP開発"
  bash scripts/setup/pmbok-spreadsheet.sh --phase 3 --title "基幹システム刷新"
  bash scripts/setup/pmbok-spreadsheet.sh --phase 2 --id "1BxiMVs0XRA..."
EOF
}

# ========================================
# 引数パース
# ========================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        --phase) PHASE="$2"; shift 2 ;;
        --title) PROJECT_TITLE="$2"; shift 2 ;;
        --id) SPREADSHEET_ID="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "不明なオプション: $1"; show_help; exit 1 ;;
    esac
done

# ========================================
# 前提条件チェック
# ========================================
check_prerequisites() {
    print_section "前提条件チェック"

    if ! command -v gws &>/dev/null; then
        check_fail "gws CLI が見つかりません"
        echo "  インストール: npm install -g @anthropic-ai/gws"
        exit 1
    fi
    check_pass "gws CLI: $(gws --version 2>/dev/null)"

    if ! command -v jq &>/dev/null; then
        check_fail "jq が見つかりません"
        echo "  インストール: brew install jq"
        exit 1
    fi
    check_pass "jq: $(jq --version 2>/dev/null)"

    # 認証チェック
    local auth_status
    auth_status=$(gws auth status 2>/dev/null | jq -r '.auth_method // "none"')
    if [[ "$auth_status" == "none" ]]; then
        check_fail "gws 認証が未設定です"
        echo "  セットアップ手順:"
        echo "    1. Google Cloud Console で OAuth クライアントID を作成"
        echo "    2. client_secret.json を ~/.config/gws/ に配置"
        echo "    3. gws auth login --scopes https://www.googleapis.com/auth/spreadsheets,https://www.googleapis.com/auth/drive"
        exit 1
    fi
    check_pass "gws 認証: $auth_status"
}

# ========================================
# スプレッドシート作成
# ========================================
create_spreadsheet() {
    local title="$1"
    print_section "スプレッドシート作成: $title"

    local json
    json=$(generate_create_json "$title")

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "$json" | jq . > /tmp/pmbok-dry-run.json
        check_pass "ドライラン: /tmp/pmbok-dry-run.json に出力"
        exit 0
    fi

    local result
    result=$(gws sheets spreadsheets create --json "$json" --format json 2>/dev/null)

    SPREADSHEET_ID=$(echo "$result" | jq -r '.spreadsheetId')
    local url
    url=$(echo "$result" | jq -r '.spreadsheetUrl')

    if [[ -z "$SPREADSHEET_ID" || "$SPREADSHEET_ID" == "null" ]]; then
        check_fail "スプレッドシートの作成に失敗しました"
        echo "$result"
        exit 1
    fi

    check_pass "作成完了: $SPREADSHEET_ID"
    echo -e "  ${CYAN}URL: $url${NC}"
}

# ========================================
# スプレッドシート作成用JSON生成
# ========================================
generate_create_json() {
    local title="$1"
    local sheets_json
    sheets_json=$(generate_sheets_json)

    cat << EOF
{
  "properties": {
    "title": "[PMBOK] $title",
    "locale": "ja_JP",
    "defaultFormat": {
      "textFormat": {
        "fontFamily": "Noto Sans JP",
        "fontSize": 10
      }
    }
  },
  "sheets": $sheets_json
}
EOF
}

# ========================================
# フェーズに応じたシート定義生成
# ========================================
generate_sheets_json() {
    local sheets=()

    # Phase 1: 最小構成
    sheets+=("$(sheet_dashboard)")
    sheets+=("$(sheet_wbs)")
    sheets+=("$(sheet_issue_log)")
    sheets+=("$(sheet_risk_log)")

    # Phase 2: 標準構成
    if [[ "$PHASE" -ge 2 ]]; then
        sheets+=("$(sheet_project_charter)")
        sheets+=("$(sheet_raci)")
        sheets+=("$(sheet_budget)")
    fi

    # Phase 3: フル構成
    if [[ "$PHASE" -ge 3 ]]; then
        sheets+=("$(sheet_stakeholder)")
        sheets+=("$(sheet_communication_plan)")
        sheets+=("$(sheet_change_log)")
    fi

    # Config シート（常に追加）
    sheets+=("$(sheet_config)")

    # JSON配列に変換（indexを連番で上書き）
    local result="["
    local first=true
    local idx=0
    for s in "${sheets[@]}"; do
        if [[ "$first" == "true" ]]; then
            first=false
        else
            result+=","
        fi
        # index と sheetId を連番に上書き
        result+="$(echo "$s" | jq --argjson i "$idx" '.properties.index = $i | .properties.sheetId = $i')"
        ((idx++))
    done
    result+="]"
    echo "$result"
}

# ========================================
# シートID動的マップ
# ========================================
declare -A SHEET_ID_MAP

build_sheet_id_map() {
    local idx=0
    SHEET_ID_MAP["ダッシュボード"]=$((idx++))
    SHEET_ID_MAP["WBS"]=$((idx++))
    SHEET_ID_MAP["課題管理"]=$((idx++))
    SHEET_ID_MAP["リスク管理"]=$((idx++))
    if [[ "$PHASE" -ge 2 ]]; then
        SHEET_ID_MAP["プロジェクト憲章"]=$((idx++))
        SHEET_ID_MAP["RACI"]=$((idx++))
        SHEET_ID_MAP["予算管理"]=$((idx++))
    fi
    if [[ "$PHASE" -ge 3 ]]; then
        SHEET_ID_MAP["ステークホルダー"]=$((idx++))
        SHEET_ID_MAP["コミュニケーション計画"]=$((idx++))
        SHEET_ID_MAP["変更管理"]=$((idx++))
    fi
    SHEET_ID_MAP["マスタ"]=$((idx++))
}

# ========================================
# 個別シート定義
# ========================================

# --- Dashboard ---
sheet_dashboard() {
    cat << 'SHEET'
{
  "properties": {
    "title": "ダッシュボード",
    "index": 0,
    "tabColorStyle": {"rgbColor": {"red": 0.2, "green": 0.66, "blue": 0.33}}
  },
  "data": [{
    "startRow": 0, "startColumn": 0,
    "rowData": [
      {"values": [
        {"userEnteredValue": {"stringValue": "プロジェクトダッシュボード"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 16}}},
        {}, {}, {},
        {"userEnteredValue": {"stringValue": "最終更新:"}, "userEnteredFormat": {"textFormat": {"bold": true}}},
        {"userEnteredValue": {"formulaValue": "=NOW()"}, "userEnteredFormat": {"numberFormat": {"type": "DATE_TIME", "pattern": "yyyy/MM/dd HH:mm"}}}
      ]},
      {},
      {"values": [
        {"userEnteredValue": {"stringValue": "KPI"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 12}, "backgroundColor": {"red": 0.9, "green": 0.9, "blue": 0.95}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "総タスク数"}},
        {"userEnteredValue": {"formulaValue": "=COUNTA(WBS!A3:A)"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "完了タスク"}},
        {"userEnteredValue": {"formulaValue": "=COUNTIF(WBS!G3:G,\"完了\")"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "進行中タスク"}},
        {"userEnteredValue": {"formulaValue": "=COUNTIF(WBS!G3:G,\"進行中\")"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "進捗率"}},
        {"userEnteredValue": {"formulaValue": "=IFERROR(COUNTIF(WBS!G3:G,\"完了\")/COUNTA(WBS!A3:A),0)"}, "userEnteredFormat": {"numberFormat": {"type": "PERCENT", "pattern": "0.0%"}}}
      ]},
      {},
      {"values": [
        {"userEnteredValue": {"stringValue": "リスクサマリー"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 12}, "backgroundColor": {"red": 0.95, "green": 0.9, "blue": 0.9}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "オープンリスク"}},
        {"userEnteredValue": {"formulaValue": "=COUNTIF('リスク管理'!B3:B,\"Risk\")-COUNTIF('リスク管理'!G3:G,\"Closed\")"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "高リスク"}},
        {"userEnteredValue": {"formulaValue": "=COUNTIFS('リスク管理'!B3:B,\"Risk\",'リスク管理'!E3:E,\"高\")"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "オープン課題"}},
        {"userEnteredValue": {"formulaValue": "=COUNTIFS('課題管理'!E3:E,\"<>完了\",'課題管理'!E3:E,\"<>\")"}}
      ]}
    ]
  }]
}
SHEET
}

# --- WBS / Schedule ---
sheet_wbs() {
    cat << 'SHEET'
{
  "properties": {
    "title": "WBS",
    "index": 1,
    "tabColorStyle": {"rgbColor": {"red": 0.26, "green": 0.52, "blue": 0.96}}
  },
  "data": [{
    "startRow": 0, "startColumn": 0,
    "rowData": [
      {"values": [
        {"userEnteredValue": {"stringValue": "WBS / スケジュール"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 14}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "WBS ID"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "階層"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "タスク名"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "担当者"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "開始日"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "終了日"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "ステータス"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "進捗%"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "依存関係"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "備考"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.85, "blue": 0.95}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "1"}},
        {"userEnteredValue": {"stringValue": "Epic"}},
        {"userEnteredValue": {"stringValue": "(例) フェーズ1: 要件定義"}},
        {},
        {"userEnteredValue": {"stringValue": "2026/04/01"}, "userEnteredFormat": {"numberFormat": {"type": "DATE", "pattern": "yyyy/MM/dd"}}},
        {"userEnteredValue": {"stringValue": "2026/04/30"}, "userEnteredFormat": {"numberFormat": {"type": "DATE", "pattern": "yyyy/MM/dd"}}},
        {"userEnteredValue": {"stringValue": "未着手"}},
        {"userEnteredValue": {"numberValue": 0}, "userEnteredFormat": {"numberFormat": {"type": "PERCENT", "pattern": "0%"}}},
        {},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "1.1"}},
        {"userEnteredValue": {"stringValue": "Story"}},
        {"userEnteredValue": {"stringValue": "  ステークホルダーヒアリング"}},
        {"userEnteredValue": {"stringValue": "PM"}},
        {"userEnteredValue": {"stringValue": "2026/04/01"}, "userEnteredFormat": {"numberFormat": {"type": "DATE", "pattern": "yyyy/MM/dd"}}},
        {"userEnteredValue": {"stringValue": "2026/04/07"}, "userEnteredFormat": {"numberFormat": {"type": "DATE", "pattern": "yyyy/MM/dd"}}},
        {"userEnteredValue": {"stringValue": "未着手"}},
        {"userEnteredValue": {"numberValue": 0}, "userEnteredFormat": {"numberFormat": {"type": "PERCENT", "pattern": "0%"}}},
        {},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "1.1.1"}},
        {"userEnteredValue": {"stringValue": "Task"}},
        {"userEnteredValue": {"stringValue": "    インタビュー日程調整"}},
        {"userEnteredValue": {"stringValue": "PM"}},
        {"userEnteredValue": {"stringValue": "2026/04/01"}, "userEnteredFormat": {"numberFormat": {"type": "DATE", "pattern": "yyyy/MM/dd"}}},
        {"userEnteredValue": {"stringValue": "2026/04/02"}, "userEnteredFormat": {"numberFormat": {"type": "DATE", "pattern": "yyyy/MM/dd"}}},
        {"userEnteredValue": {"stringValue": "未着手"}},
        {"userEnteredValue": {"numberValue": 0}, "userEnteredFormat": {"numberFormat": {"type": "PERCENT", "pattern": "0%"}}},
        {},
        {}
      ]}
    ]
  }]
}
SHEET
}

# --- リスク管理 ---
sheet_risk_log() {
    cat << 'SHEET'
{
  "properties": {
    "title": "リスク管理",
    "index": 2,
    "tabColorStyle": {"rgbColor": {"red": 0.96, "green": 0.26, "blue": 0.21}}
  },
  "data": [{
    "startRow": 0, "startColumn": 0,
    "rowData": [
      {"values": [
        {"userEnteredValue": {"stringValue": "リスク管理 (Risk / Action / Decision)"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 14}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "ID"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.95, "green": 0.85, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "種別"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.95, "green": 0.85, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "タイトル"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.95, "green": 0.85, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "詳細"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.95, "green": 0.85, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "優先度"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.95, "green": 0.85, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "担当者"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.95, "green": 0.85, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "ステータス"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.95, "green": 0.85, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "期日"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.95, "green": 0.85, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "対応策"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.95, "green": 0.85, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "登録日"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.95, "green": 0.85, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "更新日"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.95, "green": 0.85, "blue": 0.85}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "R-001"}},
        {"userEnteredValue": {"stringValue": "Risk"}},
        {"userEnteredValue": {"stringValue": "(例) 主要メンバーの離脱リスク"}},
        {"userEnteredValue": {"stringValue": "キーパーソンが他プロジェクトにアサインされる可能性"}},
        {"userEnteredValue": {"stringValue": "高"}},
        {"userEnteredValue": {"stringValue": "PM"}},
        {"userEnteredValue": {"stringValue": "Open"}},
        {"userEnteredValue": {"stringValue": "2026/04/15"}, "userEnteredFormat": {"numberFormat": {"type": "DATE", "pattern": "yyyy/MM/dd"}}},
        {"userEnteredValue": {"stringValue": "バックアップ担当者の育成、ナレッジ共有の仕組み構築"}},
        {"userEnteredValue": {"formulaValue": "=TODAY()"}, "userEnteredFormat": {"numberFormat": {"type": "DATE", "pattern": "yyyy/MM/dd"}}},
        {"userEnteredValue": {"formulaValue": "=TODAY()"}, "userEnteredFormat": {"numberFormat": {"type": "DATE", "pattern": "yyyy/MM/dd"}}}
      ]}
    ]
  }]
}
SHEET
}

# --- 課題管理 ---
sheet_issue_log() {
    cat << 'SHEET'
{
  "properties": {
    "title": "課題管理",
    "tabColorStyle": {"rgbColor": {"red": 0.96, "green": 0.47, "blue": 0.0}}
  },
  "data": [{
    "startRow": 0, "startColumn": 0,
    "rowData": [
      {"values": [
        {"userEnteredValue": {"stringValue": "課題管理表"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 16}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "NO"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.88, "blue": 0.75}}},
        {"userEnteredValue": {"stringValue": "工程"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.88, "blue": 0.75}}},
        {"userEnteredValue": {"stringValue": "カテゴリ"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.88, "blue": 0.75}}},
        {"userEnteredValue": {"stringValue": "課題内容"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.88, "blue": 0.75}}},
        {"userEnteredValue": {"stringValue": "ステータス"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.88, "blue": 0.75}}},
        {"userEnteredValue": {"stringValue": "起票日"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.88, "blue": 0.75}}},
        {"userEnteredValue": {"stringValue": "起票者"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.88, "blue": 0.75}}},
        {"userEnteredValue": {"stringValue": "担当"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.88, "blue": 0.75}}},
        {"userEnteredValue": {"stringValue": "結論"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.88, "blue": 0.75}}},
        {"userEnteredValue": {"stringValue": "Slack URL"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.88, "blue": 0.75}}}
      ]},
      {"values": [
        {"userEnteredValue": {"numberValue": 1}},
        {"userEnteredValue": {"stringValue": "開発"}},
        {"userEnteredValue": {"stringValue": "パフォーマンス"}},
        {"userEnteredValue": {"stringValue": "(例) 本番環境のレスポンス遅延（ピーク時にAPIレスポンスが3秒以上）"}},
        {"userEnteredValue": {"stringValue": "対応中"}},
        {"userEnteredValue": {"formulaValue": "=TODAY()"}, "userEnteredFormat": {"numberFormat": {"type": "DATE", "pattern": "yyyy/MM/dd"}}},
        {"userEnteredValue": {"stringValue": "QA"}},
        {"userEnteredValue": {"stringValue": "TL"}},
        {"userEnteredValue": {"stringValue": "DBインデックス追加＋キャッシュ導入で対応"}},
        {"userEnteredValue": {"stringValue": "https://example.slack.com/archives/C0000/p0000"}}
      ]}
    ]
  }]
}
SHEET
}

# --- Project Charter (Phase 2) ---
sheet_project_charter() {
    cat << 'SHEET'
{
  "properties": {
    "title": "プロジェクト憲章",
    "index": 3,
    "tabColorStyle": {"rgbColor": {"red": 0.98, "green": 0.74, "blue": 0.02}}
  },
  "data": [{
    "startRow": 0, "startColumn": 0,
    "rowData": [
      {"values": [
        {"userEnteredValue": {"stringValue": "プロジェクト憲章"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 16}}}
      ]},
      {},
      {"values": [
        {"userEnteredValue": {"stringValue": "項目"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.92, "blue": 0.75}}},
        {"userEnteredValue": {"stringValue": "内容"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.98, "green": 0.92, "blue": 0.75}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "プロジェクト名"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "プロジェクトマネージャー"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "スポンサー"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "目的・ビジネス価値"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "スコープ（含む）"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "スコープ（含まない）"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "成功基準"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "主要マイルストーン"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "予算概算"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "前提条件"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "制約条件"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "主要リスク"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "承認者"}},
        {}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "承認日"}},
        {"userEnteredFormat": {"numberFormat": {"type": "DATE", "pattern": "yyyy/MM/dd"}}}
      ]}
    ]
  }]
}
SHEET
}

# --- RACI Matrix (Phase 2) ---
sheet_raci() {
    cat << 'SHEET'
{
  "properties": {
    "title": "RACI",
    "index": 4,
    "tabColorStyle": {"rgbColor": {"red": 0.61, "green": 0.15, "blue": 0.69}}
  },
  "data": [{
    "startRow": 0, "startColumn": 0,
    "rowData": [
      {"values": [
        {"userEnteredValue": {"stringValue": "RACI 責任分担マトリクス"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 14}}},
        {}, {},
        {"userEnteredValue": {"stringValue": "R=実行責任 A=説明責任 C=相談 I=報告"}, "userEnteredFormat": {"textFormat": {"italic": true, "fontSize": 9}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "カテゴリ"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.88, "green": 0.82, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "作業項目"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.88, "green": 0.82, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "PM"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.88, "green": 0.82, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "TL"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.88, "green": 0.82, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "Dev"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.88, "green": 0.82, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "QA"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.88, "green": 0.82, "blue": 0.95}}},
        {"userEnteredValue": {"stringValue": "ビジネス"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.88, "green": 0.82, "blue": 0.95}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "計画"}},
        {"userEnteredValue": {"stringValue": "スコープ定義"}},
        {"userEnteredValue": {"stringValue": "A"}},
        {"userEnteredValue": {"stringValue": "R"}},
        {"userEnteredValue": {"stringValue": "C"}},
        {"userEnteredValue": {"stringValue": "I"}},
        {"userEnteredValue": {"stringValue": "C"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "計画"}},
        {"userEnteredValue": {"stringValue": "スケジュール作成"}},
        {"userEnteredValue": {"stringValue": "A"}},
        {"userEnteredValue": {"stringValue": "R"}},
        {"userEnteredValue": {"stringValue": "C"}},
        {"userEnteredValue": {"stringValue": "I"}},
        {"userEnteredValue": {"stringValue": "I"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "実行"}},
        {"userEnteredValue": {"stringValue": "設計"}},
        {"userEnteredValue": {"stringValue": "I"}},
        {"userEnteredValue": {"stringValue": "A"}},
        {"userEnteredValue": {"stringValue": "R"}},
        {"userEnteredValue": {"stringValue": "C"}},
        {"userEnteredValue": {"stringValue": "I"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "実行"}},
        {"userEnteredValue": {"stringValue": "実装"}},
        {"userEnteredValue": {"stringValue": "I"}},
        {"userEnteredValue": {"stringValue": "A"}},
        {"userEnteredValue": {"stringValue": "R"}},
        {"userEnteredValue": {"stringValue": "I"}},
        {"userEnteredValue": {"stringValue": ""}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "テスト"}},
        {"userEnteredValue": {"stringValue": "テスト計画"}},
        {"userEnteredValue": {"stringValue": "I"}},
        {"userEnteredValue": {"stringValue": "C"}},
        {"userEnteredValue": {"stringValue": "C"}},
        {"userEnteredValue": {"stringValue": "R"}},
        {"userEnteredValue": {"stringValue": "A"}}
      ]}
    ]
  }]
}
SHEET
}

# --- Budget / Cost (Phase 2) ---
sheet_budget() {
    cat << 'SHEET'
{
  "properties": {
    "title": "予算管理",
    "index": 5,
    "tabColorStyle": {"rgbColor": {"red": 0.0, "green": 0.59, "blue": 0.53}}
  },
  "data": [{
    "startRow": 0, "startColumn": 0,
    "rowData": [
      {"values": [
        {"userEnteredValue": {"stringValue": "予算管理 / EVM"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 14}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "カテゴリ"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.8, "green": 0.94, "blue": 0.92}}},
        {"userEnteredValue": {"stringValue": "項目"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.8, "green": 0.94, "blue": 0.92}}},
        {"userEnteredValue": {"stringValue": "計画予算 (PV)"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.8, "green": 0.94, "blue": 0.92}}},
        {"userEnteredValue": {"stringValue": "実績コスト (AC)"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.8, "green": 0.94, "blue": 0.92}}},
        {"userEnteredValue": {"stringValue": "出来高 (EV)"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.8, "green": 0.94, "blue": 0.92}}},
        {"userEnteredValue": {"stringValue": "SPI"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.8, "green": 0.94, "blue": 0.92}}},
        {"userEnteredValue": {"stringValue": "CPI"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.8, "green": 0.94, "blue": 0.92}}},
        {"userEnteredValue": {"stringValue": "備考"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.8, "green": 0.94, "blue": 0.92}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "人件費"}},
        {"userEnteredValue": {"stringValue": "開発チーム"}},
        {"userEnteredValue": {"numberValue": 0}, "userEnteredFormat": {"numberFormat": {"type": "NUMBER", "pattern": "#,##0"}}},
        {"userEnteredValue": {"numberValue": 0}, "userEnteredFormat": {"numberFormat": {"type": "NUMBER", "pattern": "#,##0"}}},
        {"userEnteredValue": {"numberValue": 0}, "userEnteredFormat": {"numberFormat": {"type": "NUMBER", "pattern": "#,##0"}}},
        {"userEnteredValue": {"formulaValue": "=IFERROR(E3/C3,0)"}, "userEnteredFormat": {"numberFormat": {"type": "NUMBER", "pattern": "0.00"}}},
        {"userEnteredValue": {"formulaValue": "=IFERROR(E3/D3,0)"}, "userEnteredFormat": {"numberFormat": {"type": "NUMBER", "pattern": "0.00"}}},
        {}
      ]},
      {},
      {"values": [
        {"userEnteredValue": {"stringValue": "合計"}, "userEnteredFormat": {"textFormat": {"bold": true}}},
        {},
        {"userEnteredValue": {"formulaValue": "=SUM(C3:C3)"}, "userEnteredFormat": {"textFormat": {"bold": true}, "numberFormat": {"type": "NUMBER", "pattern": "#,##0"}}},
        {"userEnteredValue": {"formulaValue": "=SUM(D3:D3)"}, "userEnteredFormat": {"textFormat": {"bold": true}, "numberFormat": {"type": "NUMBER", "pattern": "#,##0"}}},
        {"userEnteredValue": {"formulaValue": "=SUM(E3:E3)"}, "userEnteredFormat": {"textFormat": {"bold": true}, "numberFormat": {"type": "NUMBER", "pattern": "#,##0"}}},
        {"userEnteredValue": {"formulaValue": "=IFERROR(E6/C6,0)"}, "userEnteredFormat": {"textFormat": {"bold": true}, "numberFormat": {"type": "NUMBER", "pattern": "0.00"}}},
        {"userEnteredValue": {"formulaValue": "=IFERROR(E6/D6,0)"}, "userEnteredFormat": {"textFormat": {"bold": true}, "numberFormat": {"type": "NUMBER", "pattern": "0.00"}}}
      ]},
      {},
      {"values": [
        {"userEnteredValue": {"stringValue": "EVM指標の読み方"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 11}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "SPI > 1.0: スケジュール前倒し / SPI < 1.0: スケジュール遅延"}, "userEnteredFormat": {"textFormat": {"fontSize": 9}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "CPI > 1.0: コスト効率良好 / CPI < 1.0: コスト超過"}, "userEnteredFormat": {"textFormat": {"fontSize": 9}}}
      ]}
    ]
  }]
}
SHEET
}

# --- Stakeholder Register (Phase 3) ---
sheet_stakeholder() {
    cat << 'SHEET'
{
  "properties": {
    "title": "ステークホルダー",
    "index": 6,
    "tabColorStyle": {"rgbColor": {"red": 1.0, "green": 0.6, "blue": 0.0}}
  },
  "data": [{
    "startRow": 0, "startColumn": 0,
    "rowData": [
      {"values": [
        {"userEnteredValue": {"stringValue": "ステークホルダー登録簿"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 14}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "名前"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 1.0, "green": 0.9, "blue": 0.8}}},
        {"userEnteredValue": {"stringValue": "役割"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 1.0, "green": 0.9, "blue": 0.8}}},
        {"userEnteredValue": {"stringValue": "組織"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 1.0, "green": 0.9, "blue": 0.8}}},
        {"userEnteredValue": {"stringValue": "影響度"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 1.0, "green": 0.9, "blue": 0.8}}},
        {"userEnteredValue": {"stringValue": "関心度"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 1.0, "green": 0.9, "blue": 0.8}}},
        {"userEnteredValue": {"stringValue": "関与戦略"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 1.0, "green": 0.9, "blue": 0.8}}},
        {"userEnteredValue": {"stringValue": "連絡方法"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 1.0, "green": 0.9, "blue": 0.8}}},
        {"userEnteredValue": {"stringValue": "備考"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 1.0, "green": 0.9, "blue": 0.8}}}
      ]}
    ]
  }]
}
SHEET
}

# --- Communication Plan (Phase 3) ---
sheet_communication_plan() {
    cat << 'SHEET'
{
  "properties": {
    "title": "コミュニケーション計画",
    "index": 7,
    "tabColorStyle": {"rgbColor": {"red": 0.4, "green": 0.73, "blue": 0.42}}
  },
  "data": [{
    "startRow": 0, "startColumn": 0,
    "rowData": [
      {"values": [
        {"userEnteredValue": {"stringValue": "コミュニケーション計画"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 14}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "会議体/報告"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.95, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "目的"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.95, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "頻度"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.95, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "参加者"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.95, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "ツール"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.95, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "成果物"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.95, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "責任者"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.85, "green": 0.95, "blue": 0.85}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "デイリースタンドアップ"}},
        {"userEnteredValue": {"stringValue": "進捗共有・ブロッカー解消"}},
        {"userEnteredValue": {"stringValue": "毎日"}},
        {"userEnteredValue": {"stringValue": "開発チーム"}},
        {"userEnteredValue": {"stringValue": "Slack / Meet"}},
        {"userEnteredValue": {"stringValue": "-"}},
        {"userEnteredValue": {"stringValue": "TL"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "週次ステータス報告"}},
        {"userEnteredValue": {"stringValue": "進捗・リスク・課題の共有"}},
        {"userEnteredValue": {"stringValue": "週1回"}},
        {"userEnteredValue": {"stringValue": "PM, TL, ビジネス"}},
        {"userEnteredValue": {"stringValue": "Meet / Slides"}},
        {"userEnteredValue": {"stringValue": "週次レポート"}},
        {"userEnteredValue": {"stringValue": "PM"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "スプリントレトロ"}},
        {"userEnteredValue": {"stringValue": "振り返り・改善"}},
        {"userEnteredValue": {"stringValue": "隔週"}},
        {"userEnteredValue": {"stringValue": "開発チーム"}},
        {"userEnteredValue": {"stringValue": "Meet / Miro"}},
        {"userEnteredValue": {"stringValue": "改善アクション"}},
        {"userEnteredValue": {"stringValue": "SM"}}
      ]}
    ]
  }]
}
SHEET
}

# --- Change Log (Phase 3) ---
sheet_change_log() {
    cat << 'SHEET'
{
  "properties": {
    "title": "変更管理",
    "index": 8,
    "tabColorStyle": {"rgbColor": {"red": 0.47, "green": 0.33, "blue": 0.28}}
  },
  "data": [{
    "startRow": 0, "startColumn": 0,
    "rowData": [
      {"values": [
        {"userEnteredValue": {"stringValue": "変更管理ログ"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 14}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "変更ID"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.87, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "申請日"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.87, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "申請者"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.87, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "変更内容"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.87, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "影響範囲"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.87, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "ステータス"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.87, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "承認者"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.87, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "承認日"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.87, "blue": 0.85}}},
        {"userEnteredValue": {"stringValue": "備考"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.87, "blue": 0.85}}}
      ]}
    ]
  }]
}
SHEET
}

# --- Config / Master Data ---
sheet_config() {
    cat << 'SHEET'
{
  "properties": {
    "title": "マスタ",
    "tabColorStyle": {"rgbColor": {"red": 0.62, "green": 0.62, "blue": 0.62}}
  },
  "data": [{
    "startRow": 0, "startColumn": 0,
    "rowData": [
      {"values": [
        {"userEnteredValue": {"stringValue": "マスタデータ（ドロップダウン用）"}, "userEnteredFormat": {"textFormat": {"bold": true, "fontSize": 14}}}
      ]},
      {},
      {"values": [
        {"userEnteredValue": {"stringValue": "ステータス"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.9, "blue": 0.9}}},
        {"userEnteredValue": {"stringValue": "優先度"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.9, "blue": 0.9}}},
        {"userEnteredValue": {"stringValue": "リスク管理種別"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.9, "blue": 0.9}}},
        {"userEnteredValue": {"stringValue": "階層"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.9, "blue": 0.9}}},
        {"userEnteredValue": {"stringValue": "RACI値"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.9, "blue": 0.9}}},
        {"userEnteredValue": {"stringValue": "変更ステータス"}, "userEnteredFormat": {"textFormat": {"bold": true}, "backgroundColor": {"red": 0.9, "green": 0.9, "blue": 0.9}}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "未着手"}},
        {"userEnteredValue": {"stringValue": "高"}},
        {"userEnteredValue": {"stringValue": "Risk"}},
        {"userEnteredValue": {"stringValue": "Epic"}},
        {"userEnteredValue": {"stringValue": "R"}},
        {"userEnteredValue": {"stringValue": "申請中"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "進行中"}},
        {"userEnteredValue": {"stringValue": "中"}},
        {"userEnteredValue": {"stringValue": "Action"}},
        {"userEnteredValue": {"stringValue": "Story"}},
        {"userEnteredValue": {"stringValue": "A"}},
        {"userEnteredValue": {"stringValue": "審査中"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "完了"}},
        {"userEnteredValue": {"stringValue": "低"}},
        {},
        {"userEnteredValue": {"stringValue": "Task"}},
        {"userEnteredValue": {"stringValue": "C"}},
        {"userEnteredValue": {"stringValue": "承認"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "保留"}},
        {},
        {"userEnteredValue": {"stringValue": "Decision"}},
        {"userEnteredValue": {"stringValue": "Sub-task"}},
        {"userEnteredValue": {"stringValue": "I"}},
        {"userEnteredValue": {"stringValue": "却下"}}
      ]},
      {"values": [
        {"userEnteredValue": {"stringValue": "中止"}},
        {},
        {},
        {},
        {},
        {"userEnteredValue": {"stringValue": "保留"}}
      ]}
    ]
  }]
}
SHEET
}

# ========================================
# データバリデーション（ドロップダウン）追加
# ========================================
add_data_validations() {
    print_section "データバリデーション設定"

    local wbs_id="${SHEET_ID_MAP["WBS"]}"
    local raid_id="${SHEET_ID_MAP["リスク管理"]}"
    local issue_id="${SHEET_ID_MAP["課題管理"]}"

    local requests='{"requests": ['

    # WBS ステータス (G3:G1000)
    requests+='{"setDataValidation": {"range": {"sheetId": '"$wbs_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 6, "endColumnIndex": 7}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "未着手"}, {"userEnteredValue": "進行中"}, {"userEnteredValue": "完了"}, {"userEnteredValue": "保留"}, {"userEnteredValue": "中止"}]}, "showCustomUi": true, "strict": true}}},'

    # WBS 階層 (B3:B1000)
    requests+='{"setDataValidation": {"range": {"sheetId": '"$wbs_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 1, "endColumnIndex": 2}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "Epic"}, {"userEnteredValue": "Story"}, {"userEnteredValue": "Task"}, {"userEnteredValue": "Sub-task"}]}, "showCustomUi": true, "strict": true}}},'

    # リスク管理 種別 (B3:B1000)
    requests+='{"setDataValidation": {"range": {"sheetId": '"$raid_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 1, "endColumnIndex": 2}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "Risk"}, {"userEnteredValue": "Action"}, {"userEnteredValue": "Decision"}]}, "showCustomUi": true, "strict": true}}},'

    # リスク管理 優先度 (E3:E1000)
    requests+='{"setDataValidation": {"range": {"sheetId": '"$raid_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 4, "endColumnIndex": 5}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "高"}, {"userEnteredValue": "中"}, {"userEnteredValue": "低"}]}, "showCustomUi": true, "strict": true}}},'

    # リスク管理 ステータス (G3:G1000)
    requests+='{"setDataValidation": {"range": {"sheetId": '"$raid_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 6, "endColumnIndex": 7}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "Open"}, {"userEnteredValue": "In Progress"}, {"userEnteredValue": "Closed"}]}, "showCustomUi": true, "strict": true}}},'

    # 課題管理 カテゴリ (C3:C1000)
    requests+='{"setDataValidation": {"range": {"sheetId": '"$issue_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 2, "endColumnIndex": 3}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "パフォーマンス"}, {"userEnteredValue": "UI/UX"}, {"userEnteredValue": "セキュリティ"}, {"userEnteredValue": "インフラ"}, {"userEnteredValue": "データ"}, {"userEnteredValue": "プロセス"}, {"userEnteredValue": "外部依存"}, {"userEnteredValue": "その他"}]}, "showCustomUi": true, "strict": true}}},'

    # 課題管理 ステータス (E3:E1000)
    requests+='{"setDataValidation": {"range": {"sheetId": '"$issue_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 4, "endColumnIndex": 5}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "未着手"}, {"userEnteredValue": "対応中"}, {"userEnteredValue": "レビュー中"}, {"userEnteredValue": "完了"}, {"userEnteredValue": "保留"}]}, "showCustomUi": true, "strict": true}}}'

    # Phase 2: RACI バリデーション
    if [[ "$PHASE" -ge 2 ]]; then
        local raci_id="${SHEET_ID_MAP["RACI"]}"
        # RACI値 (C3:G1000)
        requests+=',{"setDataValidation": {"range": {"sheetId": '"$raci_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 2, "endColumnIndex": 7}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "R"}, {"userEnteredValue": "A"}, {"userEnteredValue": "C"}, {"userEnteredValue": "I"}, {"userEnteredValue": ""}]}, "showCustomUi": true, "strict": true}}}'
    fi

    # Phase 3: 変更管理・ステークホルダー バリデーション
    if [[ "$PHASE" -ge 3 ]]; then
        local change_id="${SHEET_ID_MAP["変更管理"]}"
        local stakeholder_id="${SHEET_ID_MAP["ステークホルダー"]}"
        # 変更管理 ステータス (F3:F1000)
        requests+=',{"setDataValidation": {"range": {"sheetId": '"$change_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 5, "endColumnIndex": 6}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "申請中"}, {"userEnteredValue": "審査中"}, {"userEnteredValue": "承認"}, {"userEnteredValue": "却下"}, {"userEnteredValue": "保留"}]}, "showCustomUi": true, "strict": true}}},'
        # ステークホルダー 影響度 (D3:D1000)
        requests+='{"setDataValidation": {"range": {"sheetId": '"$stakeholder_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 3, "endColumnIndex": 4}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "高"}, {"userEnteredValue": "中"}, {"userEnteredValue": "低"}]}, "showCustomUi": true, "strict": true}}},'
        # ステークホルダー 関心度 (E3:E1000)
        requests+='{"setDataValidation": {"range": {"sheetId": '"$stakeholder_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 4, "endColumnIndex": 5}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "高"}, {"userEnteredValue": "中"}, {"userEnteredValue": "低"}]}, "showCustomUi": true, "strict": true}}},'
        # ステークホルダー 関与戦略 (F3:F1000)
        requests+='{"setDataValidation": {"range": {"sheetId": '"$stakeholder_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 5, "endColumnIndex": 6}, "rule": {"condition": {"type": "ONE_OF_LIST", "values": [{"userEnteredValue": "密接に管理"}, {"userEnteredValue": "満足を維持"}, {"userEnteredValue": "情報提供"}, {"userEnteredValue": "監視"}]}, "showCustomUi": true, "strict": true}}}'
    fi

    requests+=']}'

    gws sheets spreadsheets batchUpdate --params "{\"spreadsheetId\": \"$SPREADSHEET_ID\"}" --json "$requests" --format json >/dev/null 2>&1
    check_pass "ドロップダウンバリデーション設定完了"
}

# ========================================
# 条件付き書式の追加
# ========================================
add_conditional_formatting() {
    print_section "条件付き書式設定"

    local wbs_id="${SHEET_ID_MAP["WBS"]}"
    local raid_id="${SHEET_ID_MAP["リスク管理"]}"
    local issue_id="${SHEET_ID_MAP["課題管理"]}"
    local idx=0

    local requests='{"requests": ['

    # WBS: 完了行をグレーアウト
    requests+='{"addConditionalFormatRule": {"rule": {"ranges": [{"sheetId": '"$wbs_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 0, "endColumnIndex": 10}], "booleanRule": {"condition": {"type": "CUSTOM_FORMULA", "values": [{"userEnteredValue": "=$G3=\"完了\""}]}, "format": {"textFormat": {"strikethrough": true}, "backgroundColor": {"red": 0.95, "green": 0.95, "blue": 0.95}}}},"index": '"$((idx++))"'}},'

    # WBS: 遅延タスクを赤ハイライト
    requests+='{"addConditionalFormatRule": {"rule": {"ranges": [{"sheetId": '"$wbs_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 5, "endColumnIndex": 6}], "booleanRule": {"condition": {"type": "CUSTOM_FORMULA", "values": [{"userEnteredValue": "=AND($F3<TODAY(),$G3<>\"完了\")"}]}, "format": {"backgroundColor": {"red": 0.96, "green": 0.8, "blue": 0.8}}}},"index": '"$((idx++))"'}},'

    # リスク管理: 高リスクを赤ハイライト
    requests+='{"addConditionalFormatRule": {"rule": {"ranges": [{"sheetId": '"$raid_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 0, "endColumnIndex": 11}], "booleanRule": {"condition": {"type": "CUSTOM_FORMULA", "values": [{"userEnteredValue": "=AND($E3=\"高\",$G3<>\"Closed\")"}]}, "format": {"backgroundColor": {"red": 1.0, "green": 0.85, "blue": 0.85}}}},"index": '"$((idx++))"'}},'

    # 課題管理: 完了行をグレーアウト
    requests+='{"addConditionalFormatRule": {"rule": {"ranges": [{"sheetId": '"$issue_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 0, "endColumnIndex": 10}], "booleanRule": {"condition": {"type": "CUSTOM_FORMULA", "values": [{"userEnteredValue": "=$E3=\"完了\""}]}, "format": {"textFormat": {"strikethrough": true}, "backgroundColor": {"red": 0.95, "green": 0.95, "blue": 0.95}}}},"index": '"$((idx++))"'}},'


    # 課題管理: 期日超過を赤ハイライト
    requests+='{"addConditionalFormatRule": {"rule": {"ranges": [{"sheetId": '"$issue_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 9, "endColumnIndex": 10}], "booleanRule": {"condition": {"type": "CUSTOM_FORMULA", "values": [{"userEnteredValue": "=AND($J3<TODAY(),$I3<>\"完了\")"}]}, "format": {"backgroundColor": {"red": 0.96, "green": 0.8, "blue": 0.8}}}},"index": '"$((idx++))"'}}'

    # Phase 2: 予算管理 SPI/CPI < 1.0 の赤ハイライト
    if [[ "$PHASE" -ge 2 ]]; then
        local budget_id="${SHEET_ID_MAP["予算管理"]}"
        # SPI < 1.0 (F列)
        requests+=',{"addConditionalFormatRule": {"rule": {"ranges": [{"sheetId": '"$budget_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 5, "endColumnIndex": 6}], "booleanRule": {"condition": {"type": "CUSTOM_FORMULA", "values": [{"userEnteredValue": "=AND($F3<1,$F3>0)"}]}, "format": {"backgroundColor": {"red": 1.0, "green": 0.85, "blue": 0.85}}}},"index": '"$((idx++))"'}},'
        # CPI < 1.0 (G列)
        requests+='{"addConditionalFormatRule": {"rule": {"ranges": [{"sheetId": '"$budget_id"', "startRowIndex": 2, "endRowIndex": 1000, "startColumnIndex": 6, "endColumnIndex": 7}], "booleanRule": {"condition": {"type": "CUSTOM_FORMULA", "values": [{"userEnteredValue": "=AND($G3<1,$G3>0)"}]}, "format": {"backgroundColor": {"red": 1.0, "green": 0.85, "blue": 0.85}}}},"index": '"$((idx++))"'}}'
    fi

    requests+=']}'

    gws sheets spreadsheets batchUpdate --params "{\"spreadsheetId\": \"$SPREADSHEET_ID\"}" --json "$requests" --format json >/dev/null 2>&1
    check_pass "条件付き書式設定完了"
}

# ========================================
# 列幅の自動調整
# ========================================
adjust_column_widths() {
    print_section "列幅調整"

    local dash_id="${SHEET_ID_MAP["ダッシュボード"]}"
    local wbs_id="${SHEET_ID_MAP["WBS"]}"
    local raid_id="${SHEET_ID_MAP["リスク管理"]}"
    local issue_id="${SHEET_ID_MAP["課題管理"]}"

    local requests='{"requests": ['

    # ダッシュボード: A列を広く
    requests+="{\"updateDimensionProperties\": {\"range\": {\"sheetId\": $dash_id, \"dimension\": \"COLUMNS\", \"startIndex\": 0, \"endIndex\": 1}, \"properties\": {\"pixelSize\": 200}, \"fields\": \"pixelSize\"}},"

    # WBS: タスク名列を広く
    requests+="{\"updateDimensionProperties\": {\"range\": {\"sheetId\": $wbs_id, \"dimension\": \"COLUMNS\", \"startIndex\": 2, \"endIndex\": 3}, \"properties\": {\"pixelSize\": 300}, \"fields\": \"pixelSize\"}},"

    # リスク管理: タイトル・詳細・対応策を広く
    requests+="{\"updateDimensionProperties\": {\"range\": {\"sheetId\": $raid_id, \"dimension\": \"COLUMNS\", \"startIndex\": 2, \"endIndex\": 3}, \"properties\": {\"pixelSize\": 250}, \"fields\": \"pixelSize\"}},"
    requests+="{\"updateDimensionProperties\": {\"range\": {\"sheetId\": $raid_id, \"dimension\": \"COLUMNS\", \"startIndex\": 3, \"endIndex\": 4}, \"properties\": {\"pixelSize\": 300}, \"fields\": \"pixelSize\"}},"
    requests+="{\"updateDimensionProperties\": {\"range\": {\"sheetId\": $raid_id, \"dimension\": \"COLUMNS\", \"startIndex\": 8, \"endIndex\": 9}, \"properties\": {\"pixelSize\": 300}, \"fields\": \"pixelSize\"}},"

    # 課題管理: 課題内容・結論・Slack URLを広く
    requests+="{\"updateDimensionProperties\": {\"range\": {\"sheetId\": $issue_id, \"dimension\": \"COLUMNS\", \"startIndex\": 3, \"endIndex\": 4}, \"properties\": {\"pixelSize\": 400}, \"fields\": \"pixelSize\"}},"
    requests+="{\"updateDimensionProperties\": {\"range\": {\"sheetId\": $issue_id, \"dimension\": \"COLUMNS\", \"startIndex\": 8, \"endIndex\": 9}, \"properties\": {\"pixelSize\": 350}, \"fields\": \"pixelSize\"}},"
    requests+="{\"updateDimensionProperties\": {\"range\": {\"sheetId\": $issue_id, \"dimension\": \"COLUMNS\", \"startIndex\": 9, \"endIndex\": 10}, \"properties\": {\"pixelSize\": 300}, \"fields\": \"pixelSize\"}}"

    # Phase 2: プロジェクト憲章・ステークホルダー列幅
    if [[ "$PHASE" -ge 2 ]]; then
        local charter_id="${SHEET_ID_MAP["プロジェクト憲章"]}"
        # プロジェクト憲章: B列(内容)を500px
        requests+=",{\"updateDimensionProperties\": {\"range\": {\"sheetId\": $charter_id, \"dimension\": \"COLUMNS\", \"startIndex\": 1, \"endIndex\": 2}, \"properties\": {\"pixelSize\": 500}, \"fields\": \"pixelSize\"}}"
    fi

    # Phase 3: ステークホルダー・変更管理列幅
    if [[ "$PHASE" -ge 3 ]]; then
        local stakeholder_id="${SHEET_ID_MAP["ステークホルダー"]}"
        local change_id="${SHEET_ID_MAP["変更管理"]}"
        # ステークホルダー: 関与戦略列(F列)を200px
        requests+=",{\"updateDimensionProperties\": {\"range\": {\"sheetId\": $stakeholder_id, \"dimension\": \"COLUMNS\", \"startIndex\": 5, \"endIndex\": 6}, \"properties\": {\"pixelSize\": 200}, \"fields\": \"pixelSize\"}}"
        # 変更管理: 変更内容列(C列)を300px
        requests+=",{\"updateDimensionProperties\": {\"range\": {\"sheetId\": $change_id, \"dimension\": \"COLUMNS\", \"startIndex\": 2, \"endIndex\": 3}, \"properties\": {\"pixelSize\": 300}, \"fields\": \"pixelSize\"}}"
    fi

    requests+=']}'

    gws sheets spreadsheets batchUpdate --params "{\"spreadsheetId\": \"$SPREADSHEET_ID\"}" --json "$requests" --format json >/dev/null 2>&1
    check_pass "列幅調整完了"
}

# ========================================
# ヘッダー行の固定
# ========================================
freeze_header_rows() {
    print_section "ヘッダー行固定"

    local wbs_id="${SHEET_ID_MAP["WBS"]}"
    local raid_id="${SHEET_ID_MAP["リスク管理"]}"
    local issue_id="${SHEET_ID_MAP["課題管理"]}"

    local requests='{"requests": ['

    # WBS: 2行目まで固定
    requests+="{\"updateSheetProperties\": {\"properties\": {\"sheetId\": $wbs_id, \"gridProperties\": {\"frozenRowCount\": 2}}, \"fields\": \"gridProperties.frozenRowCount\"}},"

    # リスク管理: 2行目まで固定
    requests+="{\"updateSheetProperties\": {\"properties\": {\"sheetId\": $raid_id, \"gridProperties\": {\"frozenRowCount\": 2}}, \"fields\": \"gridProperties.frozenRowCount\"}},"

    # 課題管理: 2行目まで固定
    requests+="{\"updateSheetProperties\": {\"properties\": {\"sheetId\": $issue_id, \"gridProperties\": {\"frozenRowCount\": 2}}, \"fields\": \"gridProperties.frozenRowCount\"}}"

    # Phase 2: RACI・予算管理（プロジェクト憲章はキー値形式のため固定なし）
    if [[ "$PHASE" -ge 2 ]]; then
        local raci_id="${SHEET_ID_MAP["RACI"]}"
        local budget_id="${SHEET_ID_MAP["予算管理"]}"
        requests+=",{\"updateSheetProperties\": {\"properties\": {\"sheetId\": $raci_id, \"gridProperties\": {\"frozenRowCount\": 2}}, \"fields\": \"gridProperties.frozenRowCount\"}}"
        requests+=",{\"updateSheetProperties\": {\"properties\": {\"sheetId\": $budget_id, \"gridProperties\": {\"frozenRowCount\": 2}}, \"fields\": \"gridProperties.frozenRowCount\"}}"
    fi

    # Phase 3: ステークホルダー・コミュニケーション計画・変更管理
    if [[ "$PHASE" -ge 3 ]]; then
        local stakeholder_id="${SHEET_ID_MAP["ステークホルダー"]}"
        local comm_id="${SHEET_ID_MAP["コミュニケーション計画"]}"
        local change_id="${SHEET_ID_MAP["変更管理"]}"
        requests+=",{\"updateSheetProperties\": {\"properties\": {\"sheetId\": $stakeholder_id, \"gridProperties\": {\"frozenRowCount\": 2}}, \"fields\": \"gridProperties.frozenRowCount\"}}"
        requests+=",{\"updateSheetProperties\": {\"properties\": {\"sheetId\": $comm_id, \"gridProperties\": {\"frozenRowCount\": 2}}, \"fields\": \"gridProperties.frozenRowCount\"}}"
        requests+=",{\"updateSheetProperties\": {\"properties\": {\"sheetId\": $change_id, \"gridProperties\": {\"frozenRowCount\": 2}}, \"fields\": \"gridProperties.frozenRowCount\"}}"
    fi

    requests+=']}'

    gws sheets spreadsheets batchUpdate --params "{\"spreadsheetId\": \"$SPREADSHEET_ID\"}" --json "$requests" --format json >/dev/null 2>&1
    check_pass "ヘッダー行固定完了"
}

# ========================================
# 交互行の色分け（banding）＆フィルター
# ========================================
add_banding_and_filters() {
    print_section "交互行の色分け・フィルター設定"

    local wbs_id="${SHEET_ID_MAP["WBS"]}"
    local raid_id="${SHEET_ID_MAP["リスク管理"]}"
    local issue_id="${SHEET_ID_MAP["課題管理"]}"

    local requests='{"requests": ['

    # --- Banding（交互行の色分け） ---
    # WBS: 淡い青紫
    requests+="{\"addBanding\": {\"bandedRange\": {\"range\": {\"sheetId\": $wbs_id, \"startRowIndex\": 2, \"endRowIndex\": 1000, \"startColumnIndex\": 0, \"endColumnIndex\": 10}, \"rowProperties\": {\"firstBandColor\": {\"red\": 1, \"green\": 1, \"blue\": 1}, \"secondBandColor\": {\"red\": 0.94, \"green\": 0.94, \"blue\": 0.97}}}}},"

    # リスク管理: 淡い赤
    requests+="{\"addBanding\": {\"bandedRange\": {\"range\": {\"sheetId\": $raid_id, \"startRowIndex\": 2, \"endRowIndex\": 1000, \"startColumnIndex\": 0, \"endColumnIndex\": 11}, \"rowProperties\": {\"firstBandColor\": {\"red\": 1, \"green\": 1, \"blue\": 1}, \"secondBandColor\": {\"red\": 0.97, \"green\": 0.93, \"blue\": 0.93}}}}},"

    # 課題管理: 淡いオレンジ
    requests+="{\"addBanding\": {\"bandedRange\": {\"range\": {\"sheetId\": $issue_id, \"startRowIndex\": 2, \"endRowIndex\": 1000, \"startColumnIndex\": 0, \"endColumnIndex\": 10}, \"rowProperties\": {\"firstBandColor\": {\"red\": 1, \"green\": 1, \"blue\": 1}, \"secondBandColor\": {\"red\": 0.98, \"green\": 0.95, \"blue\": 0.9}}}}}"

    # Phase 2
    if [[ "$PHASE" -ge 2 ]]; then
        local raci_id="${SHEET_ID_MAP["RACI"]}"
        local budget_id="${SHEET_ID_MAP["予算管理"]}"
        # RACI: 淡い紫
        requests+=",{\"addBanding\": {\"bandedRange\": {\"range\": {\"sheetId\": $raci_id, \"startRowIndex\": 2, \"endRowIndex\": 1000, \"startColumnIndex\": 0, \"endColumnIndex\": 7}, \"rowProperties\": {\"firstBandColor\": {\"red\": 1, \"green\": 1, \"blue\": 1}, \"secondBandColor\": {\"red\": 0.95, \"green\": 0.93, \"blue\": 0.97}}}}}"
        # 予算管理: 淡いティール
        requests+=",{\"addBanding\": {\"bandedRange\": {\"range\": {\"sheetId\": $budget_id, \"startRowIndex\": 2, \"endRowIndex\": 1000, \"startColumnIndex\": 0, \"endColumnIndex\": 8}, \"rowProperties\": {\"firstBandColor\": {\"red\": 1, \"green\": 1, \"blue\": 1}, \"secondBandColor\": {\"red\": 0.92, \"green\": 0.97, \"blue\": 0.96}}}}}"
    fi

    # Phase 3
    if [[ "$PHASE" -ge 3 ]]; then
        local stakeholder_id="${SHEET_ID_MAP["ステークホルダー"]}"
        local comm_id="${SHEET_ID_MAP["コミュニケーション計画"]}"
        local change_id="${SHEET_ID_MAP["変更管理"]}"
        # ステークホルダー: 淡いオレンジ
        requests+=",{\"addBanding\": {\"bandedRange\": {\"range\": {\"sheetId\": $stakeholder_id, \"startRowIndex\": 2, \"endRowIndex\": 1000, \"startColumnIndex\": 0, \"endColumnIndex\": 8}, \"rowProperties\": {\"firstBandColor\": {\"red\": 1, \"green\": 1, \"blue\": 1}, \"secondBandColor\": {\"red\": 0.98, \"green\": 0.96, \"blue\": 0.92}}}}}"
        # コミュニケーション計画: 淡い緑
        requests+=",{\"addBanding\": {\"bandedRange\": {\"range\": {\"sheetId\": $comm_id, \"startRowIndex\": 2, \"endRowIndex\": 1000, \"startColumnIndex\": 0, \"endColumnIndex\": 7}, \"rowProperties\": {\"firstBandColor\": {\"red\": 1, \"green\": 1, \"blue\": 1}, \"secondBandColor\": {\"red\": 0.93, \"green\": 0.97, \"blue\": 0.93}}}}}"
        # 変更管理: 淡いブラウン
        requests+=",{\"addBanding\": {\"bandedRange\": {\"range\": {\"sheetId\": $change_id, \"startRowIndex\": 2, \"endRowIndex\": 1000, \"startColumnIndex\": 0, \"endColumnIndex\": 9}, \"rowProperties\": {\"firstBandColor\": {\"red\": 1, \"green\": 1, \"blue\": 1}, \"secondBandColor\": {\"red\": 0.96, \"green\": 0.95, \"blue\": 0.94}}}}}"
    fi

    # --- フィルター ---
    requests+=",{\"setBasicFilter\": {\"filter\": {\"range\": {\"sheetId\": $wbs_id, \"startRowIndex\": 1, \"startColumnIndex\": 0, \"endColumnIndex\": 10}}}}"
    requests+=",{\"setBasicFilter\": {\"filter\": {\"range\": {\"sheetId\": $raid_id, \"startRowIndex\": 1, \"startColumnIndex\": 0, \"endColumnIndex\": 11}}}}"
    requests+=",{\"setBasicFilter\": {\"filter\": {\"range\": {\"sheetId\": $issue_id, \"startRowIndex\": 1, \"startColumnIndex\": 0, \"endColumnIndex\": 10}}}}"

    if [[ "$PHASE" -ge 2 ]]; then
        requests+=",{\"setBasicFilter\": {\"filter\": {\"range\": {\"sheetId\": $raci_id, \"startRowIndex\": 1, \"startColumnIndex\": 0, \"endColumnIndex\": 7}}}}"
        requests+=",{\"setBasicFilter\": {\"filter\": {\"range\": {\"sheetId\": $budget_id, \"startRowIndex\": 1, \"startColumnIndex\": 0, \"endColumnIndex\": 8}}}}"
    fi

    if [[ "$PHASE" -ge 3 ]]; then
        requests+=",{\"setBasicFilter\": {\"filter\": {\"range\": {\"sheetId\": $stakeholder_id, \"startRowIndex\": 1, \"startColumnIndex\": 0, \"endColumnIndex\": 8}}}}"
        requests+=",{\"setBasicFilter\": {\"filter\": {\"range\": {\"sheetId\": $comm_id, \"startRowIndex\": 1, \"startColumnIndex\": 0, \"endColumnIndex\": 7}}}}"
        requests+=",{\"setBasicFilter\": {\"filter\": {\"range\": {\"sheetId\": $change_id, \"startRowIndex\": 1, \"startColumnIndex\": 0, \"endColumnIndex\": 9}}}}"
    fi

    requests+=']}'

    gws sheets spreadsheets batchUpdate --params "{\"spreadsheetId\": \"$SPREADSHEET_ID\"}" --json "$requests" --format json >/dev/null 2>&1
    check_pass "交互行の色分け・フィルター設定完了"
}

# ========================================
# メイン処理
# ========================================
main() {
    print_banner "PMBOK プロジェクト管理テンプレート生成"
    echo -e "  フェーズ: ${BOLD}Phase $PHASE${NC}"
    echo -e "  プロジェクト: ${BOLD}$PROJECT_TITLE${NC}"
    echo ""

    check_prerequisites
    build_sheet_id_map

    if [[ -z "$SPREADSHEET_ID" ]]; then
        create_spreadsheet "$PROJECT_TITLE"
    else
        print_section "既存スプレッドシートを使用: $SPREADSHEET_ID"
    fi

    add_data_validations
    add_conditional_formatting
    adjust_column_widths
    freeze_header_rows
    add_banding_and_filters

    echo ""
    print_header "完了"
    echo -e "  ${GREEN}スプレッドシートID: $SPREADSHEET_ID${NC}"
    echo -e "  ${CYAN}URL: https://docs.google.com/spreadsheets/d/$SPREADSHEET_ID${NC}"
    echo ""
    echo "  シート構成 (Phase $PHASE):"
    echo "    - ダッシュボード (KPI・進捗一覧)"
    echo "    - WBS (作業分解・スケジュール・ガントチャート)"
    echo "    - 課題管理 (課題・結論・Slack連携)"
    echo "    - リスク管理 (リスク・アクション・決定事項)"
    if [[ "$PHASE" -ge 2 ]]; then
        echo "    - プロジェクト憲章"
        echo "    - RACI (責任分担マトリクス)"
        echo "    - 予算管理 (EVM)"
    fi
    if [[ "$PHASE" -ge 3 ]]; then
        echo "    - ステークホルダー (登録簿)"
        echo "    - コミュニケーション計画"
        echo "    - 変更管理 (変更管理ログ)"
    fi
    echo "    - マスタ (マスタデータ)"
}

main
