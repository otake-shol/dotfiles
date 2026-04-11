# ========================================
# 基本操作
# ========================================

# ディレクトリ移動
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

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

# ripgrep (高速grep) — .ripgreprc廃止、aliasで管理
alias rg="rg --smart-case --glob='!*.min.js' --glob='!*.min.css' --glob='!*.lock' --glob='!package-lock.json' --glob='!yarn.lock' --glob='!pnpm-lock.yaml'"
alias rgi="rg -i"                 # 常に大文字小文字無視
alias rgf="rg --files"            # ファイル名のみ表示

# fd (高速find)
alias fd="fd --hidden --exclude .git"  # 隠しファイル含む
alias fdi="fd -I"                      # gitignore無視して検索

# 安全な削除・コピー
alias cp="cp -i"
alias mv="mv -i"
# sizeof, port関数は aliases/core.zsh 下部に定義

# ========================================
# Claude Code
# ========================================
alias c="claude"                          # 基本起動
alias co="claude --model opus"            # Opusモデル
alias cs="claude --model sonnet"          # Sonnetモデル
alias ch="claude --model haiku"           # Haikuモデル
alias clp="claude --print"                # 非対話モード（パイプ用）
alias claude-mem='node "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
alias cc="claude --continue"              # 最新セッション再開
# セッション管理関数: cls(一覧), csa(全検索) → functions/claude-functions.zsh

# ========================================
# zoxide（高速ディレクトリジャンプ）
# ========================================
alias j="z"                           # ディレクトリジャンプ
alias ji="zi"                         # インタラクティブ選択

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

# ファイルプレビュー: fp関数 (fzf-functions.zsh) を使用

# ========================================
# 開発ツール
# ========================================

# エディタ・ビューア
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias view="bat"                   # 軽量ファイル閲覧

# コマンド置換
alias diff="delta"
alias python="python3"
alias pip="pip3"

# ========================================
# Git（OMZにないもの）
# ========================================
alias gs="git status"                    # OMZのgstより短い
alias gpf='git push --force-with-lease'  # 安全なforce push

# ========================================
# システム・ネットワーク
# ========================================
alias reload="source ~/.zshrc"
alias df="df -h"                     # ディスク空き容量(human-readable)
alias du="du -sh"                    # ディスク使用量(summary)
alias top="btop"                     # モダンなシステムモニター
alias ports="lsof -i -P | grep LISTEN"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# ========================================
# その他
# ========================================
alias please='sudo $(fc -ln -1)'       # 直前コマンドをsudoで再実行
alias now="date '+%Y-%m-%d %H:%M:%S'"  # 現在時刻
alias o="open ."                       # Finderで開く
alias md="mkdir -p"                    # ディレクトリ作成（親も作成）
alias cpwd='pwd | tr -d "\n" | pbcopy && echo "Copied: $(pwd)"'  # 現在パスをコピー
alias ag="alias | grep"                # エイリアス検索
# port関数は functions/util-functions.zsh に定義（引数結合が必要なため）
