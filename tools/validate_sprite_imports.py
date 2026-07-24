#!/usr/bin/env python3.11
"""Validate Arcania sprite imports against art-style-lock + asset production list.

Usage:
  python3 tools/validate_sprite_imports.py
  python3 tools/validate_sprite_imports.py --strict
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
SPRITES = ROOT / "godot" / "assets" / "sprites"

# Wave 1 required assets (style-lock exit criteria)
WAVE1_REQUIRED: list[tuple[str, tuple[int, int] | None]] = [
    ("player/elara_core.png", None),  # multi-row sheet
    ("player/elara_portrait_48.png", (48, 48)),
    ("tilesets/01_ashen_threshold/tileset.png", None),
    ("tilesets/01_ashen_threshold/parallax_0_sky.png", (960, 540)),
    ("tilesets/01_ashen_threshold/parallax_1_far_ruins.png", (960, 540)),
    ("tilesets/01_ashen_threshold/parallax_2_mid_architecture.png", (960, 540)),
    ("tilesets/01_ashen_threshold/parallax_3_mid_fog.png", (960, 540)),
    ("tilesets/01_ashen_threshold/parallax_4_near_occluders.png", (960, 540)),
    ("tilesets/01_ashen_threshold/props.png", None),
    ("enemies/e01_ash_wisp/e01_sheet.png", None),
    ("enemies/e02_bone_crawler/e02_sheet.png", None),
    ("enemies/e04_ember_moth/e04_sheet.png", None),
    ("enemies/e08_threshold_shade/e08_sheet.png", None),
    ("vfx/spells/vfx_ember_sigil.png", None),
    ("vfx/spells/vfx_ember_bolt.png", None),
]

# Co-located SpriteFrames expected beside character/VFX sheets
TRES_PAIRS = [
    "player/elara_core",
    "enemies/e01_ash_wisp/e01_sheet",
    "enemies/e02_bone_crawler/e02_sheet",
    "enemies/e03_bramble_stalker/e03_sheet",
    "enemies/e04_ember_moth/e04_sheet",
    "enemies/e08_threshold_shade/e08_sheet",
    "vfx/spells/vfx_ember_sigil",
    "vfx/spells/vfx_ember_bolt",
]

SNAKE_OK = set("abcdefghijklmnopqrstuvwxyz0123456789_.")


def check_naming(rel: str, errors: list[str]) -> None:
    name = Path(rel).name
    if name != name.lower() or any(c not in SNAKE_OK for c in name):
        errors.append(f"naming: {rel} must be lowercase snake_case")


def check_png(rel: str, expected_size: tuple[int, int] | None, errors: list[str], warnings: list[str]) -> None:
    path = SPRITES / rel
    if not path.exists():
        errors.append(f"missing: {rel}")
        return
    check_naming(rel, errors)
    try:
        with Image.open(path) as img:
            w, h = img.size
            if expected_size and (w, h) != expected_size:
                errors.append(f"size: {rel} is {w}x{h}, expected {expected_size[0]}x{expected_size[1]}")
            if rel.endswith("tileset.png") and (h != 64 or w % 64 != 0):
                warnings.append(f"tileset: {rel} should be N*64 x 64 (got {w}x{h})")
            if "parallax" in rel and h != 540:
                warnings.append(f"parallax: {rel} height {h} != 540")
            if img.mode not in ("RGBA", "RGB"):
                warnings.append(f"mode: {rel} is {img.mode}, prefer RGBA")
    except OSError as exc:
        errors.append(f"unreadable: {rel} ({exc})")


def check_tres_pairs(errors: list[str]) -> None:
    for stem in TRES_PAIRS:
        png = SPRITES / f"{stem}.png"
        tres = SPRITES / f"{stem}.tres"
        if png.exists() and not tres.exists():
            errors.append(f"missing .tres for {stem}.png")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--strict", action="store_true", help="Treat warnings as errors")
    args = parser.parse_args()

    errors: list[str] = []
    warnings: list[str] = []

    if not SPRITES.is_dir():
        print(f"ERROR: sprites root missing: {SPRITES}", file=sys.stderr)
        return 2

    for rel, size in WAVE1_REQUIRED:
        check_png(rel, size, errors, warnings)

    check_tres_pairs(errors)

    # Soft check: tileset should have ≥16 tiles (1024px+) for Wave 1
    tileset = SPRITES / "tilesets/01_ashen_threshold/tileset.png"
    if tileset.exists():
        with Image.open(tileset) as img:
            tile_count = img.size[0] // 64
            if tile_count < 16:
                warnings.append(f"tileset: only {tile_count} tiles (Wave 1 target 16–24)")

    for w in warnings:
        print(f"WARN  {w}")
    for e in errors:
        print(f"ERROR {e}")

    if args.strict:
        errors.extend(f"(strict) {w}" for w in warnings)

    if errors:
        print(f"\nFAILED — {len(errors)} error(s), {len(warnings)} warning(s)")
        return 1

    print(f"OK — Wave 1 assets present ({len(warnings)} warning(s))")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
