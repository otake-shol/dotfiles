# ========================================
# 変数定義
# ========================================
DOTFILES_SCRIPTS="${DOTFILES_DIR:-$HOME/dotfiles}/scripts"

# ========================================
# 基本操作
# ========================================

# ディレクトリ移動
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias -- -="cd -"
alias CD="cd"

# ls関連 (eza)
alias ls="eza"                    # モダンなls
alias ll="eza -l --git"           # 詳細表示+Git状態
alias la="eza -la --git"          # 隠しファイル含む
alias l="eza -1"                  # 1行1ファイル
alias lsd="eza -lD"               # ディレクトリのみ
alias lt="eza -T --git-ignore"    # ツリー表示
alias lta="eza -Ta"               # ツリー（全ファイル）

# 検索・grep
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias h="history | grep"

# ripgrep (高速grep)
alias rg="rg --smart-case"        # 大文字小文字自動判定
alias rgi="rg -i"                 # 常に大文字小文字無視
alias rgf="rg --files"            # ファイル名のみ表示

# fd (高速find)
alias fd="fd --hidden --exclude .git"  # 隠しファイル含む
alias fdi="fd -I"                      # gitignore無視して検索

# 安全な削除・コピー
alias cp="cp -i"
alias mv="mv -i"
# rm関数は functions/util-functions.zsh に定義

# ========================================
# Claude
# ========================================
alias c="claude"

# ========================================
# システム・ネットワーク
# ========================================

# システム
alias reload="source ~/.zshrc"
alias zshconfig="vim ~/.zshrc"
alias aliasconfig="vim ~/.aliases"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias zshtime="time zsh -i -c exit"  # zsh起動時間計測
alias zshbench="bash $DOTFILES_SCRIPTS/utils/zsh_benchmark.sh"  # 詳細ベンチマーク
alias path='echo -e ${PATH//:/\\n}'
alias his="history"
alias df="df -h"
alias top="btop"                     # モダンなシステムモニター

# ネットワーク
alias myip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en0"
alias ips="echo 'Local:' && ipconfig getifaddr en0 && echo 'Global:' && curl -s ifconfig.me"
alias ports="lsof -i -P | grep LISTEN"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# ========================================
# zoxide（高速ディレクトリジャンプ）
# ========================================
alias j="z"                           # ディレクトリジャンプ
alias ji="zi"                         # インタラクティブ選択

# ========================================
# dotfiles管理
# ========================================
alias dotup="bash $DOTFILES_SCRIPTS/maintenance/check_updates.sh"       # 更新チェック
alias dotupdate="bash $DOTFILES_SCRIPTS/maintenance/update_all.sh"      # 一括更新
alias brewsync="bash $DOTFILES_SCRIPTS/maintenance/sync_brewfile.sh"    # Brewfile同期チェック
alias dotsysinfo="bash $DOTFILES_SCRIPTS/lib/os_detect.sh"              # システム情報表示
alias dothelp="bash $DOTFILES_SCRIPTS/utils/dothelp.sh"                 # エイリアスヘルプ
alias dotverify="bash $DOTFILES_SCRIPTS/maintenance/verify_setup.sh"   # セットアップ検証
alias dotssh="bash $DOTFILES_SCRIPTS/utils/setup_ssh.sh"                # SSH鍵管理
alias dotsshlist="bash $DOTFILES_SCRIPTS/utils/setup_ssh.sh --list"     # SSH鍵一覧

# ========================================
# クイックアクセス
# ========================================
alias dots="cd ~/dotfiles"
alias projects="cd ~/Projects"
alias downloads="cd ~/Downloads"
alias desktop="cd ~/Desktop"

# ========================================
# ファイル表示 (bat)
# ========================================
alias cat="bat"                      # catをbatに置き換え
alias catp="bat -p"                  # プレーン表示（装飾なし）
alias catl="bat -l"                  # 言語指定 (例: catl json file.txt)
alias less="bat --paging=always"     # ページャーとして使用
alias bathelp="bat --help"           # batのヘルプ

# ファイルプレビュー (fzf + bat)
alias fp="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# ========================================
# 開発ツール
# ========================================

# コード統計
alias loc="tokei"                      # Lines of Code

# ========================================
# エイリアス管理
# ========================================
alias aliases="cat ~/.aliases"         # 全表示
alias aliasgrep="alias | grep"         # 検索
alias ag="alias | grep"                # 短縮版
alias af="alias | fzf"                 # fzfで対話的検索
