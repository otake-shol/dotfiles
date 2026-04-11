# ========================================
# システム
# ========================================
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
alias help="tldr"                    # コマンドヘルプ簡易版
alias mdv="glow"                     # Markdownターミナル表示 (markdown view)

# ========================================
# ネットワーク
# ========================================
alias myip="curl -s ifconfig.me"
alias localip="ipconfig getifaddr en0"
alias ips="echo 'Local:' && ipconfig getifaddr en0 && echo 'Global:' && curl -s ifconfig.me"
alias ports="lsof -i -P | grep LISTEN"
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias ping5="ping -c 5"                # 5回だけping
alias flushdns="sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder && echo 'DNS cache flushed'"
alias speedtest="speedtest-cli"        # brew install speedtest-cli

# 天気（wttr.in）
alias wttr="curl -s 'wttr.in/Tokyo?lang=ja'"           # 現在の天気
alias wttr3="curl -s 'wttr.in/Tokyo?lang=ja&format=v2'" # 3日間予報
alias wttr1="curl -s 'wttr.in/Tokyo?format=1'"          # 1行表示

# ========================================
# クリップボード操作
# ========================================
alias cpy="pbcopy"                     # コピー
alias pst="pbpaste"                    # ペースト
alias cpwd='pwd | tr -d "\n" | pbcopy && echo "Copied: $(pwd)"'  # 現在パスをコピー
# cpfile関数は functions/util-functions.zsh に定義

# ========================================
# エイリアス管理
# ========================================
alias aliases="cat ~/.aliases"         # 全表示
alias aliasgrep="alias | grep"         # 検索
alias ag="alias | grep"                # 短縮版
alias af="alias | fzf"                 # fzfで対話的検索
