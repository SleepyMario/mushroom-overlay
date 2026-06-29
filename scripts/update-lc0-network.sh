#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EBUILD="$ROOT/games-board/lc0/lc0-9999.ebuild"
BESTNETS_URL="https://lczero.org/play/networks/bestnets/"
DISTDIR="${DISTDIR:-$ROOT/distfiles}"

cd "$ROOT"

network_url="$(
	curl -fsSL "$BESTNETS_URL" |
		grep -Eo 'https://[^" ]+\.pb\.gz' |
		head -n 1
)"

if [[ -z "$network_url" ]]; then
	echo "Could not find a network URL on $BESTNETS_URL" >&2
	exit 1
fi

perl -0pi -e \
	"s#NETWORK_URI=\"[^\"]+\"#NETWORK_URI=\"$network_url\"#" \
	"$EBUILD"

mkdir -p "$DISTDIR"
DISTDIR="$DISTDIR" ebuild "$EBUILD" manifest

echo "Updated lc0 network to: ${network_url##*/}"
