#!/bin/bash
# Claude Code Status Line Script
# Layout: [Directory] [Branch] | [Model] [Progress Bar] [Percentage] [Tokens]

set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract values using jq
MODEL_NAME=$(echo "$INPUT" | jq -r '.model.display_name // "Unknown"')
CURRENT_DIR=$(echo "$INPUT" | jq -r '.workspace.current_dir // ""')
USED_PERCENTAGE=$(echo "$INPUT" | jq -r '.context_window.used_percentage // empty')
TOTAL_INPUT=$(echo "$INPUT" | jq -r '.context_window.total_input_tokens // 0')
TOTAL_OUTPUT=$(echo "$INPUT" | jq -r '.context_window.total_output_tokens // 0')
CONTEXT_SIZE=$(echo "$INPUT" | jq -r '.context_window.context_window_size // 200000')

# Get directory basename
if [ -n "$CURRENT_DIR" ]; then
    DIR_NAME=$(basename "$CURRENT_DIR")
else
    DIR_NAME="~"
fi

# Get git branch
GIT_BRANCH=""
if [ -n "$CURRENT_DIR" ] && [ -d "$CURRENT_DIR/.git" ]; then
    GIT_BRANCH=$(cd "$CURRENT_DIR" && git branch --show-current 2>/dev/null || echo "")
fi

# ANSI color codes
CYAN='\033[36m'
YELLOW='\033[33m'
MAGENTA='\033[1;35m'
GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'
DIM='\033[2m'

# Build left section: [Directory] [Branch]
LEFT_SECTION="${CYAN}${DIR_NAME}${RESET}"

if [ -n "$GIT_BRANCH" ]; then
    LEFT_SECTION="${LEFT_SECTION} ${YELLOW}${GIT_BRANCH}${RESET}"
fi

# Build progress bar
PROGRESS_SECTION=""
if [ -n "$USED_PERCENTAGE" ]; then
    # Determine color based on usage
    BAR_COLOR="$GREEN"
    PCT_INT=$(printf "%.0f" "$USED_PERCENTAGE")
    if [ "$PCT_INT" -ge 80 ]; then
        BAR_COLOR="$RED"
    elif [ "$PCT_INT" -ge 50 ]; then
        BAR_COLOR="$YELLOW"
    fi

    # Calculate filled and empty blocks (10 total)
    FILLED=$(( PCT_INT / 10 ))
    EMPTY=$(( 10 - FILLED ))

    BAR="["
    for ((i=0; i<FILLED; i++)); do
        BAR="${BAR}█"
    done
    for ((i=0; i<EMPTY; i++)); do
        BAR="${BAR}░"
    done
    BAR="${BAR}]"

    PROGRESS_SECTION="${BAR_COLOR}${BAR}${RESET} ${USED_PERCENTAGE}%"
fi

# Calculate token usage in k format
CURRENT_TOKENS=$(( TOTAL_INPUT + TOTAL_OUTPUT ))
if [ "$CURRENT_TOKENS" -ge 1000 ]; then
    CURRENT_K=$(awk "BEGIN {printf \"%.1f\", $CURRENT_TOKENS / 1000}")
else
    CURRENT_K="$CURRENT_TOKENS"
fi
MAX_K=$(( CONTEXT_SIZE / 1000 ))
TOKEN_SECTION="${CURRENT_K}k/${MAX_K}k"

# Build right section: [Model] [Progress] [Tokens]
RIGHT_SECTION="${MAGENTA}${MODEL_NAME}${RESET}"

if [ -n "$PROGRESS_SECTION" ]; then
    RIGHT_SECTION="${RIGHT_SECTION} ${PROGRESS_SECTION}"
fi

RIGHT_SECTION="${RIGHT_SECTION} ${DIM}${TOKEN_SECTION}${RESET}"

# Output: [Left] | [Right]
printf "${LEFT_SECTION} ${DIM}|${RESET} ${RIGHT_SECTION}"
