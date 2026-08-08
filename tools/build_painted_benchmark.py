#!/usr/bin/env python3.11
"""Build the painted-realism East Road benchmark from approved AI sources."""

from __future__ import annotations

import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
BATCH = ROOT / "docs" / "art-batches" / "painted_realism"
SOURCE = BATCH / "source"
PROCESSED = BATCH / "processed"
SPRITES = ROOT / "godot" / "assets" / "sprites"
MANIFEST = json.loads((BATCH / "manifest.json").read_text(encoding="utf-8"))


def split_grid(image: Image.Image, columns: int, rows: int) -> list[Image.Image]:
	cell_width = image.width // columns
	cell_height = image.height // rows
	return [
		image.crop((column * cell_width, row * cell_height, (column + 1) * cell_width, (row + 1) * cell_height))
		for row in range(rows)
		for column in range(columns)
	]


def fit_subject(image: Image.Image, size: int, subject_height: int, baseline: int) -> Image.Image:
	image = image.convert("RGBA")
	bounds = image.getchannel("A").getbbox()
	if bounds is None:
		raise ValueError("source cell is empty")
	trimmed = image.crop(bounds)
	scale = min(subject_height / trimmed.height, (size - 12) / trimmed.width)
	new_size = (max(1, round(trimmed.width * scale)), max(1, round(trimmed.height * scale)))
	resized = trimmed.resize(new_size, Image.Resampling.LANCZOS)
	result = Image.new("RGBA", (size, size), (0, 0, 0, 0))
	x = (size - resized.width) // 2
	y = baseline - resized.height
	result.alpha_composite(resized, (x, y))
	return result


def fit_platform(image: Image.Image) -> Image.Image:
	image = image.convert("RGBA")
	bounds = image.getchannel("A").getbbox()
	if bounds is None:
		raise ValueError("platform source cell is empty")
	trimmed = image.crop(bounds)
	scale = 128 / trimmed.width
	resized = trimmed.resize((128, min(128, round(trimmed.height * scale))), Image.Resampling.LANCZOS)
	result = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
	result.alpha_composite(resized, (0, 124 - resized.height))
	return result


def fit_layer(image: Image.Image, size: tuple[int, int], cover: bool) -> Image.Image:
	image = image.convert("RGBA")
	scale = max(size[0] / image.width, size[1] / image.height) if cover else min(size[0] / image.width, size[1] / image.height)
	resized = image.resize((round(image.width * scale), round(image.height * scale)), Image.Resampling.LANCZOS)
	result = Image.new("RGBA", size, (0, 0, 0, 0))
	result.alpha_composite(resized, ((size[0] - resized.width) // 2, (size[1] - resized.height) // 2))
	return result


def black_to_alpha(image: Image.Image) -> Image.Image:
	image = image.convert("RGBA")
	pixels = []
	for red, green, blue, _alpha in image.get_flattened_data():
		alpha = max(red, green, blue)
		pixels.append((red, green, blue, alpha))
	image.putdata(pixels)
	return image


def save(image: Image.Image, path: Path) -> None:
	path.parent.mkdir(parents=True, exist_ok=True)
	image.save(path)
	print(f"wrote {path.relative_to(ROOT)} {image.size}")


def sprite_frames_text(texture_path: str, animations: list[tuple[str, list[tuple[int, int]], int, bool]], cell_size: int) -> str:
	frame_count = sum(len(frames) for _name, frames, _fps, _loop in animations)
	lines = [
		f'[gd_resource type="SpriteFrames" load_steps={frame_count + 2} format=3]',
		"",
		f'[ext_resource type="Texture2D" path="{texture_path}" id="1_tex"]',
		"",
	]
	resource_id = 1
	animation_resources: list[tuple[str, list[int], int, bool]] = []
	for name, frames, fps, loop in animations:
		ids = []
		for column, row in frames:
			ids.append(resource_id)
			lines.extend([
				f'[sub_resource type="AtlasTexture" id="AtlasTexture_{resource_id}"]',
				'atlas = ExtResource("1_tex")',
				f"region = Rect2({column * cell_size}, {row * cell_size}, {cell_size}, {cell_size})",
				"",
			])
			resource_id += 1
		animation_resources.append((name, ids, fps, loop))
	lines.extend(["[resource]", "animations = ["])
	for index, (name, ids, fps, loop) in enumerate(animation_resources):
		frames = ", ".join(f'{{"duration": 1.0, "texture": SubResource("AtlasTexture_{resource_id}")}}' for resource_id in ids)
		lines.extend([
			"{",
			f'"frames": [{frames}],',
			f'"loop": {str(loop).lower()},',
			f'"name": &"{name}",',
			f'"speed": {float(fps):.1f}',
			"}" + ("," if index < len(animation_resources) - 1 else ""),
		])
	lines.extend(["]", ""])
	return "\n".join(lines)


def build_player() -> None:
	locomotion = split_grid(Image.open(PROCESSED / "elara_locomotion_rgba.png"), 4, 3)
	combat = split_grid(Image.open(PROCESSED / "elara_combat_rgba.png"), 4, 3)
	sources = {"locomotion": locomotion, "combat": combat}
	animations = MANIFEST["player"]["animations"]
	cell_size = MANIFEST["player"]["cell_size"]
	atlas = Image.new("RGBA", (cell_size * 8, cell_size * len(animations)), (0, 0, 0, 0))
	resource_animations = []
	for row, (name, animation) in enumerate(animations.items()):
		frames = []
		for column, source_index in enumerate(animation["frames"]):
			cell = fit_subject(sources[animation["source"]][source_index], cell_size, 224, 248)
			atlas.alpha_composite(cell, (column * cell_size, row * cell_size))
			frames.append((column, row))
		resource_animations.append((name, frames, animation["fps"], animation["loop"]))
	path = SPRITES / "player" / "elara_core.png"
	save(atlas, path)
	resource = sprite_frames_text("res://assets/sprites/player/elara_core.png", resource_animations, cell_size)
	(path.with_suffix(".tres")).write_text(resource, encoding="utf-8")


def build_enemy(name: str, source_row: int, subject_height: int) -> None:
	source_cells = split_grid(Image.open(PROCESSED / "east_road_enemies_rgba.png"), 4, 3)
	cells = source_cells[source_row * 4 : source_row * 4 + 4]
	sequences = {"idle": [0, 1, 2, 1], "walk": [0, 1, 2, 3, 2, 1]}
	cell_size = 128
	atlas = Image.new("RGBA", (cell_size * 6, cell_size * 2), (0, 0, 0, 0))
	resource_animations = []
	for row, (animation_name, sequence) in enumerate(sequences.items()):
		frames = []
		for column, source_index in enumerate(sequence):
			cell = fit_subject(cells[source_index], cell_size, subject_height, 122)
			atlas.alpha_composite(cell, (column * cell_size, row * cell_size))
			frames.append((column, row))
		resource_animations.append((animation_name, frames, 8 if animation_name == "idle" else 10, True))
	directory = SPRITES / "enemies" / name
	path = directory / f"{name}_sheet.png"
	save(atlas, path)
	resource_path = f"res://assets/sprites/enemies/{name}/{name}_sheet.png"
	path.with_suffix(".tres").write_text(sprite_frames_text(resource_path, resource_animations, cell_size), encoding="utf-8")


def build_environment() -> None:
	target_size = (1536, 540)
	layers = [
		(Image.open(SOURCE / "ashen_sky.png"), "parallax_0_sky.png", True),
		(Image.open(PROCESSED / "ashen_far_ruins_rgba.png"), "parallax_1_far_ruins.png", False),
		(Image.open(PROCESSED / "ashen_mid_architecture_rgba.png"), "parallax_2_mid_architecture.png", False),
		(black_to_alpha(Image.open(SOURCE / "ashen_fog_black.png")), "parallax_3_mid_fog.png", True),
		(Image.open(PROCESSED / "ashen_foreground_rgba.png"), "parallax_4_near_occluders.png", False),
	]
	base = SPRITES / "tilesets" / "01_ashen_threshold"
	for image, name, cover in layers:
		save(fit_layer(image, target_size, cover), base / name)

	platform_cells = split_grid(Image.open(PROCESSED / "ashen_platform_kit_rgba.png"), 4, 2)
	atlas = Image.new("RGBA", (512, 256), (0, 0, 0, 0))
	for index, source_cell in enumerate(platform_cells):
		cell = fit_platform(source_cell)
		atlas.alpha_composite(cell, ((index % 4) * 128, (index // 4) * 128))
	save(atlas, base / "painted_platform_kit.png")


def build_vfx() -> None:
	cells = split_grid(black_to_alpha(Image.open(SOURCE / "combat_vfx_black.png")), 4, 2)
	for name, source_indices, frame_count in [
		("vfx_ember_sigil.png", [3, 4], 8),
		("vfx_ember_bolt.png", [5], 6),
		("vfx_veil_step.png", [6], 8),
	]:
		strip = Image.new("RGBA", (128 * frame_count, 128), (0, 0, 0, 0))
		for frame in range(frame_count):
			cell = fit_subject(cells[source_indices[frame % len(source_indices)]], 128, 112, 120)
			strip.alpha_composite(cell, (frame * 128, 0))
		save(strip, SPRITES / "vfx" / "spells" / name)

	barrier = black_to_alpha(Image.open(SOURCE / "phase_barrier_black.png"))
	bounds = barrier.getchannel("A").getbbox()
	if bounds is None:
		raise ValueError("phase barrier source is empty")
	trimmed = barrier.crop(bounds)
	scale = min(116 / trimmed.width, 240 / trimmed.height)
	resized = trimmed.resize((round(trimmed.width * scale), round(trimmed.height * scale)), Image.Resampling.LANCZOS)
	canvas = Image.new("RGBA", (128, 256), (0, 0, 0, 0))
	canvas.alpha_composite(resized, ((128 - resized.width) // 2, (256 - resized.height) // 2))
	save(canvas, SPRITES / "world" / "world_phase_barrier.png")


def build_hud() -> None:
	cells = split_grid(Image.open(PROCESSED / "hud_rgba.png"), 4, 2)
	outputs = [
		("ui_hud_portrait_frame.png", (96, 96), 0),
		("ui_hud_hp_pip_filled.png", (18, 22), 1),
		("ui_hud_hp_pip_empty.png", (18, 22), 2),
		("ui_hud_mana_bar_bg.png", (176, 28), 3),
		("ui_hud_spell_slot.png", (56, 56), 4),
		("ui_hud_spell_slot_active.png", (56, 56), 4),
		("ui_hud_minimap_frame.png", (176, 104), 6),
		("ui_hud_currency_endcap.png", (176, 36), 7),
	]
	base = SPRITES / "ui" / "hud"
	for name, size, source_index in outputs:
		trimmed = cells[source_index].crop(cells[source_index].getchannel("A").getbbox())
		trimmed.thumbnail(size, Image.Resampling.LANCZOS)
		canvas = Image.new("RGBA", size, (0, 0, 0, 0))
		canvas.alpha_composite(trimmed, ((size[0] - trimmed.width) // 2, (size[1] - trimmed.height) // 2))
		save(canvas, base / name)


def validate_outputs() -> None:
	player = Image.open(SPRITES / "player" / "elara_core.png").convert("RGBA")
	if player.size != (2048, 2560):
		raise ValueError(f"unexpected player atlas size {player.size}")
	for row in range(10):
		for column in range(8):
			cell = player.crop((column * 256, row * 256, (column + 1) * 256, (row + 1) * 256))
			bounds = cell.getchannel("A").getbbox()
			if bounds is None:
				continue
			height_ratio = (bounds[3] - bounds[1]) / 256
			if not 0.55 <= height_ratio <= 0.94:
				raise ValueError(f"player cell {row}:{column} height ratio {height_ratio:.2f}")
	for path in (PROCESSED / "elara_locomotion_rgba.png", PROCESSED / "elara_combat_rgba.png"):
		image = Image.open(path).convert("RGBA")
		for corner in ((0, 0), (image.width - 1, 0), (0, image.height - 1), (image.width - 1, image.height - 1)):
			if image.getpixel(corner)[3] > MANIFEST["quality"]["transparent_corner_alpha"]:
				raise ValueError(f"non-transparent corner in {path.name}")
	print("painted benchmark quality gates passed")


def main() -> None:
	build_player()
	build_enemy("e03_bramble_stalker", 0, 116)
	build_enemy("e15_thornweft_larva", 1, 100)
	build_enemy("e07_mothling_swarm", 2, 108)
	build_environment()
	build_vfx()
	build_hud()
	validate_outputs()


if __name__ == "__main__":
	main()
