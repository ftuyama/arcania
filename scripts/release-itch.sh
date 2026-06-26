#!/usr/bin/env bash
# Package Arcania for itch.io (HTML): ZIP with index.html at the archive root, or push with butler.
#
# Prerequisites:
#   - Godot 4.3+ with Web export templates (see ./scripts/export-web.sh --help)
#
# Manual upload (ZIP):
#   ./scripts/release-itch.sh
#   → creates release/arcania-itch.zip — upload at itch.io → Edit game → Uploads
#
# Upload with butler (delta patches; itch desktop app):
#   1. Install: https://itch.io/docs/butler/
#   2. API key: itch.io → Edit account → API keys → Generate
#   3. export BUTLER_API_KEY=...
#   4. ./scripts/release-itch.sh --push -- <itch-user> <game-slug>
#      or: ITCH_USER=... ITCH_GAME=... ./scripts/release-itch.sh --push
#
# Default butler channel for browser builds: "html"
#
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

ZIP_BASENAME="${ZIP_BASENAME:-arcania-itch.zip}"
RELEASE_DIR="${RELEASE_DIR:-$ROOT/release}"
DIST_DIR="${DIST_DIR:-$ROOT/builds/web}"
BUTLER_CHANNEL="${BUTLER_CHANNEL:-html}"

DO_PUSH=false
SKIP_ZIP=false
RUN_IMPORT=false

usage() {
	echo "Usage: $(basename "$0") [options] [--] [<itch-user> <game-slug>]"
	echo "  --push              Push $DIST_DIR with butler (needs BUTLER_API_KEY and user/slug)"
	echo "  --import            Reimport Godot assets before export (slower; useful on CI)"
	echo "  --no-zip            Build only (and --push if combined); skip ZIP"
	echo "  -h, --help          Show this help"
	echo
	echo "Positional args (with --push, if ITCH_USER/ITCH_GAME are unset):"
	echo "  <itch-user> <game-slug>"
}

while [[ $# -gt 0 ]]; do
	case "$1" in
	--push) DO_PUSH=true ;;
	--import) RUN_IMPORT=true ;;
	--no-zip) SKIP_ZIP=true ;;
	-h | --help)
		usage
		exit 0
		;;
	--)
		shift
		break
		;;
	-*)
		echo "Unknown option: $1" >&2
		usage >&2
		exit 1
		;;
	*)
		break
		;;
	esac
	shift
done

ITCH_USER="${ITCH_USER:-${1:-}}"
ITCH_GAME="${ITCH_GAME:-${2:-}}"

if [[ "$DO_PUSH" == true ]]; then
	if [[ -z "$ITCH_USER" || -z "$ITCH_GAME" ]]; then
		echo "With --push, set ITCH_USER and ITCH_GAME or pass: <user> <slug>" >&2
		exit 1
	fi
	if [[ -z "${BUTLER_API_KEY:-}" ]]; then
		echo "With --push, set BUTLER_API_KEY (itch.io → API keys)." >&2
		exit 1
	fi
fi

EXPORT_ARGS=()
if [[ "$RUN_IMPORT" == true ]]; then
	EXPORT_ARGS+=(--import)
fi

if [[ ${#EXPORT_ARGS[@]} -gt 0 ]]; then
	echo "→ ./scripts/export-web.sh ${EXPORT_ARGS[*]}"
	"$ROOT/scripts/export-web.sh" "${EXPORT_ARGS[@]}"
else
	echo "→ ./scripts/export-web.sh"
	"$ROOT/scripts/export-web.sh"
fi

if [[ ! -f "$DIST_DIR/index.html" ]]; then
	echo "ERROR: $DIST_DIR/index.html missing after export." >&2
	exit 1
fi

if [[ "$SKIP_ZIP" == false ]]; then
	mkdir -p "$RELEASE_DIR"
	ZIP_PATH="$RELEASE_DIR/$ZIP_BASENAME"
	echo "→ ZIP (index.html at archive root): $ZIP_PATH"
	rm -f "$ZIP_PATH"
	(cd "$DIST_DIR" && zip -q -r "$ZIP_PATH" .)
	echo "   $(wc -c <"$ZIP_PATH" | tr -d ' ') bytes"
fi

if [[ "$DO_PUSH" == true ]]; then
	if ! command -v butler >/dev/null 2>&1; then
		echo "ERROR: butler not in PATH. Install: https://itch.io/docs/butler/" >&2
		exit 1
	fi
	TARGET="${ITCH_USER}/${ITCH_GAME}:${BUTLER_CHANNEL}"
	echo "→ butler push $DIST_DIR $TARGET"
	butler push "$DIST_DIR" "$TARGET"
	echo "Done. On itch.io, set the project kind to HTML and link the html channel to Play in browser."
fi

echo "OK."
