#!/usr/bin/env bash
# Build Arcania for the browser (HTML5/WebAssembly).
#
# Prerequisites:
#   - Godot 4.3+ with Web export templates installed
#     (Editor → Manage Export Templates, or copy templates into ~/.local/share/godot/export_templates/)
#
# Usage:
#   ./scripts/export-web.sh              # export to builds/web/
#   ./scripts/export-web.sh --import     # reimport assets before export (slower, useful on CI/fresh clone)
#   ./scripts/export-web.sh --serve      # export, then serve locally for testing
#   ./scripts/export-web.sh --install-templates  # download Godot export templates (one-time)
#   GODOT_BIN=/path/to/Godot ./scripts/export-web.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_DIR="$ROOT/godot"
OUT_DIR="$ROOT/builds/web"
PRESET_NAME="Web"
EXPORT_FILE="$OUT_DIR/index.html"

RUN_IMPORT=false
RUN_SERVE=false
INSTALL_TEMPLATES=false

for arg in "$@"; do
	case "$arg" in
	--import) RUN_IMPORT=true ;;
	--serve) RUN_SERVE=true ;;
	--install-templates) INSTALL_TEMPLATES=true ;;
	-h | --help)
		sed -n '2,13p' "$0"
		exit 0
		;;
	*)
		echo "Unknown option: $arg (try --help)" >&2
		exit 1
		;;
	esac
done

resolve_godot() {
	if [[ -n "${GODOT_BIN:-}" ]]; then
		echo "$GODOT_BIN"
		return
	fi
	if command -v godot >/dev/null 2>&1; then
		command -v godot
		return
	fi
	if command -v godot4 >/dev/null 2>&1; then
		command -v godot4
		return
	fi
	local mac_app
	for mac_app in \
		"/Applications/Godot.app/Contents/MacOS/Godot" \
		"/Applications/Godot 4.app/Contents/MacOS/Godot" \
		"$HOME/Applications/Godot.app/Contents/MacOS/Godot" \
		"$HOME/Applications/Godot 4.app/Contents/MacOS/Godot"; do
		if [[ -x "$mac_app" ]]; then
			echo "$mac_app"
			return
		fi
	done
	echo "ERROR: Godot 4 not found. Install Godot 4.3+ and Web export templates," >&2
	echo "       or set GODOT_BIN to your Godot executable." >&2
	exit 1
}

GODOT="$(resolve_godot)"
echo "Using Godot: $GODOT"
GODOT_VERSION="$("$GODOT" --version)"
echo "$GODOT_VERSION"

godot_templates_dir() {
	local major_minor
	major_minor="$(echo "$GODOT_VERSION" | sed -E 's/^([0-9]+\.[0-9]+)\..*/\1/')"
	if [[ "$(uname -s)" == "Darwin" ]]; then
		echo "$HOME/Library/Application Support/Godot/export_templates/${major_minor}.stable"
	elif [[ -n "${XDG_DATA_HOME:-}" ]]; then
		echo "$XDG_DATA_HOME/godot/export_templates/${major_minor}.stable"
	else
		echo "$HOME/.local/share/godot/export_templates/${major_minor}.stable"
	fi
}

install_export_templates() {
	local templates_dir version_slug url tmp
	templates_dir="$(godot_templates_dir)"
	version_slug="$(basename "$templates_dir")"
	url="https://github.com/godotengine/godot/releases/download/${version_slug}/Godot_v${version_slug}_export_templates.tpz"
	tmp="$(mktemp -d)"
	echo "Downloading export templates from $url ..."
	curl -fsSL -o "$tmp/templates.tpz" "$url"
	mkdir -p "$templates_dir"
	unzip -q "$tmp/templates.tpz" -d "$tmp/extract"
	cp -R "$tmp/extract/templates/"* "$templates_dir/"
	rm -rf "$tmp"
	echo "Installed templates to $templates_dir"
}

templates_ready() {
	local templates_dir="$1"
	[[ -f "$templates_dir/web_nothreads_release.zip" ]]
}

TEMPLATES_DIR="$(godot_templates_dir)"
if [[ "$INSTALL_TEMPLATES" == true ]]; then
	install_export_templates
	if [[ $# -eq 1 ]]; then
		exit 0
	fi
fi

if ! templates_ready "$TEMPLATES_DIR"; then
	echo "ERROR: Web export templates not found at:" >&2
	echo "  $TEMPLATES_DIR/web_nothreads_release.zip" >&2
	echo "" >&2
	echo "Install once with:" >&2
	echo "  ./scripts/export-web.sh --install-templates" >&2
	echo "Or in Godot: Editor → Manage Export Templates" >&2
	exit 1
fi

mkdir -p "$OUT_DIR"

if [[ "$RUN_IMPORT" == true ]]; then
	echo "Importing project assets..."
	"$GODOT" --headless --path "$PROJECT_DIR" --import --quit
fi

echo "Exporting Web build to $OUT_DIR ..."
"$GODOT" --headless --path "$PROJECT_DIR" --export-release "$PRESET_NAME" "$EXPORT_FILE"

if [[ ! -f "$EXPORT_FILE" ]]; then
	echo "ERROR: Export failed — $EXPORT_FILE was not created." >&2
	echo "       Install Web export templates matching your Godot version." >&2
	exit 1
fi

echo ""
echo "Web build ready:"
echo "  $OUT_DIR"
echo ""
echo "itch.io release: ./scripts/release-itch.sh"
echo "Local test: ./scripts/export-web.sh --serve"

if [[ "$RUN_SERVE" == true ]]; then
	if command -v python3 >/dev/null 2>&1; then
		echo "Serving http://127.0.0.1:8060/ (Ctrl+C to stop)"
		cd "$OUT_DIR"
		python3 -m http.server 8060
	elif command -v python >/dev/null 2>&1; then
		echo "Serving http://127.0.0.1:8060/ (Ctrl+C to stop)"
		cd "$OUT_DIR"
		python -m http.server 8060
	else
		echo "Python not found; open $EXPORT_FILE with a local web server manually." >&2
		exit 1
	fi
fi
