#!/bin/bash
# ========================================
# setup_ssh.sh - SSH鍵生成・管理ヘルパー
# ========================================
# 使用方法: bash scripts/utils/setup_ssh.sh [オプション]
# オプション:
#   -e, --email EMAIL    SSH鍵に使用するメールアドレス
#   -t, --type TYPE      鍵の種類 (ed25519, rsa) デフォルト: ed25519
#   -n, --name NAME      鍵ファイル名 デフォルト: id_ed25519
#   -g, --github         GitHub用の鍵を生成
#   -l, --list           既存の鍵を一覧表示
#   -h, --help           ヘルプを表示

set -euo pipefail

# 共通ライブラリ読み込み（必須）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"

# デフォルト設定
KEY_TYPE="ed25519"
KEY_NAME=""
EMAIL=""
GITHUB_MODE=false

# ========================================
# ヘルプ
# ========================================
show_help() {
    cat << EOF
使用方法: bash setup-ssh.sh [オプション]

SSH鍵の生成・管理ヘルパースクリプト

オプション:
  -e, --email EMAIL    SSH鍵に使用するメールアドレス
  -t, --type TYPE      鍵の種類 (ed25519, rsa) デフォルト: ed25519
  -n, --name NAME      鍵ファイル名 デフォルト: id_ed25519 または id_rsa
  -g, --github         GitHub用の鍵を生成（自動でclipboardにコピー）
  -l, --list           既存の鍵を一覧表示
  -h, --help           このヘルプを表示

例:
  bash setup-ssh.sh --github --email "your@email.com"
  bash setup-ssh.sh --type rsa --name id_work_rsa --email "work@company.com"
  bash setup-ssh.sh --list
EOF
    exit 0
}

# ========================================
# 引数解析
# ========================================
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -e|--email)
            EMAIL="$2"
            shift
            ;;
        -t|--type)
            KEY_TYPE="$2"
            shift
            ;;
        -n|--name)
            KEY_NAME="$2"
            shift
            ;;
        -g|--github)
            GITHUB_MODE=true
            ;;
        -l|--list)
            list_keys
            exit 0
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo -e "${RED}不明なオプション: $1${NC}"
            show_help
            ;;
    esac
    shift
done

# ========================================
# 関数定義
# ========================================

# 既存の鍵を一覧表示
list_keys() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  SSH鍵一覧${NC}"
    echo -e "${BLUE}========================================${NC}"

    if [[ ! -d "$HOME/.ssh" ]]; then
        echo -e "${YELLOW}~/.ssh ディレクトリが存在しません${NC}"
        return
    fi

    local found=false
    for key in "$HOME"/.ssh/id_*; do
        if [[ -f "$key" && ! "$key" =~ \.pub$ ]]; then
            found=true
            local pub_key="${key}.pub"
            local key_name
            key_name=$(basename "$key")

            echo -e "\n${GREEN}● ${key_name}${NC}"
            echo -e "  パス: $key"

            if [[ -f "$pub_key" ]]; then
                # 鍵の種類を取得
                local key_type
                key_type=$(head -1 "$pub_key" | awk '{print $1}')
                echo -e "  種類: $key_type"

                # フィンガープリント
                local fingerprint
                fingerprint=$(ssh-keygen -lf "$pub_key" 2>/dev/null | awk '{print $2}')
                echo -e "  フィンガープリント: $fingerprint"

                # コメント（メールアドレス等）
                local comment
                comment=$(head -1 "$pub_key" | awk '{print $NF}')
                echo -e "  コメント: $comment"
            fi
        fi
    done

    if [[ "$found" = false ]]; then
        echo -e "${YELLOW}SSH鍵が見つかりません${NC}"
    fi
}

# SSH鍵を生成
generate_key() {
    local email="$1"
    local key_type="$2"
    local key_name="$3"

    # 鍵ファイル名のデフォルト設定
    if [[ -z "$key_name" ]]; then
        key_name="id_${key_type}"
    fi

    local key_path="$HOME/.ssh/${key_name}"

    # ディレクトリ作成
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    # 既存の鍵チェック
    if [[ -f "$key_path" ]]; then
        echo -e "${YELLOW}警告: ${key_path} は既に存在します${NC}"
        echo -en "${YELLOW}上書きしますか？ [y/N]: ${NC}"
        read -r answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            echo -e "${CYAN}キャンセルしました${NC}"
            return 1
        fi
    fi

    echo -e "${BLUE}SSH鍵を生成中...${NC}"
    echo -e "  種類: $key_type"
    echo -e "  パス: $key_path"
    echo -e "  メール: $email"

    # パスフレーズ入力（セキュリティ強化）
    echo -e "\n${YELLOW}パスフレーズを設定してください（空でスキップ可）:${NC}"
    echo -e "${DIM}※ パスフレーズを設定すると、鍵が盗まれても悪用を防げます${NC}"
    local passphrase=""
    local passphrase_confirm=""
    read -rsp "パスフレーズ: " passphrase
    echo ""
    if [[ -n "$passphrase" ]]; then
        read -rsp "パスフレーズ（確認）: " passphrase_confirm
        echo ""
        if [[ "$passphrase" != "$passphrase_confirm" ]]; then
            echo -e "${RED}パスフレーズが一致しません${NC}"
            return 1
        fi
    fi

    # 鍵生成
    case "$key_type" in
        ed25519)
            ssh-keygen -t ed25519 -C "$email" -f "$key_path" -N "$passphrase"
            ;;
        rsa)
            ssh-keygen -t rsa -b 4096 -C "$email" -f "$key_path" -N "$passphrase"
            ;;
        *)
            echo -e "${RED}不明な鍵の種類: $key_type${NC}"
            return 1
            ;;
    esac

    # パーミッション設定
    chmod 600 "$key_path"
    chmod 644 "${key_path}.pub"

    echo -e "${GREEN}✓ SSH鍵を生成しました${NC}"
    echo -e "  秘密鍵: $key_path"
    echo -e "  公開鍵: ${key_path}.pub"

    return 0
}

# ssh-agentに鍵を追加
add_to_agent() {
    local key_path="$1"

    echo -e "${BLUE}ssh-agentに鍵を追加中...${NC}"

    # ssh-agentが起動していない場合は起動
    if [[ -z "${SSH_AUTH_SOCK:-}" ]]; then
        eval "$(ssh-agent -s)"
    fi

    # macOSの場合はキーチェーンに保存
    if [[ "$(uname -s)" == "Darwin" ]]; then
        ssh-add --apple-use-keychain "$key_path" 2>/dev/null || ssh-add "$key_path"
    else
        ssh-add "$key_path"
    fi

    echo -e "${GREEN}✓ ssh-agentに追加しました${NC}"
}

# 公開鍵をクリップボードにコピー
copy_to_clipboard() {
    local pub_key_path="$1"

    if [[ ! -f "$pub_key_path" ]]; then
        echo -e "${RED}公開鍵が見つかりません: $pub_key_path${NC}"
        return 1
    fi

    if [[ "$(uname -s)" == "Darwin" ]]; then
        pbcopy < "$pub_key_path"
        echo -e "${GREEN}✓ 公開鍵をクリップボードにコピーしました（macOS）${NC}"
    elif command -v xclip &>/dev/null; then
        xclip -selection clipboard < "$pub_key_path"
        echo -e "${GREEN}✓ 公開鍵をクリップボードにコピーしました（xclip）${NC}"
    elif command -v xsel &>/dev/null; then
        xsel --clipboard --input < "$pub_key_path"
        echo -e "${GREEN}✓ 公開鍵をクリップボードにコピーしました（xsel）${NC}"
    elif [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
        cat "$pub_key_path" | clip.exe
        echo -e "${GREEN}✓ 公開鍵をクリップボードにコピーしました（WSL）${NC}"
    else
        echo -e "${YELLOW}クリップボードツールが見つかりません${NC}"
        echo -e "${CYAN}公開鍵の内容:${NC}"
        cat "$pub_key_path"
        return 1
    fi

    return 0
}

# GitHub用の設定案内
show_github_instructions() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}  GitHub SSH設定手順${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "1. GitHubにログイン"
    echo -e "2. Settings → SSH and GPG keys → New SSH key"
    echo -e "3. クリップボードの内容を貼り付け"
    echo -e "4. 'Add SSH key' をクリック"
    echo -e ""
    echo -e "${CYAN}接続テスト:${NC}"
    echo -e "  ssh -T git@github.com"
    echo -e ""
    echo -e "${CYAN}~/.ssh/config に追加推奨:${NC}"
    cat << 'SSHCONFIG'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
    AddKeysToAgent yes
SSHCONFIG
}

# ========================================
# メイン処理
# ========================================
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  SSH鍵セットアップ${NC}"
    echo -e "${BLUE}========================================${NC}"

    # メールアドレス入力
    if [[ -z "$EMAIL" ]]; then
        echo -en "${YELLOW}メールアドレスを入力してください: ${NC}"
        read -r EMAIL
        if [[ -z "$EMAIL" ]]; then
            echo -e "${RED}メールアドレスは必須です${NC}"
            exit 1
        fi
    fi

    # GitHub用の場合
    if [[ "$GITHUB_MODE" = true ]]; then
        KEY_NAME="${KEY_NAME:-id_ed25519_github}"
        echo -e "${CYAN}GitHub用SSH鍵を生成します${NC}"
    fi

    # 鍵生成
    if ! generate_key "$EMAIL" "$KEY_TYPE" "$KEY_NAME"; then
        exit 1
    fi

    local key_path="$HOME/.ssh/${KEY_NAME:-id_${KEY_TYPE}}"

    # ssh-agentに追加
    add_to_agent "$key_path"

    # クリップボードにコピー
    copy_to_clipboard "${key_path}.pub"

    # GitHub用の案内
    if [[ "$GITHUB_MODE" = true ]]; then
        show_github_instructions
    fi

    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}  セットアップ完了！${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# -l オプションの場合は一覧表示のみ
if [[ "${1:-}" == "-l" || "${1:-}" == "--list" ]]; then
    list_keys
    exit 0
fi

# メイン実行（引数がある場合のみ）
if [[ "$#" -gt 0 ]] || [[ "$GITHUB_MODE" = true ]] || [[ -n "$EMAIL" ]]; then
    main
else
    # 引数なしの場合は対話モード
    echo -e "${CYAN}SSH鍵セットアップヘルパー${NC}"
    echo -e "使用方法: bash setup-ssh.sh --help"
    echo -e ""
    echo -e "クイックスタート:"
    echo -e "  GitHub用:  bash setup-ssh.sh --github --email your@email.com"
    echo -e "  鍵一覧:    bash setup-ssh.sh --list"
fi
