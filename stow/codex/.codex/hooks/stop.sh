#!/bin/bash
# Codex Stop hook. Keep this lightweight; full validation is available via verify.sh.

set -euo pipefail

if [ -S /tmp/cmux.sock ] && command -v cmux >/dev/null 2>&1; then
    cmux notify --title "Codex" --body "Turn completed" >/dev/null 2>&1 || true
fi

exit 0
