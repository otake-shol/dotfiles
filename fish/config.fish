
source /Users/otkshol/.docker/init-fish.sh || true # Added by Docker Desktop

string match -q "$TERM_PROGRAM" "kiro" and . (kiro --locate-shell-integration-path fish)
