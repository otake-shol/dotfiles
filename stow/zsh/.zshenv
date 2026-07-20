# .zshenv - すべての zsh 起動（対話・非対話・スクリプト）で最初に読まれる
#
# Claude Code 等の Bash ツールはシェルスナップショットから関数のみ復元し、
# .zshrc 由来の export は引き継がれない。全シェルへ確実に届けたい
# 環境変数はここに置く。

# zoxide doctor 警告を抑止。
# init はキャッシュ経由（tools.zsh）かつ .zshrc 末尾でないため、
# doctor が誤検知する。tools.zsh での export はスナップショット
# シェルに届かず抑止できないので .zshenv で設定する。
export _ZO_DOCTOR=0
