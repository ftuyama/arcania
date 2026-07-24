#!/usr/bin/env bash
# Resolve Godot 4 and run it with the given args (or print the binary path).
#
# Resolution order:
#   1. GODOT_BIN env var
#   2. `godot` / `godot4` on PATH
#   3. Common macOS .app locations
#
# Usage:
#   ./tools/godot.sh --version
#   ./tools/godot.sh --print-path
#   ./tools/godot.sh --headless --path godot --script res://tests/unit/test_runner.gd
#   GODOT_BIN=/path/to/Godot ./tools/godot.sh --version
#
# Put this repo's tools/bin on your PATH to get a `godot` shim:
#   export PATH="/path/to/arcania/tools/bin:$PATH"
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

resolve_godot() {
	if [[ -n "${GODOT_BIN:-}" ]]; then
		echo "$GODOT_BIN"
		return
	fi
	if command -v godot >/dev/null 2>&1; then
		# Prefer a real install over this repo's tools/bin shim (avoid recursion).
		local found
		found="$(command -v godot)"
		if [[ "$found" != "$ROOT/tools/bin/godot" ]]; then
			echo "$found"
			return
		fi
		# Shim is first on PATH — look further.
		local candidate
		while IFS= read -r candidate; do
			if [[ "$candidate" != "$ROOT/tools/bin/godot" ]]; then
				echo "$candidate"
				return
			fi
		done < <(type -aP godot 2>/dev/null || true)
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
	echo "ERROR: Godot 4 not found. Install Godot 4.3+," >&2
	echo "       or set GODOT_BIN to your Godot executable." >&2
	exit 1
}

PRINT_PATH=false
if [[ "${1:-}" == "--print-path" ]]; then
	PRINT_PATH=true
	shift
elif [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
	sed -n '2,18p' "$0"
	exit 0
fi

GODOT="$(resolve_godot)"
if [[ "$PRINT_PATH" == true ]]; then
	echo "$GODOT"
	exit 0
fi

exec "$GODOT" "$@"
