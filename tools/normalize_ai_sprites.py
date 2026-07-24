#!/usr/bin/env python3.11
"""Normalize Cursor AI generations into locked Godot sprite sizes/sheets.

Staging: docs/art-batches/incoming/
Final:   godot/assets/sprites/

Usage:
  python3.11 tools/normalize_ai_sprites.py
  python3.11 tools/normalize_ai_sprites.py --dry-run
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
INCOMING = ROOT / "docs" / "art-batches" / "incoming"
SPRITES = ROOT / "godot" / "assets" / "sprites"

# Exact final sizes for single-image assets
RESIZE_MAP: dict[str, tuple[int, int]] = {
    "parallax_0_sky.png": (960, 540),
    "parallax_1_far_ruins.png": (960, 540),
    "parallax_2_mid_architecture.png": (960, 540),
    "parallax_3_mid_fog.png": (960, 540),
    "parallax_4_near_occluders.png": (960, 540),
    "elara_portrait_48.png": (48, 48),
    "ui_hud_portrait_frame.png": (56, 56),
    "ui_hud_hp_pip_filled.png": (12, 14),
    "ui_hud_hp_pip_empty.png": (12, 14),
    "ui_hud_mana_bar_bg.png": (140, 16),
    "ui_hud_mana_bar_fill.png": (8, 8),
    "ui_hud_spell_slot.png": (40, 40),
    "ui_hud_spell_slot_active.png": (40, 40),
    "ui_hud_shard_icon.png": (16, 16),
    "ui_hud_skull_icon.png": (16, 16),
    "ui_hud_currency_endcap.png": (32, 32),
    "ui_hud_minimap_frame.png": (72, 72),
    "ui_hud_player_marker.png": (8, 8),
    "ui_hud_compass_icon.png": (12, 12),
    "ui_hud_overcast_edge.png": (140, 4),
    "vignette_overlay.png": (960, 540),
}

# Destination relative to SPRITES for known staging filenames
DEST_MAP: dict[str, str] = {
    "parallax_0_sky.png": "tilesets/01_ashen_threshold/parallax_0_sky.png",
    "parallax_1_far_ruins.png": "tilesets/01_ashen_threshold/parallax_1_far_ruins.png",
    "parallax_2_mid_architecture.png": "tilesets/01_ashen_threshold/parallax_2_mid_architecture.png",
    "parallax_3_mid_fog.png": "tilesets/01_ashen_threshold/parallax_3_mid_fog.png",
    "parallax_4_near_occluders.png": "tilesets/01_ashen_threshold/parallax_4_near_occluders.png",
    "tileset.png": "tilesets/01_ashen_threshold/tileset.png",
    "props.png": "tilesets/01_ashen_threshold/props.png",
    "elara_core.png": "player/elara_core.png",
    "elara_portrait_48.png": "player/elara_portrait_48.png",
    "e01_sheet.png": "enemies/e01_ash_wisp/e01_sheet.png",
    "e02_sheet.png": "enemies/e02_bone_crawler/e02_sheet.png",
    "e03_sheet.png": "enemies/e03_bramble_stalker/e03_sheet.png",
    "e04_sheet.png": "enemies/e04_ember_moth/e04_sheet.png",
    "e08_sheet.png": "enemies/e08_threshold_shade/e08_sheet.png",
    "vfx_ember_sigil.png": "vfx/spells/vfx_ember_sigil.png",
    "vfx_ember_bolt.png": "vfx/spells/vfx_ember_bolt.png",
    "ui_hud_portrait_frame.png": "ui/hud/ui_hud_portrait_frame.png",
    "ui_hud_hp_pip_filled.png": "ui/hud/ui_hud_hp_pip_filled.png",
    "ui_hud_hp_pip_empty.png": "ui/hud/ui_hud_hp_pip_empty.png",
    "ui_hud_mana_bar_bg.png": "ui/hud/ui_hud_mana_bar_bg.png",
    "ui_hud_mana_bar_fill.png": "ui/hud/ui_hud_mana_bar_fill.png",
    "ui_hud_spell_slot.png": "ui/hud/ui_hud_spell_slot.png",
    "ui_hud_spell_slot_active.png": "ui/hud/ui_hud_spell_slot_active.png",
    "ui_hud_shard_icon.png": "ui/hud/ui_hud_shard_icon.png",
    "ui_hud_skull_icon.png": "ui/hud/ui_hud_skull_icon.png",
    "ui_hud_currency_endcap.png": "ui/hud/ui_hud_currency_endcap.png",
    "ui_hud_minimap_frame.png": "ui/hud/ui_hud_minimap_frame.png",
    "ui_hud_player_marker.png": "ui/hud/ui_hud_player_marker.png",
    "ui_hud_compass_icon.png": "ui/hud/ui_hud_compass_icon.png",
    "ui_hud_overcast_edge.png": "ui/hud/ui_hud_overcast_edge.png",
    "vignette_overlay.png": "ui/vignette_overlay.png",
}

# Sheet assembly: folder of frames → atlas
# Elara rows match elara_core.tres
ELARA_ROWS: list[tuple[str, int]] = [
    ("idle", 8),
    ("walk", 8),
    ("jump", 6),
    ("fall", 4),
    ("dash", 6),
    ("melee_1", 6),
    ("melee_2", 6),
    ("melee_3", 6),
    ("cast", 6),
    ("hit", 4),
]

ENEMY_SHEETS: dict[str, list[tuple[str, int]]] = {
    "e01": [("idle", 4)],
    "e02": [("walk", 6)],
    "e03": [("idle", 4), ("walk", 6)],
    "e04": [("idle", 4)],
    "e08": [("idle", 4)],
}


def nearest_resize(img: Image.Image, size: tuple[int, int]) -> Image.Image:
    return img.convert("RGBA").resize(size, Image.Resampling.NEAREST)


def fit_on_canvas(src: Image.Image, cell: tuple[int, int], feet_y: int | None = None) -> Image.Image:
    """Scale subject to fit cell, place feet near bottom-center."""
    cell_w, cell_h = cell
    src = src.convert("RGBA")
    # Trim transparent margins
    bbox = src.getbbox()
    if bbox:
        src = src.crop(bbox)
    # Leave 2px margin
    max_w, max_h = cell_w - 4, cell_h - 4
    scale = min(max_w / src.width, max_h / src.height, 1.0)
    # Prefer downscaling AI gens that are too large
    if src.width > max_w or src.height > max_h:
        scale = min(max_w / src.width, max_h / src.height)
    new_w = max(1, int(src.width * scale))
    new_h = max(1, int(src.height * scale))
    # Pixel-art: if still huge, force to ~56px body height
    if new_h > 56 and cell_h == 64:
        scale2 = 56 / new_h
        new_w = max(1, int(new_w * scale2))
        new_h = 56
    resized = src.resize((new_w, new_h), Image.Resampling.LANCZOS)
    # Optional second nearest pass for crisp pixels when near target size
    if cell_w <= 128:
        # Quantize soft edges via slight nearest after lanczos for game scale
        pass
    canvas = Image.new("RGBA", cell, (0, 0, 0, 0))
    x = (cell_w - new_w) // 2
    if feet_y is None:
        y = cell_h - new_h - 2
    else:
        y = feet_y - new_h
    y = max(0, min(y, cell_h - new_h))
    canvas.paste(resized, (x, y), resized)
    return canvas


def pack_sheet(
    frame_paths: list[Path],
    cell: tuple[int, int],
    cols: int,
    feet_pivot: bool = True,
) -> Image.Image:
    rows = (len(frame_paths) + cols - 1) // cols
    sheet = Image.new("RGBA", (cols * cell[0], rows * cell[1]), (0, 0, 0, 0))
    for i, path in enumerate(frame_paths):
        with Image.open(path) as im:
            cell_img = fit_on_canvas(im, cell, feet_y=cell[1] - 2 if feet_pivot else None)
        r, c = divmod(i, cols)
        sheet.paste(cell_img, (c * cell[0], r * cell[1]), cell_img)
    return sheet


def assemble_elara(incoming: Path) -> Image.Image | None:
    """Assemble Elara only from complete per-frame PNGs.

    The staged 1536×1024 elara_core.png is not a valid game atlas (cell bleed /
    inconsistent pivots). Do not nearest-resize or remap it into production.
    """
    frames_dir = incoming / "elara_frames"
    if not frames_dir.is_dir():
        return None

    # Require majority of named frames before assembling
    missing = 0
    total = sum(c for _, c in ELARA_ROWS)
    for anim, count in ELARA_ROWS:
        for i in range(count):
            if not any(
                (frames_dir / name).exists()
                for name in (f"{anim}_{i:02d}.png", f"{anim}_{i}.png")
            ):
                missing += 1
    if missing > total // 2:
        return None

    cells: list[Image.Image] = []
    for anim, count in ELARA_ROWS:
        for i in range(count):
            candidates = [
                frames_dir / f"{anim}_{i:02d}.png",
                frames_dir / f"{anim}_{i}.png",
                frames_dir / anim / f"{i:02d}.png",
            ]
            path = next((p for p in candidates if p.exists()), None)
            if path is None:
                fallback = frames_dir / f"{anim}_00.png"
                if not fallback.exists():
                    fallback = frames_dir / "idle_00.png"
                if not fallback.exists():
                    pngs = sorted(frames_dir.glob("*.png"))
                    if not pngs:
                        return None
                    path = pngs[0]
                else:
                    path = fallback
            with Image.open(path) as im:
                cells.append(fit_on_canvas(im, (64, 64), feet_y=62))
    sheet = Image.new("RGBA", (512, 640), (0, 0, 0, 0))
    idx = 0
    for row_i, (anim, count) in enumerate(ELARA_ROWS):
        for col in range(count):
            sheet.paste(cells[idx], (col * 64, row_i * 64), cells[idx])
            idx += 1
    return sheet


def assemble_enemy(incoming: Path, enemy_id: str) -> Image.Image | None:
    layout = ENEMY_SHEETS[enemy_id]
    frames_dir = incoming / f"{enemy_id}_frames"
    sheet_name = f"{enemy_id}_sheet.png"
    if not frames_dir.is_dir():
        path = incoming / sheet_name
        if path.exists():
            with Image.open(path) as im:
                # e03 is 384x128; others single row
                rows = len(layout)
                max_frames = max(c for _, c in layout)
                return nearest_resize(im.convert("RGBA"), (max_frames * 64, rows * 64))
        return None
    max_cols = max(c for _, c in layout)
    sheet = Image.new("RGBA", (max_cols * 64, len(layout) * 64), (0, 0, 0, 0))
    for row_i, (anim, count) in enumerate(layout):
        for col in range(count):
            candidates = [
                frames_dir / f"{anim}_{col:02d}.png",
                frames_dir / f"{anim}_{col}.png",
            ]
            path = next((p for p in candidates if p.exists()), None)
            if path is None:
                pngs = sorted(frames_dir.glob("*.png"))
                path = pngs[min(col, len(pngs) - 1)] if pngs else None
            if path is None:
                continue
            with Image.open(path) as im:
                cell = fit_on_canvas(im, (64, 64), feet_y=62)
            sheet.paste(cell, (col * 64, row_i * 64), cell)
    return sheet


def copy_resized(src: Path, dest: Path, size: tuple[int, int] | None, dry_run: bool) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    with Image.open(src) as im:
        out = im.convert("RGBA")
        if size:
            out = nearest_resize(out, size)
        elif dest.name == "tileset.png":
            # Force height 64, width multiple of 64
            h = 64
            w = max(64, (out.width * h // out.height + 63) // 64 * 64)
            w = min(w, 1024)
            out = nearest_resize(out, (w, h))
        elif dest.name == "props.png":
            out = nearest_resize(out, (512, 128))
        elif dest.name.startswith("vfx_"):
            # Keep 128 cell strips if close; else scale height to 128
            if out.height != 128:
                frames = max(1, out.width // max(out.height, 1))
                out = nearest_resize(out, (frames * 128, 128))
    if dry_run:
        print(f"  would write {dest.relative_to(ROOT)} ({out.size})")
        return
    out.save(dest)
    print(f"  wrote {dest.relative_to(ROOT)} ({out.size})")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--incoming", type=Path, default=INCOMING)
    args = parser.parse_args()
    incoming: Path = args.incoming
    if not incoming.is_dir():
        print(f"No incoming dir: {incoming}", file=sys.stderr)
        return 1

    print(f"Normalizing from {incoming.relative_to(ROOT)} ...")

    # Assemble Elara if frames present
    elara = assemble_elara(incoming)
    if elara is not None:
        dest = SPRITES / "player" / "elara_core.png"
        if args.dry_run:
            print(f"  would write {dest.relative_to(ROOT)} ({elara.size})")
        else:
            dest.parent.mkdir(parents=True, exist_ok=True)
            elara.save(dest)
            print(f"  wrote {dest.relative_to(ROOT)} ({elara.size})")

    for eid in ENEMY_SHEETS:
        sheet = assemble_enemy(incoming, eid)
        if sheet is None:
            continue
        dest = SPRITES / DEST_MAP[f"{eid}_sheet.png"]
        if args.dry_run:
            print(f"  would write {dest.relative_to(ROOT)} ({sheet.size})")
        else:
            dest.parent.mkdir(parents=True, exist_ok=True)
            sheet.save(dest)
            print(f"  wrote {dest.relative_to(ROOT)} ({sheet.size})")

    # Single-file copies
    for name, rel in DEST_MAP.items():
        if name == "elara_core.png" or name.endswith("_sheet.png"):
            continue  # handled above when assembled; also allow direct copy below
        src = incoming / name
        if not src.exists():
            continue
        # Skip if we already assembled sheets from frames
        if name == "elara_core.png" and elara is not None:
            continue
        size = RESIZE_MAP.get(name)
        copy_resized(src, SPRITES / rel, size, args.dry_run)

    # Direct sheet drops when not already assembled above
    for name in ("elara_core.png", "e01_sheet.png", "e02_sheet.png", "e03_sheet.png", "e04_sheet.png", "e08_sheet.png"):
        src = incoming / name
        if not src.exists():
            continue
        if name == "elara_core.png" and elara is not None:
            continue
        eid = name[:3]
        if name != "elara_core.png" and (incoming / f"{eid}_frames").is_dir():
            continue
        rel = DEST_MAP[name]
        if name == "elara_core.png":
            # Never import unaligned 1536×1024 AI sheet via naive resize.
            with Image.open(src) as im:
                if im.size != (512, 640):
                    print(f"  skip {name}: expected 512x640 game atlas, got {im.size}")
                    continue
            size = (512, 640)
        elif name == "e03_sheet.png":
            size = (384, 128)
        elif name == "e02_sheet.png":
            size = (384, 64)
        else:
            size = (256, 64)
        copy_resized(src, SPRITES / rel, size, args.dry_run)

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
