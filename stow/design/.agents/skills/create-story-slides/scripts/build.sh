#!/bin/bash
# create-story-slides: Marp デッキを描画検査してから PDF を書き出す
#
# 使い方: build.sh <deck.md> [出力先ディレクトリ] [present|read] [--minutes N] [--notes]
#   1. ovs deck verify で静的検査と描画実測を行う。error があれば終了コード1で止める
#      （ovs がない環境では各スライドの PNG を書き出し、目視の確認に回す）
#   2. しおり付きの PDF を書き出す。発表者ノートは配布先に見えるため PDF に埋め込まない
#   3. --notes を指定した場合だけ既存ノートをテキストで書き出す
set -euo pipefail

skill_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly skill_dir
readonly theme="$skill_dir/assets/story-slides.css"

usage() {
	echo "使い方: $(basename "$0") <deck.md> [出力先ディレクトリ] [present|read] [--minutes N] [--notes]" >&2
	exit 2
}

main() {
	[[ $# -ge 1 ]] || usage
	local deck=$1
	shift
	local out_dir mode=present minutes="" export_notes=false
	local -a positional=() timing_args=()
	while [[ $# -gt 0 ]]; do
		case "$1" in
		--notes)
			export_notes=true
			shift
			;;
		--minutes)
			[[ $# -ge 2 && -z $minutes ]] || usage
			minutes=$2
			if [[ ! $minutes =~ ^[0-9]+([.][0-9]+)?$ || ! $minutes =~ [1-9] ]]; then
				echo "--minutes は正の数で指定してください" >&2
				exit 2
			fi
			timing_args=(--minutes "$minutes")
			shift 2
			;;
		--*) usage ;;
		*) positional+=("$1"); shift ;;
		esac
	done
	[[ ${#positional[@]} -le 2 ]] || usage
	out_dir=${positional[0]:-$(dirname "$deck")}
	mode=${positional[1]:-present}
	[[ $mode == present || $mode == read ]] || usage
	local name shots
	name=$(basename "$deck" .md)
	shots="$out_dir/$name-check"

	if [[ ! -f $deck ]]; then
		echo "デッキが見つかりません: $deck" >&2
		exit 1
	fi
	if ! command -v marp >/dev/null; then
		echo "marp がありません（brew install marp-cli）。PDF は書き出せません" >&2
		exit 1
	fi
	mkdir -p "$out_dir"

	if command -v ovs >/dev/null; then
		ovs deck verify "$deck" --mode "$mode" --theme "$theme" --shots "$shots" ${timing_args[@]+"${timing_args[@]}"}
	else
		if [[ -n $minutes ]]; then
			echo "ovs がないため持ち時間 ${minutes} 分の検査は未実施です" >&2
		fi
		echo "ovs がないため静的検査と実測は未実施です。$shots の PNG を1枚ずつ目視で確認してください" >&2
		mkdir -p "$shots"
		marp --no-stdin --html --allow-local-files --theme "$theme" --images png "$deck" -o "$shots/$name.png"
	fi

	marp --no-stdin --html --allow-local-files --theme "$theme" --pdf --pdf-outlines "$deck" -o "$out_dir/$name.pdf"
	if [[ $export_notes == true ]]; then
		marp --no-stdin --theme "$theme" --notes "$deck" -o "$out_dir/$name.notes.txt"
		echo "既存ノート: $out_dir/$name.notes.txt"
	fi

	echo "PDF: $out_dir/$name.pdf"
	echo "確認用の画像: $shots/"
}

main "$@"
