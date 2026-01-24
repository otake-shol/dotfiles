#!/bin/bash
# ========================================
# dothelp - dotfiles自己文書化ヘルプ
# ========================================
# 使用方法: dothelp [カテゴリ]
# カテゴリ: all, core, git, node, dev, fzf, tools

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"

# 共通ライブラリ読み込み
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# dothelp固有のdothelp_header（装飾付き）
dothelp_header() {
    echo -e "\n${BOLD}${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}$1${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════╝${NC}\n"
}

print_alias() {
    printf "  ${GREEN}%-20s${NC} %s\n" "$1" "$2"
}

print_function() {
    printf "  ${MAGENTA}%-20s${NC} %s\n" "$1" "$2"
}

show_core_aliases() {
    print_section "ディレクトリ移動"
    print_alias ".." "cd .."
    print_alias "..." "cd ../.."
    print_alias "~" "cd ~"
    print_alias "j <dir>" "zoxide: ディレクトリジャンプ"
    print_alias "ji" "zoxide: インタラクティブ選択"

    print_section "ファイル操作 (eza)"
    print_alias "ls" "eza (モダンls)"
    print_alias "ll" "詳細表示+Git状態"
    print_alias "la" "隠しファイル含む"
    print_alias "lt" "ツリー表示"

    print_section "検索"
    print_alias "rg" "ripgrep (高速grep)"
    print_alias "fd" "fd (高速find)"
    print_alias "h <pattern>" "履歴検索"

    print_section "安全な削除"
    print_alias "rm -rf" "確認プロンプト付き（関数でラップ）"

    print_section "システム"
    print_alias "reload" "zshrc再読み込み"
    print_alias "myip" "グローバルIP表示"
    print_alias "localip" "ローカルIP表示"
    print_alias "ports" "LISTEN中のポート一覧"
}

show_git_aliases() {
    print_section "Git基本"
    print_alias "gs" "git status"
    print_alias "ga" "git add"
    print_alias "gc" "git commit"
    print_alias "gcm" "git commit -m"
    print_alias "gp" "git push"
    print_alias "gpl" "git pull"
    print_alias "gco" "git checkout"
    print_alias "gcb" "git checkout -b"
    print_alias "gb" "git branch"
    print_alias "gd" "git diff"
    print_alias "gl" "git log"
    print_alias "glg" "グラフ付きログ"
    print_alias "gundo" "直前コミット取消"

    print_section "GitHub CLI"
    print_alias "ghpl" "PR一覧"
    print_alias "ghpr" "PR作成"
    print_alias "ghpv" "PR表示（ブラウザ）"
    print_alias "ghil" "Issue一覧"
    print_alias "ghic" "Issue作成"
}

show_node_aliases() {
    print_section "npm"
    print_alias "ni" "npm install"
    print_alias "nid" "npm install -D"
    print_alias "nr" "npm run"
    print_alias "nt" "npm test"

    print_section "yarn"
    print_alias "yi" "yarn install"
    print_alias "ya" "yarn add"
    print_alias "yad" "yarn add -D"

    print_section "pnpm"
    print_alias "pn" "pnpm"
    print_alias "pni" "pnpm install"
    print_alias "pnr" "pnpm run"

    print_section "bun"
    print_alias "b" "bun"
    print_alias "bi" "bun install"
    print_alias "br" "bun run"
}

show_dev_aliases() {
    print_section "エディタ"
    print_alias "vi / vim" "nvim"
    print_alias "c" "claude"

    print_section "Python"
    print_alias "py" "python3"
    print_alias "pip" "pip3"
    print_alias "venv" "python3 -m venv"
    print_alias "activate" "source .venv/bin/activate"

    print_section "ユーティリティ"
    print_alias "loc" "tokei (コード統計)"
}

show_fzf_functions() {
    print_section "fzf統合関数"
    print_function "fvim" "ファイル選択→nvimで開く"
    print_function "fbr" "ブランチ選択→checkout"
    print_function "fshow" "コミット履歴閲覧"
    print_function "fcd" "ディレクトリ選択→移動"
    print_function "fkill" "プロセス選択→kill"
    print_function "fstash" "stash選択→適用"
    print_function "fenv" "環境変数検索"
    print_function "fhistory" "履歴検索→実行"
    print_function "fman" "manページ検索"
}

show_tools() {
    print_section "モダンCLIツール"
    print_alias "cat → bat" "シンタックスハイライト付きcat"
    print_alias "ls → eza" "アイコン・Git対応ls"
    print_alias "grep → rg" "ripgrep (高速検索)"
    print_alias "find → fd" "fd (高速ファイル検索)"
    print_alias "top → btop" "モダンなリソースモニター"
    print_alias "diff → delta" "美しいdiff (git diff)"
    print_alias "cd → zoxide" "スマートディレクトリジャンプ"
    print_alias "y" "yazi (ターミナルファイルマネージャー)"

    print_section "dotfiles管理"
    print_alias "dotup" "更新チェック"
    print_alias "dotupdate" "一括更新"
    print_alias "dotverify" "セットアップ検証"
    print_alias "brewsync" "Brewfile同期チェック"
    print_alias "dots" "cd ~/dotfiles"
}

show_all() {
    show_core_aliases
    echo ""
    show_git_aliases
    echo ""
    show_node_aliases
    echo ""
    show_dev_aliases
    echo ""
    show_fzf_functions
    echo ""
    show_tools
}

show_usage() {
    dothelp_header "dothelp - dotfiles ヘルプ"
    echo -e "${BOLD}使用方法:${NC}"
    echo "  dothelp [カテゴリ]"
    echo ""
    echo -e "${BOLD}カテゴリ:${NC}"
    print_alias "all" "全てのエイリアス・関数"
    print_alias "core" "基本操作（ls, cd, 検索など）"
    print_alias "git" "Git & GitHub CLI"
    print_alias "node" "npm / yarn / pnpm / bun"
    print_alias "dev" "エディタ・開発ツール"
    print_alias "fzf" "fzf統合関数"
    print_alias "tools" "モダンCLIツール一覧"
    echo ""
    echo -e "${BOLD}例:${NC}"
    echo "  dothelp git     # Git関連のエイリアスを表示"
    echo "  dothelp all     # 全て表示"
    echo "  dothelp         # このヘルプを表示"
}

# メイン処理
case "${1:-}" in
    all)
        dothelp_header "dotfiles 全エイリアス・関数"
        show_all
        ;;
    core|basic)
        dothelp_header "基本操作"
        show_core_aliases
        ;;
    git)
        dothelp_header "Git & GitHub CLI"
        show_git_aliases
        ;;
    node|npm|yarn|pnpm|bun)
        dothelp_header "Node.js パッケージマネージャー"
        show_node_aliases
        ;;
    dev)
        dothelp_header "開発ツール"
        show_dev_aliases
        ;;
    fzf)
        dothelp_header "fzf統合関数"
        show_fzf_functions
        ;;
    tools)
        dothelp_header "モダンCLIツール"
        show_tools
        ;;
    -h|--help|"")
        show_usage
        ;;
    *)
        echo -e "${YELLOW}不明なカテゴリ: $1${NC}"
        show_usage
        exit 1
        ;;
esac
