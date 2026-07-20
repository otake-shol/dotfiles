#!/bin/bash
# Summarize token usage from one or more `codex exec --json` traces.

set -euo pipefail

usage() {
    cat <<'EOF'
Usage: model-usage.sh [trace.jsonl ...]

Read Codex JSONL traces and print per-file plus aggregate token usage.
With no files, read one trace from stdin.

Create a trace without persisting the Codex session:
  codex exec --ephemeral --json "task" > trace.jsonl
EOF
}

require_jq() {
    if ! command -v jq >/dev/null 2>&1; then
        echo "jq is required." >&2
        exit 127
    fi
}

summarize() {
    local label="$1"
    shift
    local row

    row=$(
        jq -rs --arg label "$label" '
            [
                .[]
                | select(
                    .type == "turn.completed"
                    and (.usage | type == "object")
                )
                | .usage
            ] as $turns
            | ($turns | map(.input_tokens // 0) | add // 0) as $input
            | ($turns | map(.cached_input_tokens // 0) | add // 0) as $cached
            | ($turns | map(.output_tokens // 0) | add // 0) as $output
            | ($turns | map(.reasoning_output_tokens // 0) | add // 0) as $reasoning
            | if ($turns | length) == 0 then
                empty
              else
                [
                    $label,
                    ($turns | length),
                    $input,
                    $cached,
                    ([$input - $cached, 0] | max),
                    $output,
                    $reasoning,
                    ($input + $output),
                    (if $input > 0 then ((1000 * $cached / $input) | round / 10) else 0 end)
                ]
                | @tsv
              end
        ' "$@"
    )

    if [ -z "$row" ]; then
        echo "No turn.completed usage found in: $label" >&2
        return 1
    fi

    printf '%s\n' "$row"
}

main() {
    local files=("$@")
    local file

    if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
        usage
        return 0
    fi

    require_jq
    printf 'source\tturns\tinput\tcached\tuncached\toutput\treasoning\ttotal\tcache_pct\n'

    if [ "${#files[@]}" -eq 0 ]; then
        summarize "stdin"
        return
    fi

    for file in "${files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "Trace not found: $file" >&2
            return 2
        fi
        summarize "$file" "$file"
    done

    if [ "${#files[@]}" -gt 1 ]; then
        summarize "TOTAL" "${files[@]}"
    fi
}

main "$@"
