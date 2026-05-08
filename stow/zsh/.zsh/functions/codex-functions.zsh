# shellcheck shell=bash
# ========================================
# Codex CLI helpers
# ========================================

# Ask Codex to inspect, verify, commit, and push the current working tree.
cxcp() {
  local extra="${*:-}"
  local prompt

  prompt="現在の Git working tree を確認し、問題なければコミットしてリモートに push してください。

必ず次の手順で進める:
1. git status と git diff を確認する。
2. 機密ファイル（.env, credentials, *.key, ~/.ssh 相当）が含まれていないか確認する。
3. 変更内容に応じた最小限の検証を実行する。この dotfiles では make lint と git diff --check を必須にし、必要に応じて bash bootstrap.sh --dry-run --yes --skip-apps / make stats / make check を使う。
4. Conventional Commits の短い英語サブジェクトを作る。
5. 未関係の変更が混じっている場合は、それを含めない。コミット対象ファイルを明示して codex-commit-push \"<message>\" <file...> を使う。
6. すべて同じ目的の変更だけなら codex-commit-push \"<message>\" でまとめてよい。
7. HOME側リンクの異常が疑われる場合は make doctor を実行し、失敗したら make doctor-plan で状況を報告する。壊れたリンクの削除は勝手に実行しない。
8. push 後に git status --short と git log -1 --oneline を確認して報告する。

未関係の変更が混じっている場合は、勝手に含めずに理由を説明して止める。"

  if [[ -n "$extra" ]]; then
    prompt="${prompt}

追加指示:
${extra}"
  fi

  codex exec "$prompt"
}
