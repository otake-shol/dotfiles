# core.zsh - 基本設定・オプション

# --- カラーコード定数 ---
NC='\033[0m'

# --- エディタ ---
export EDITOR="nvim"
export VISUAL="nvim"
export GIT_EDITOR="nvim"

# --- manページをbatでカラー表示 ---
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# --- Claude Code: フリッカーフリーレンダリング（alt-screen + 仮想スクロールバック） ---
export CLAUDE_CODE_NO_FLICKER=1

# --- 実行時間の自動表示（カラー対応） ---
# p10k instant prompt対応: 初期化中は出力しない
_zsh_initialized=false

# preexec: コマンド実行前に時刻を記録
_cmd_start_time=""
_last_cmd=""
_preexec_timer() {
  _zsh_initialized=true
  _cmd_start_time=$EPOCHSECONDS
  _last_cmd="$1"
}

# precmd: コマンド実行後に経過時間を表示 + エラー提案
_precmd_timer() {
  local exit_code=$?

  # 初期化完了前は何も出力しない（instant prompt対応）
  [[ "$_zsh_initialized" != true ]] && return

  # 実行時間表示 + 通知音
  if [[ -n "$_cmd_start_time" ]]; then
    local elapsed=$((EPOCHSECONDS - _cmd_start_time))
    if [[ $elapsed -ge 5 ]]; then
      local color
      if [[ $elapsed -ge 30 ]]; then
        color='\033[91m'  # 赤: 30秒以上
      elif [[ $elapsed -ge 10 ]]; then
        color='\033[93m'  # 黄: 10秒以上
      else
        color='\033[92m'  # 緑: 5秒以上
      fi
      echo -e "${color}⏱ ${elapsed}s${NC}"
    fi
    # 長時間コマンド完了時の通知音
    _notify_sound "$elapsed" "$exit_code"
  fi

  # コマンド失敗時の提案
  if [[ $exit_code -ne 0 && -n "$_last_cmd" ]]; then
    _suggest_fix "$_last_cmd" "$exit_code"
  fi

  _cmd_start_time=""
  _last_cmd=""
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _preexec_timer
add-zsh-hook precmd _precmd_timer

# エラー時の修正提案
_suggest_fix() {
  local cmd="$1"
  local code="$2"
  local suggestion=""

  case "$cmd" in
    git\ push*)
      [[ $code -eq 128 ]] && suggestion="git pull --rebase してから再度 push"
      ;;
    git\ checkout*)
      suggestion="変更を stash するか commit してください: git stash"
      ;;
    npm\ *)
      suggestion="node_modules を削除して再インストール: rm -rf node_modules && npm install"
      ;;
    pip\ install*)
      suggestion="仮想環境を確認: source .venv/bin/activate"
      ;;
    sudo\ *)
      [[ $code -eq 1 ]] && suggestion="パスワードを確認、または権限が必要な操作か確認"
      ;;
    ssh\ *)
      suggestion="SSH鍵を確認: ssh-add -l"
      ;;
    *)
      # command not found
      if [[ $code -eq 127 ]]; then
        local first_word="${cmd%% *}"
        # ネットワークアクセスを避け、ヒントのみ表示
        if command -v brew &>/dev/null; then
          suggestion="brew install ${first_word} で入るかも（brew search ${first_word} で確認）"
        fi
      fi
      ;;
  esac

  if [[ -n "$suggestion" ]]; then
    echo -e "\033[93m💡 ヒント: ${suggestion}${NC}"
  fi
}

# 長時間コマンド完了時の通知音（10秒以上かかった場合）
_notify_sound() {
  local elapsed="$1"
  local exit_code="$2"

  # 10秒以上かかったコマンドのみ
  [[ $elapsed -lt 10 ]] && return

  # バックグラウンドで音を鳴らす
  if [[ $exit_code -eq 0 ]]; then
    # 成功: 軽快な音
    afplay /System/Library/Sounds/Glass.aiff &>/dev/null &
  else
    # 失敗: 警告音
    afplay /System/Library/Sounds/Basso.aiff &>/dev/null &
  fi
}

# REPORTTIME は無効化（カスタム表示を使用）
# REPORTTIME=5

# History settings
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

# Zsh options
setopt no_beep
setopt auto_pushd
setopt pushd_ignore_dups
setopt auto_cd
setopt hist_ignore_dups
setopt hist_ignore_all_dups    # 重複を完全排除
setopt hist_ignore_space       # スペースで始まるコマンドを履歴に残さない
setopt hist_reduce_blanks      # 余分な空白を削除
setopt share_history
setopt inc_append_history
setopt extended_history        # タイムスタンプを記録
setopt correct                 # コマンドのスペルミスを修正
CORRECT_IGNORE='_*|claude'     # claude は遅延読み込みのため除外
setopt complete_in_word        # 単語の途中でも補完

# Ctrl+Z でfg/bgトグル
function fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    BUFFER="fg"
    zle accept-line
  else
    zle push-input
    zle clear-screen
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

# ========================================
# 補完強化
# ========================================
# 大文字小文字を無視（cd doc → Documents にマッチ）
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# 補完候補をメニュー表示（Tab連打で選択可能）
zstyle ':completion:*' menu select

# 補完候補に色付け（ls --colorと同じ色）
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# 補完候補をグループ化して説明表示
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'

# 補完候補のキャッシュ（大規模補完の高速化）
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# killコマンドでプロセス名を補完
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# cdで親ディレクトリも補完候補に
zstyle ':completion:*' special-dirs true

# OMZ gitプラグインのalias解除（関数定義と競合するため、先に実行）
unalias gpr gbr 2>/dev/null

# --- ターミナル起動中はディスプレイスリープ（画面OFF）を抑止（電池連動）---
# 条件: 実端末(tty)が開いている & (AC接続 or バッテリー残量 >= CAFFEINATE_MIN_BATT%)
# 60秒ごとに再判定して caffeinate を自動 ON/OFF。端末を閉じると監視ごと終了し即解除。
# [[ -t 1 ]] で本物のターミナルに限定（パイプ接続のフック/コマンドシェルには生やさない）。
#   無効化      : CAFFEINATE_DISABLE=1（.zshenv で export）
#   しきい値変更 : CAFFEINATE_MIN_BATT=50 等（.zshenv で export。既定 30）
: ${CAFFEINATE_MIN_BATT:=30}
if [[ "$OSTYPE" == darwin* ]] && [[ -t 1 ]] && [[ -z "$CAFFEINATE_SHELL" ]] && [[ -z "$CAFFEINATE_DISABLE" ]] \
    && command -v caffeinate >/dev/null 2>&1; then
    export CAFFEINATE_SHELL=1
    _caffeinate_watch() {
        local shell_pid=$1 caff_pid="" batt pct
        while kill -0 "$shell_pid" 2>/dev/null; do
            batt=$(pmset -g batt 2>/dev/null)
            pct=$(print -r -- "$batt" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
            if [[ "$batt" == *"'AC Power'"* ]] \
               || { [[ -n "$pct" ]] && (( pct >= CAFFEINATE_MIN_BATT )); }; then
                # 抑止すべき: caffeinate が動いていなければ起動（-w でシェル終了に即追従）
                if [[ -z "$caff_pid" ]] || ! kill -0 "$caff_pid" 2>/dev/null; then
                    caffeinate -d -w "$shell_pid" & caff_pid=$!
                fi
            else
                # 抑止不要（低残量など）: 動いていれば停止して画面OFFを許可
                [[ -n "$caff_pid" ]] && kill "$caff_pid" 2>/dev/null
                caff_pid=""
            fi
            sleep 60
        done
        [[ -n "$caff_pid" ]] && kill "$caff_pid" 2>/dev/null  # シェル終了時の後始末
    }
    _caffeinate_watch $$ &!
fi

# --- iCloud等の同期フォルダからの claude/codex 起動を安全化するラッパー ---
# iCloud/Google Drive 等（FileProvider管理）を CWD にして起動すると、起動時の
# Seatbelt サンドボックス初期化が EPERM で落ちる既知不具合がある。
#   claude: anthropics/claude-code#71955（settings.json では無効化不可）
#   codex : sandbox_mode=workspace-write のサンドボックス初期化が同様に失敗
# CWD が同期フォルダ配下のときだけ $HOME から起動して回避。通常パスは素通し。
# 実体は `command` で呼ぶ（関数の無限再帰を防止）。
_is_cloudsync_dir() {
    local p=${1:-$PWD}
    [[ "$p" == "$HOME/Library/Mobile Documents/"* ]] \
        || [[ "$p" == "$HOME/Library/CloudStorage/"* ]]
}

claude() {
    if _is_cloudsync_dir; then
        local here=$PWD
        print -ru2 -- "⚠️  同期フォルダのため \$HOME から起動し '$here' を --add-dir で追加（#71955回避）"
        ( builtin cd -- "$HOME" && command claude --add-dir "$here" "$@" )
    else
        command claude "$@"
    fi
}

# Remote対応サブコマンドまたは通常の対話セッションなら成功を返す。
# exec/review等の非対話・管理系サブコマンドはローカル実行のままにする。
_codex_uses_remote() {
    local arg
    local skip_value=0

    for arg in "$@"; do
        if (( skip_value )); then
            skip_value=0
            continue
        fi

        case "$arg" in
            --remote | --remote=* | --remote-auth-token-env | --remote-auth-token-env=*)
                # 明示指定を尊重し、ラッパー側では接続先を上書きしない。
                return 1
                ;;
            -h | --help | -V | --version)
                return 1
                ;;
            -c | --config | --enable | --disable | -m | --model | --local-provider | -p | --profile | -s | --sandbox | -C | --cd | --add-dir | -a | --ask-for-approval)
                skip_value=1
                ;;
            --config=* | --enable=* | --disable=* | --model=* | --local-provider=* | --profile=* | --sandbox=* | --cd=* | --add-dir=* | --ask-for-approval=*)
                ;;
            resume | fork | archive | delete | unarchive)
                return 0
                ;;
            exec | e | review | login | logout | mcp | plugin | mcp-server | app-server | remote-control | app | completion | update | doctor | sandbox | debug | apply | a | cloud | cloud-tasks | exec-server | execpolicy | features | help)
                return 1
                ;;
            --)
                return 0
                ;;
            -*)
                ;;
            *)
                # 未知の最初の位置引数は初回プロンプト。
                return 0
                ;;
        esac
    done

    return 0
}

_codex_is_session_management() {
    local arg
    local skip_value=0

    for arg in "$@"; do
        if (( skip_value )); then
            skip_value=0
            continue
        fi

        case "$arg" in
            -c | --config | --enable | --disable | -m | --model | --local-provider | -p | --profile | -s | --sandbox | -C | --cd | --add-dir | -a | --ask-for-approval | --remote-auth-token-env)
                skip_value=1
                ;;
            resume | fork | archive | delete | unarchive)
                return 0
                ;;
        esac
    done

    return 1
}

_codex_maybe_cleanup_sessions() {
    local codex_bin=$1
    shift
    local cleanup_script="$HOME/.codex/bin/session-cleanup.mjs"

    [[ -t 0 && -t 1 ]] || return 0
    [[ "${CODEX_SESSION_CLEANUP_ENABLED:-1}" != "0" ]] || return 0
    _codex_is_session_management "$@" && return 0
    [[ -f "$cleanup_script" ]] || return 0
    command -v node >/dev/null 2>&1 || return 0

    if ! command node "$cleanup_script" --maybe-prompt --codex "$codex_bin"; then
        print -ru2 -- "⚠️  Codexセッション数の確認に失敗しました（起動は継続します）"
    fi
}

_codex_run() {
    local standalone_codex="$HOME/.codex/packages/standalone/current/codex"
    local codex_bin

    if [[ -x "$standalone_codex" ]]; then
        codex_bin="$standalone_codex"
    else
        codex_bin="$(whence -p codex)"
    fi

    if [[ -z "$codex_bin" ]]; then
        print -ru2 -- "codex executable not found"
        return 127
    fi

    if _codex_uses_remote "$@"; then
        if [[ "$codex_bin" != "$standalone_codex" ]]; then
            print -ru2 -- "⚠️  Remote連携にはCodex standalone版が必要なため、今回はローカル起動します"
            "$codex_bin" "$@"
            return
        fi

        if ! "$codex_bin" remote-control start >/dev/null 2>&1; then
            print -ru2 -- "⚠️  Remote Controlを起動できなかったため、今回はローカル起動します"
            "$codex_bin" "$@"
            return
        fi

        _codex_maybe_cleanup_sessions "$codex_bin" "$@"
        "$codex_bin" --remote unix:// "$@"
    else
        "$codex_bin" "$@"
    fi
}

codex-session-cleanup() {
    local standalone_codex="$HOME/.codex/packages/standalone/current/codex"
    local cleanup_script="$HOME/.codex/bin/session-cleanup.mjs"

    if [[ ! -x "$standalone_codex" ]]; then
        print -ru2 -- "Codex standalone版が見つかりません"
        return 127
    fi
    if [[ ! -f "$cleanup_script" ]] || ! command -v node >/dev/null 2>&1; then
        print -ru2 -- "Codexセッション整理スクリプトを実行できません"
        return 127
    fi

    command node "$cleanup_script" --interactive --codex "$standalone_codex"
}

codex() {
    if _is_cloudsync_dir; then
        local here=$PWD
        print -ru2 -- "⚠️  同期フォルダのため \$HOME から起動（サンドボックス初期化のEPERM回避）"
        print -ru2 -- "    Vault内ファイルを編集したい場合: codex --sandbox danger-full-access（サンドボックス無効）"
        ( builtin cd -- "$HOME" && _codex_run "$@" )
    else
        _codex_run "$@"
    fi
}

# 関数ファイルの読み込み（fzf-functions以外、fzfはlazy.zshで遅延読み込み）
for func_file in "$ZSH_CONFIG_DIR/functions"/{git,util,claude,codex}-functions.zsh; do
    [[ -f "$func_file" ]] && source "$func_file"
done

# エイリアスファイルの読み込み
for alias_file in "$ZSH_CONFIG_DIR/aliases"/*.zsh; do
    [[ -f "$alias_file" ]] && source "$alias_file"
done

unset func_file alias_file
