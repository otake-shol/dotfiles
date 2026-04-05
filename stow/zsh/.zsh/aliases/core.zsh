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
# rm関数は functions/util-functions.zsh に定義

# ========================================
# Claude Code
# ========================================
alias c="claude"                          # 基本起動
alias co="claude --model opus"            # Opusモデル
alias cs="claude --model sonnet"          # Sonnetモデル
alias ch="claude --model haiku"           # Haikuモデル
alias clp="claude --print"                # 非対話モード（パイプ用）
alias claude-mem='node "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
# セッション管理関数: cls(一覧), csa(全検索), csd(削除), cc(続行), cm(モデル指定)

# ========================================
# システム・ネットワーク
# ========================================

# システム
alias reload="source ~/.zshrc"
alias zshconfig="vim ~/.zshrc"
alias aliasconfig="vim ~/.aliases"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias zshtime="time zsh -i -c exit"  # zsh起動時間計測
alias path='echo -e ${PATH//:/\\n}'
alias his="history"
alias df="df -h"                     # ディスク空き容量(human-readable)
alias du="du -sh"                    # ディスク使用量(summary)
alias top="btop"                     # モダンなシステムモニター
# alias ps="procs"                  # 削除: btop + fkill関数で代替
alias help="tldr"                    # コマンドヘルプ簡易版
alias mdv="glow"                     # Markdownターミナル表示 (markdown view)

# ネットワーク
alias myip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en0"
alias ips="echo 'Local:' && ipconfig getifaddr en0 && echo 'Global:' && curl -s ifconfig.me"
alias ports="lsof -i -P | grep LISTEN"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"

# 天気（wttr.in）
alias wttr="curl -s 'wttr.in/Tokyo?lang=ja'"           # 現在の天気
alias wttr3="curl -s 'wttr.in/Tokyo?lang=ja&format=v2'" # 3日間予報
alias wttr1="curl -s 'wttr.in/Tokyo?format=1'"          # 1行表示

# ========================================
# zoxide（高速ディレクトリジャンプ）
# ========================================
alias j="z"                           # ディレクトリジャンプ
alias ji="zi"                         # インタラクティブ選択

# ========================================
# dotfiles管理
# ========================================

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

# ファイルプレビュー: fp関数 (fzf-functions.zsh) を使用

# ========================================
# 開発ツール
# ========================================

# エディタ（nvim統一）
alias vim="nvim"
alias vi="nvim"
alias v="nvim"

# diff（deltaでカラー表示）
alias diff="delta"

# ========================================
# 即戦力系
# ========================================
alias please='sudo $(fc -ln -1)'       # 直前コマンドをsudoで再実行
alias cl="clear && ls"                 # クリア後にls
alias now="date '+%Y-%m-%d %H:%M:%S'"  # 現在時刻
alias week="date +%V"                  # 今週の週番号
alias o="open ."                       # Finderで開く
alias oo="open"                        # 指定ファイル/URLを開く

# ========================================
# クリップボード操作
# ========================================
alias cpy="pbcopy"                     # コピー
alias pst="pbpaste"                    # ペースト
alias cpwd='pwd | tr -d "\n" | pbcopy && echo "Copied: $(pwd)"'  # 現在パスをコピー
cpfile() { cat "$1" | pbcopy && echo "Copied: $1"; }             # ファイル内容をコピー

# ========================================
# ファイル操作
# ========================================
alias take="mkcd"                      # mkdir + cd（mkcdのエイリアス）
alias rd="rmdir"                       # ディレクトリ削除
alias md="mkdir -p"                    # ディレクトリ作成（親も作成）
sizeof() { du -sh "${1:-.}" | cut -f1; }  # サイズ確認

# ========================================
# ネットワーク強化
# ========================================
alias ping5="ping -c 5"                # 5回だけping
alias flushdns="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo 'DNS cache flushed'"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -"

# ========================================
# エイリアス管理
# ========================================
alias aliases="cat ~/.aliases"         # 全表示
alias aliasgrep="alias | grep"         # 検索
alias ag="alias | grep"                # 短縮版
alias af="alias | fzf"                 # fzfで対話的検索
