#!/usr/bin/env bash
# Boot a Godot scene/room and write a PNG screenshot for visual debugging.
#
# Does NOT use --headless (headless disables rendering → black frames).
# A borderless 960×540 window flashes briefly, then quits.
#
# Usage:
#   ./tools/capture_scene_screenshot.sh
#   ./tools/capture_scene_screenshot.sh at_01_threshold_hub
#   ./tools/capture_scene_screenshot.sh ww_07_heartwood_chamber /tmp/ww07.png
#   ./tools/capture_scene_screenshot.sh res://scenes/rooms/ashen_threshold/at_03_east_road.tscn
#
# Env:
#   GODOT_BIN   Override Godot executable (see tools/godot.sh)
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT_SH="$ROOT/tools/godot.sh"
OUT_DIR="$ROOT/tmp/scene_captures"
DEFAULT_SCENE="at_01_threshold_hub"

SCENE="${1:-$DEFAULT_SCENE}"
STAMP="$(date +%Y%m%d_%H%M%S)"
SAFE_NAME="$(echo "$SCENE" | sed 's#[/:]#_#g; s#\.tscn$##; s#^res___scenes_rooms_##' )"
OUT="${2:-$OUT_DIR/${SAFE_NAME}_${STAMP}.png}"

mkdir -p "$(dirname "$OUT")"
# Resolve to absolute path for Godot save_png.
OUT="$(cd "$(dirname "$OUT")" && pwd)/$(basename "$OUT")"

echo "Using Godot: $("$GODOT_SH" --print-path)"
echo "Scene: $SCENE"
echo "Out:   $OUT"

# Rendering requires a display; do not pass --headless.
"$GODOT_SH" --path "$ROOT/godot" \
	--script "res://tests/debug/capture_scene_screenshot.gd" \
	-- \
	"--scene=$SCENE" \
	"--out=$OUT"

echo "Done: $OUT"
