# ========================================
# Docker
# ========================================
alias d="docker"
alias dc="docker compose"          # Docker Compose v2
alias dcu="docker compose up"
alias dcud="docker compose up -d"  # デタッチモード
alias dcd="docker compose down"
alias dcb="docker compose build"
alias dclogs="docker compose logs -f"
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"
alias drm="docker rm"
alias drmi="docker rmi"
alias dstop="docker stop"
alias dstart="docker start"
alias dexec="docker exec -it"      # コンテナに入る

# クリーンアップ
alias dclean="docker system prune -af"              # 全クリーンアップ（確認なし）
alias dcleanv="docker system prune -af --volumes"   # ボリューム含めてクリーンアップ
alias drmall="docker rm -f \$(docker ps -aq)"       # 全コンテナ削除
alias drmiall="docker rmi -f \$(docker images -q)"  # 全イメージ削除
