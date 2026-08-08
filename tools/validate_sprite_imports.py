#!/usr/bin/env python3.11
"""Validate the painted-realism East Road benchmark assets."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SPRITES = ROOT / "godot" / "assets" / "sprites"
MANIFEST_PATH = ROOT / "docs" / "art-batches" / "painted_realism" / "manifest.json"

REQUIRED: list[tuple[str, tuple[int, int]]] = [
	("player/elara_core.png", (2048, 2560)),
	("enemies/e03_bramble_stalker/e03_bramble_stalker_sheet.png", (768, 256)),
	("enemies/e15_thornweft_larva/e15_thornweft_larva_sheet.png", (768, 256)),
	("enemies/e07_mothling_swarm/e07_mothling_swarm_sheet.png", (768, 256)),
	("tilesets/01_ashen_threshold/parallax_0_sky.png", (1536, 540)),
	("tilesets/01_ashen_threshold/parallax_1_far_ruins.png", (1536, 540)),
	("tilesets/01_ashen_threshold/parallax_2_mid_architecture.png", (1536, 540)),
	("tilesets/01_ashen_threshold/parallax_3_mid_fog.png", (1536, 540)),
	("tilesets/01_ashen_threshold/parallax_4_near_occluders.png", (1536, 540)),
	("tilesets/01_ashen_threshold/painted_platform_kit.png", (512, 256)),
	("vfx/spells/vfx_ember_sigil.png", (1024, 128)),
	("vfx/spells/vfx_ember_bolt.png", (768, 128)),
	("vfx/spells/vfx_veil_step.png", (1024, 128)),
	("world/world_phase_barrier.png", (128, 256)),
	("ui/hud/ui_hud_portrait_frame.png", (96, 96)),
	("ui/hud/ui_hud_minimap_frame.png", (176, 104)),
]

SPRITE_FRAME_STEMS = [
	"player/elara_core",
	"enemies/e03_bramble_stalker/e03_bramble_stalker_sheet",
	"enemies/e15_thornweft_larva/e15_thornweft_larva_sheet",
	"enemies/e07_mothling_swarm/e07_mothling_swarm_sheet",
	"vfx/spells/vfx_ember_sigil",
	"vfx/spells/vfx_ember_bolt",
]


def check_png(relative_path: str, expected_size: tuple[int, int], errors: list[str]) -> None:
	path = SPRITES / relative_path
	if not path.exists():
		errors.append(f"missing: {relative_path}")
		return
	try:
		with Image.open(path) as image:
			if image.size != expected_size:
				errors.append(
					f"size: {relative_path} is {image.width}x{image.height}, "
					f"expected {expected_size[0]}x{expected_size[1]}"
				)
			if image.mode not in ("RGB", "RGBA"):
				errors.append(f"mode: {relative_path} is {image.mode}, expected RGB or RGBA")
	except OSError as exception:
		errors.append(f"unreadable: {relative_path} ({exception})")


def check_player_cells(manifest: dict, errors: list[str]) -> None:
	path = SPRITES / "player" / "elara_core.png"
	if not path.exists():
		return
	cell_size = int(manifest["player"]["cell_size"])
	minimum = float(manifest["quality"]["min_subject_height_ratio"])
	maximum = float(manifest["quality"]["max_subject_height_ratio"])
	with Image.open(path) as source:
		image = source.convert("RGBA")
		for row, animation in enumerate(manifest["player"]["animations"].values()):
			for column in range(len(animation["frames"])):
				cell = image.crop((
					column * cell_size,
					row * cell_size,
					(column + 1) * cell_size,
					(row + 1) * cell_size,
				))
				bounds = cell.getchannel("A").getbbox()
				if bounds is None:
					errors.append(f"empty player cell: row {row}, column {column}")
					continue
				height_ratio = (bounds[3] - bounds[1]) / cell_size
				if not minimum <= height_ratio <= maximum:
					errors.append(
					f"player cell {row}:{column} height ratio {height_ratio:.2f}, "
					f"expected {minimum:.2f}-{maximum:.2f}"
				)


def main() -> int:
	parser = argparse.ArgumentParser(description=__doc__)
	parser.add_argument("--strict", action="store_true", help="Retained for CI compatibility")
	parser.parse_args()

	errors: list[str] = []
	if not MANIFEST_PATH.exists():
		print(f"ERROR missing manifest: {MANIFEST_PATH.relative_to(ROOT)}")
		return 2
	manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))

	for relative_path, expected_size in REQUIRED:
		check_png(relative_path, expected_size, errors)
	for stem in SPRITE_FRAME_STEMS:
		if not (SPRITES / f"{stem}.tres").exists():
			errors.append(f"missing SpriteFrames: {stem}.tres")
	check_player_cells(manifest, errors)

	for error in errors:
		print(f"ERROR {error}")
	if errors:
		print(f"\nFAILED — {len(errors)} error(s)")
		return 1
	print(f"OK — painted benchmark assets passed ({len(REQUIRED)} PNGs)")
	return 0


if __name__ == "__main__":
	raise SystemExit(main())
