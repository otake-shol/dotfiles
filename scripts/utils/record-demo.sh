#!/bin/bash
# ========================================
# record-demo.sh - デモGIF録画スクリプト
# ========================================
# 使用方法: bash scripts/utils/record-demo.sh
#
# 必要なツール:
#   - asciinema: brew install asciinema
#   - agg (asciinema gif generator): cargo install agg
#   または
#   - terminalizer: npm install -g terminalizer

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/../../docs/assets"
AUTO_MODE="${AUTO_MODE:-false}"

# 色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ツール確認
check_tools() {
    echo -e "${CYAN}ツール確認中...${NC}"

    if command -v asciinema &>/dev/null; then
        echo -e "${GREEN}✓ asciinema${NC}"
        RECORDER="asciinema"
    elif command -v terminalizer &>/dev/null; then
        echo -e "${GREEN}✓ terminalizer${NC}"
        RECORDER="terminalizer"
    else
        echo -e "${YELLOW}⚠ 録画ツールがインストールされていません${NC}"
        echo ""
        echo "以下のいずれかをインストールしてください:"
        echo "  brew install asciinema"
        echo "  npm install -g terminalizer"
        exit 1
    fi
}

# デモスクリプト
demo_script() {
    echo -e "${CYAN}デモスクリプトを実行します${NC}"
    echo ""

    # 1. シェル起動
    echo -e "${GREEN}# Modern dotfiles with AI-driven development${NC}"
    sleep 1

    # 2. エイリアス表示
    echo -e "${YELLOW}# Show some aliases${NC}"
    echo "dothelp git"
    sleep 2

    # 3. fzf機能デモ
    echo -e "${YELLOW}# fzf integration${NC}"
    echo "# fvim - select file with fzf"
    sleep 1

    # 4. モダンCLIツール
    echo -e "${YELLOW}# Modern CLI tools${NC}"
    echo "ll"
    sleep 1
    echo "bat ~/.zshrc"
    sleep 1

    # 5. Git統合
    echo -e "${YELLOW}# Git integration${NC}"
    echo "gs"  # git status
    sleep 1

    # 6. Claude Code
    echo -e "${YELLOW}# Claude Code with MCP servers${NC}"
    echo "claude --help"
    sleep 2

    echo -e "${GREEN}# Setup: cd ~/dotfiles && bash bootstrap.sh${NC}"
}

# asciinemaで録画
record_asciinema() {
    local output="${OUTPUT_DIR}/demo.cast"
    local scenario="${SCRIPT_DIR}/demo-scenario.sh"
    local theme_file="${OUTPUT_DIR}/agg-theme-tokyonight.txt"

    echo -e "${CYAN}asciinemaで録画を開始します${NC}"

    if [[ "$AUTO_MODE" == "true" ]] && [[ -f "$scenario" ]]; then
        echo "自動シナリオモード: demo-scenario.sh を実行"
        echo ""
        asciinema rec "$output" \
            --title "dotfiles demo" \
            --cols 120 \
            --rows 30 \
            --command "bash $scenario"
    else
        echo "対話モード: 録画終了は exit または Ctrl+D"
        echo ""
        asciinema rec "$output" \
            --title "dotfiles demo" \
            --cols 120 \
            --rows 30
    fi

    echo -e "${GREEN}✓ 録画完了: $output${NC}"

    # GIF変換
    if command -v agg &>/dev/null; then
        echo -e "${CYAN}GIFに変換中...${NC}"
        local agg_opts=(
            --font-family "JetBrains Mono, Menlo, monospace"
            --font-size 14
        )

        # テーマファイルがあれば使用
        if [[ -f "$theme_file" ]]; then
            agg_opts+=(--theme-file "$theme_file")
        else
            agg_opts+=(--theme tokyonight)
        fi

        agg "$output" "${OUTPUT_DIR}/demo.gif" "${agg_opts[@]}"
        echo -e "${GREEN}✓ GIF作成: ${OUTPUT_DIR}/demo.gif${NC}"
    else
        echo -e "${YELLOW}⚠ agg がないためGIF変換をスキップ${NC}"
        echo "  インストール: cargo install agg"
        echo "  または https://asciinema.org にアップロードして変換"
    fi
}

# terminalizerで録画
record_terminalizer() {
    local config="${OUTPUT_DIR}/terminalizer.yml"
    local output="${OUTPUT_DIR}/demo"

    # 設定ファイル作成
    cat > "$config" << 'EOF'
command: zsh
cwd: ~/dotfiles
env:
  recording: true
cols: 120
rows: 30
repeat: 0
quality: 100
frameDelay: auto
maxIdleTime: 2000
frameBox:
  type: solid
  title: dotfiles
  style:
    boxShadow: none
    margin: 0px
watermark:
  imagePath: null
  style:
    position: absolute
    right: 15px
    bottom: 15px
    width: 100px
    opacity: 0.9
cursorStyle: block
fontFamily: "JetBrains Mono, Monaco, monospace"
fontSize: 14
lineHeight: 1.2
letterSpacing: 0
theme:
  background: "#1a1b26"
  foreground: "#c0caf5"
  cursor: "#c0caf5"
  black: "#15161e"
  red: "#f7768e"
  green: "#9ece6a"
  yellow: "#e0af68"
  blue: "#7aa2f7"
  magenta: "#bb9af7"
  cyan: "#7dcfff"
  white: "#a9b1d6"
  brightBlack: "#414868"
  brightRed: "#f7768e"
  brightGreen: "#9ece6a"
  brightYellow: "#e0af68"
  brightBlue: "#7aa2f7"
  brightMagenta: "#bb9af7"
  brightCyan: "#7dcfff"
  brightWhite: "#c0caf5"
EOF

    echo -e "${CYAN}terminalizerで録画を開始します${NC}"
    echo "録画終了: exit"
    echo ""

    terminalizer record "$output" -c "$config"

    echo -e "${GREEN}✓ 録画完了${NC}"

    # GIF生成
    echo -e "${CYAN}GIFを生成中...${NC}"
    terminalizer render "$output" -o "${output}.gif"
    echo -e "${GREEN}✓ GIF作成: ${output}.gif${NC}"

    # 設定ファイル削除
    rm -f "$config"
}

# ヘルプ表示
show_help() {
    cat << 'EOF'
Usage: record-demo.sh [OPTIONS]

Options:
  --auto          自動シナリオモード（demo-scenario.shを実行）
  --interactive   対話モード（デフォルト）
  -h, --help      このヘルプを表示

Examples:
  # 自動シナリオでデモを録画
  bash record-demo.sh --auto

  # 対話モードで録画
  bash record-demo.sh --interactive

  # 録画後のGIF生成（agg必要）
  agg docs/assets/demo.cast docs/assets/demo.gif --theme tokyonight

Requirements:
  - asciinema: brew install asciinema
  - agg (GIF生成): cargo install agg
  または
  - terminalizer: npm install -g terminalizer
EOF
}

# メイン
main() {
    # 引数処理
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --auto)
                AUTO_MODE=true
                shift
                ;;
            --interactive)
                AUTO_MODE=false
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  dotfiles デモ録画スクリプト${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    echo -e "モード: ${YELLOW}${AUTO_MODE:-false}${NC} (auto)"
    echo ""

    check_tools

    case "$RECORDER" in
        asciinema)
            record_asciinema
            ;;
        terminalizer)
            record_terminalizer
            ;;
    esac

    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  完了${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "生成されたファイル:"
    ls -la "${OUTPUT_DIR}"/demo.* 2>/dev/null || echo "  (ファイルなし)"
    echo ""
    echo "README.mdに追加:"
    echo '  <img src="docs/assets/demo.gif" alt="Demo" width="800">'
}

main "$@"
