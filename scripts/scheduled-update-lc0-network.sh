#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${LOG_DIR:-$HOME/.local/state/mushroom-overlay}"
LOCK_FILE="${LOCK_FILE:-${XDG_RUNTIME_DIR:-/tmp}/update-lc0-network.lock}"

mkdir -p "$LOG_DIR"
exec >>"$LOG_DIR/update-lc0-network.log" 2>&1

printf '\n[%s] Starting scheduled LC0 network update\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"

cd "$ROOT"

flock -n "$LOCK_FILE" "$ROOT/scripts/update-lc0-network.sh"

if ! git diff --quiet -- games-board/lc0/lc0-9999.ebuild games-board/lc0/Manifest; then
	printf '[%s] LC0 network changed; review, commit, and push overlay updates.\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
	git status --short
else
	printf '[%s] LC0 network already current; no overlay changes.\n' "$(date '+%Y-%m-%d %H:%M:%S %z')"
fi
