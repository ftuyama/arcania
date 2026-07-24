#!/usr/bin/env python3.11
"""Build production sprites from Cursor AI staging images.

Pixelizes / palette-quantizes AI art into locked Godot sizes and assembles
animation sheets from hero key art when full frame sets are incomplete.
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
INCOMING = ROOT / "docs" / "art-batches" / "incoming"
CURSOR_ASSETS = Path.home() / ".cursor" / "projects" / "Users-felipe-tuyama-arcania" / "assets"
SPRITES = ROOT / "godot" / "assets" / "sprites"

ASHEN = [
    (0x1A, 0x1A, 0x2E),
    (0x2C, 0x2C, 0x34),
    (0x4A, 0x4E, 0x69),
    (0x8B, 0x45, 0x13),
    (0xFF, 0x6B, 0x35),
    (0x3D, 0x2A, 0x4A),  # muted purple sky
    (0x6B, 0x5A, 0x78),
    (0xC4, 0x5A, 0x2E),  # ember mid
    (0xE8, 0xE0, 0xD8),  # bone highlight
    (0x0B, 0x09, 0x0A),  # near black
]


def nearest_color(rgb: tuple[int, int, int], palette: list[tuple[int, int, int]]) -> tuple[int, int, int]:
    r, g, b = rgb
    best, best_d = palette[0], 1e18
    for pr, pg, pb in palette:
        d = (r - pr) ** 2 + (g - pg) ** 2 + (b - pb) ** 2
        if d < best_d:
            best, best_d = (pr, pg, pb), d
    return best


def pixelize(img: Image.Image, target: tuple[int, int], palette: bool = True) -> Image.Image:
    """Downscale with LANCZOS. Mild adaptive quantize (96 colors) — never 10-color crush."""
    img = img.convert("RGBA")
    small = img.resize(target, Image.Resampling.LANCZOS)
    if palette:
        alpha = small.split()[-1]
        q = small.convert("RGB").quantize(colors=96, method=Image.Quantize.MEDIANCUT)
        small = q.convert("RGBA")
        small.putalpha(alpha)
    return small


def quantize_rgba(img: Image.Image, palette: list[tuple[int, int, int]] | None = None, alpha_cut: int = 40) -> Image.Image:
    """Legacy name — now mild adaptive, ignores hardcoded ASHEN table."""
    img = img.convert("RGBA")
    alpha = img.split()[-1]
    # Soft alpha cut
    px = alpha.load()
    w, h = alpha.size
    for y in range(h):
        for x in range(w):
            if px[x, y] < alpha_cut:
                px[x, y] = 0
    q = img.convert("RGB").quantize(colors=64, method=Image.Quantize.MEDIANCUT)
    out = q.convert("RGBA")
    out.putalpha(alpha)
    return out

def remove_near_black_bg(img: Image.Image, thresh: int = 28) -> Image.Image:
    img = img.convert("RGBA")
    px = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if r <= thresh and g <= thresh and b <= thresh:
                px[x, y] = (0, 0, 0, 0)
            # Knock out cream/white AI frame panels
            elif r > 180 and g > 170 and b > 140 and abs(r - g) < 45:
                px[x, y] = (0, 0, 0, 0)
            elif r > 200 and g > 200 and b > 200:
                px[x, y] = (0, 0, 0, 0)
    return img


def trim(img: Image.Image, pad: int = 2) -> Image.Image:
    bbox = img.getbbox()
    if not bbox:
        return img
    l, t, r, b = bbox
    l = max(0, l - pad)
    t = max(0, t - pad)
    r = min(img.width, r + pad)
    b = min(img.height, b + pad)
    return img.crop((l, t, r, b))


def fit_feet(img: Image.Image, cell: tuple[int, int] = (64, 64), body_h: int = 56) -> Image.Image:
    img = trim(img)
    if img.height == 0 or img.width == 0:
        return Image.new("RGBA", cell, (0, 0, 0, 0))
    scale = body_h / img.height
    nw = max(1, int(img.width * scale))
    nh = body_h
    if nw > cell[0] - 4:
        scale = (cell[0] - 4) / img.width
        nw = cell[0] - 4
        nh = max(1, int(img.height * scale))
    resized = img.resize((nw, nh), Image.Resampling.LANCZOS)
    resized = quantize_rgba(resized)
    canvas = Image.new("RGBA", cell, (0, 0, 0, 0))
    x = (cell[0] - nw) // 2
    y = cell[1] - nh - 2
    canvas.paste(resized, (x, y), resized)
    return canvas


def load_ai(name: str) -> Image.Image | None:
    for base in (INCOMING, CURSOR_ASSETS):
        path = base / name
        if path.exists():
            return Image.open(path).convert("RGBA")
    return None


def wobble(img: Image.Image, dx: int, dy: int, squash: float = 1.0) -> Image.Image:
    """Simple animation variant."""
    w, h = img.size
    nh = max(1, int(h * squash))
    nw = max(1, int(w / squash))
    scaled = img.resize((nw, nh), Image.Resampling.NEAREST)
    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    x = (w - nw) // 2 + dx
    y = h - nh + dy
    canvas.paste(scaled, (x, y), scaled)
    return canvas


def build_elara_sheet(hero: Image.Image, idle: Image.Image | None = None) -> Image.Image:
    hero = remove_near_black_bg(hero)
    hero = trim(hero)
    idle_src = trim(remove_near_black_bg(idle)) if idle is not None else hero

    idle_cell = fit_feet(idle_src)
    cast_cell = fit_feet(hero)
    # Walk / action bases: slight crops of hero without oversized sigil emphasis —
    # use idle for locomotion, cast for spell row.
    base = idle_cell
    cast = cast_cell

    rows: list[list[Image.Image]] = []
    # idle 8
    rows.append([wobble(base, 0, -(i % 2), 1.0 + (i % 3) * 0.01) for i in range(8)])
    # walk 8
    walk = []
    for i in range(8):
        phase = math.sin(i / 8 * math.pi * 2)
        walk.append(wobble(base, int(phase * 2), -abs(int(phase)), 0.96 + abs(phase) * 0.06))
    rows.append(walk)
    # jump 6
    rows.append([wobble(base, 0, -4 - i, 0.92 + i * 0.01) for i in range(6)])
    # fall 4
    rows.append([wobble(base, 0, -2 + i, 1.05) for i in range(4)])
    # dash 6
    rows.append([wobble(base, 3 + i, -1, 0.85) for i in range(6)])
    # melee x3
    for _ in range(3):
        rows.append([wobble(base, i, -1, 0.95 + (i % 2) * 0.05) for i in range(6)])
    # cast 6 — blend toward cast pose
    cast_row = []
    for i in range(6):
        t = i / 5
        # cross-dissolve idle→cast
        a = base.copy()
        c = cast.copy()
        # simple: early frames idle, later cast
        cast_row.append(c if t > 0.35 else wobble(base, i // 2, -1, 1.0))
    rows.append(cast_row)
    # hit 4
    rows.append([wobble(base, -2 - i, 0, 1.1) for i in range(4)])

    sheet = Image.new("RGBA", (512, 640), (0, 0, 0, 0))
    for ri, row in enumerate(rows):
        for ci, cell in enumerate(row):
            sheet.paste(cell, (ci * 64, ri * 64), cell)
    return sheet


def slice_strip_to_sheet(src: Image.Image, frame_count: int, cell: tuple[int, int] = (64, 64), rows: int = 1) -> Image.Image:
    src = remove_near_black_bg(src)
    # Assume horizontal strip (or grid)
    if rows == 1:
        fw = src.width // frame_count
        fh = src.height
        out = Image.new("RGBA", (frame_count * cell[0], cell[1]), (0, 0, 0, 0))
        for i in range(frame_count):
            frame = src.crop((i * fw, 0, (i + 1) * fw, fh))
            out.paste(fit_feet(frame, cell), (i * cell[0], 0), fit_feet(frame, cell))
        return out
    # 2-row e03 style
    max_frames = frame_count
    out = Image.new("RGBA", (max_frames * cell[0], rows * cell[1]), (0, 0, 0, 0))
    rh = src.height // rows
    counts = [4, 6] if rows == 2 else [frame_count]
    for r, count in enumerate(counts):
        fw = src.width // count
        for i in range(count):
            frame = src.crop((i * fw, r * rh, (i + 1) * fw, (r + 1) * rh))
            cell_img = fit_feet(frame, cell)
            out.paste(cell_img, (i * cell[0], r * cell[1]), cell_img)
    return out


def save(img: Image.Image, rel: str) -> None:
    path = SPRITES / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)
    print(f"  wrote {rel} {img.size}")


def process_parallax(name: str, dest: str) -> None:
    img = load_ai(name)
    if img is None:
        print(f"  skip missing {name}")
        return
    out = pixelize(img, (960, 540), palette=True)
    save(out, dest)


def process_tileset() -> None:
    img = load_ai("tileset.png")
    if img is None:
        return
    # Crop to stone ledge band if full scene
    out = pixelize(img, (1024, 64), palette=True)
    save(out, "tilesets/01_ashen_threshold/tileset.png")


def process_props() -> None:
    img = load_ai("props.png")
    if img is None:
        return
    out = pixelize(img, (192, 64), palette=True)
    save(out, "tilesets/01_ashen_threshold/props.png")


def hud_pixel(name: str, dest: str, size: tuple[int, int]) -> None:
    img = load_ai(name)
    if img is None:
        print(f"  skip missing {name}")
        return
    img = remove_near_black_bg(img)
    img = trim(img)
    out = pixelize(img, size, palette=True)
    save(out, dest)


def grid_cells(img: Image.Image, cols: int, rows: int) -> list[Image.Image]:
    img = remove_near_black_bg(img)
    cw, ch = img.width // cols, img.height // rows
    cells = []
    for r in range(rows):
        for c in range(cols):
            cells.append(img.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch)))
    return cells


def vfx_strip(src: Image.Image, frames: int, cell: int = 128) -> Image.Image:
    src = remove_near_black_bg(src)
    src = trim(src)
    out = Image.new("RGBA", (frames * cell, cell), (0, 0, 0, 0))
    fw = max(1, src.width // frames)
    for i in range(frames):
        frame = src.crop((i * fw, 0, min(src.width, (i + 1) * fw), src.height)) if src.width >= frames * 8 else src
        fitted = pixelize(trim(frame), (cell, cell), palette=True)
        out.paste(fitted, (i * cell, 0), fitted)
    return out


def sync_cursor_assets() -> None:
    """Copy newest Cursor-generated PNGs into incoming staging."""
    if not CURSOR_ASSETS.is_dir():
        return
    INCOMING.mkdir(parents=True, exist_ok=True)
    for path in CURSOR_ASSETS.glob("*.png"):
        if path.name.startswith("image-"):
            continue
        dest = INCOMING / path.name
        dest.write_bytes(path.read_bytes())


def main() -> int:
    INCOMING.mkdir(parents=True, exist_ok=True)
    sync_cursor_assets()
    print("Building AI → Godot sprites...")

    # Ashen environment
    process_parallax("parallax_0_sky.png", "tilesets/01_ashen_threshold/parallax_0_sky.png")
    process_parallax("parallax_1_far_ruins.png", "tilesets/01_ashen_threshold/parallax_1_far_ruins.png")
    process_parallax("parallax_2_mid_architecture.png", "tilesets/01_ashen_threshold/parallax_2_mid_architecture.png")
    process_parallax("parallax_3_mid_fog.png", "tilesets/01_ashen_threshold/parallax_3_mid_fog.png")
    process_parallax("parallax_4_near_occluders.png", "tilesets/01_ashen_threshold/parallax_4_near_occluders.png")
    process_tileset()
    process_props()

    # Whisperwood parallax
    ww = [
        ("ww_parallax_0_sky.png", "tilesets/02_whisperwood_hollow/parallax_0_sky.png"),
        ("ww_parallax_1_far_trees.png", "tilesets/02_whisperwood_hollow/parallax_1_far_trees.png"),
        ("ww_parallax_2_mid_canopy.png", "tilesets/02_whisperwood_hollow/parallax_2_mid_canopy.png"),
        ("ww_parallax_3_spore_fog.png", "tilesets/02_whisperwood_hollow/parallax_3_spore_fog.png"),
    ]
    for src, dest in ww:
        process_parallax(src, dest)

    # Elara
    cast = load_ai("elara_cast_hero.png") or load_ai("elara_frames/cast_00.png")
    idle = load_ai("elara_idle_stand.png")
    if cast is not None:
        idle_char = None
        if idle is not None:
            w, h = idle.size
            idle_char = idle.crop((int(w * 0.25), int(h * 0.15), int(w * 0.62), int(h * 0.85)))
            idle_char = remove_near_black_bg(idle_char, thresh=40)
        sheet = build_elara_sheet(cast, idle_char)
        save(sheet, "player/elara_core.png")
        portrait = fit_feet(trim(remove_near_black_bg(cast)), (48, 48), body_h=44)
        save(portrait, "player/elara_portrait_48.png")
    else:
        print("  WARN: no Elara cast hero")

    # Enemies
    for name, dest, frames, rows in [
        ("e01_sheet.png", "enemies/e01_ash_wisp/e01_sheet.png", 4, 1),
        ("e02_sheet.png", "enemies/e02_bone_crawler/e02_sheet.png", 6, 1),
        ("e03_sheet.png", "enemies/e03_bramble_stalker/e03_sheet.png", 6, 2),
        ("e04_sheet.png", "enemies/e04_ember_moth/e04_sheet.png", 4, 1),
        ("e08_sheet.png", "enemies/e08_threshold_shade/e08_sheet.png", 4, 1),
    ]:
        img = load_ai(name)
        if img is None:
            print(f"  skip missing {name}")
            continue
        save(slice_strip_to_sheet(img, frames, rows=rows), dest)

    # Bosses — keep existing atlas dimensions
    for name, dest, size in [
        ("boss_01_sheet.png", "bosses/boss_01_root_warden/boss_01_sheet.png", (576, 480)),
        ("mb_01_sheet.png", "bosses/mb_01_thornweft_matron/mb_01_sheet.png", (576, 384)),
    ]:
        img = load_ai(name)
        if img is None:
            print(f"  skip missing {name}")
            continue
        save(pixelize(remove_near_black_bg(img), size, palette=True), dest)

    # NPC
    npc = load_ai("npc_magister_corin.png")
    if npc is not None:
        cell = fit_feet(trim(remove_near_black_bg(npc)), (64, 64))
        sheet = Image.new("RGBA", (256, 64), (0, 0, 0, 0))
        for i in range(4):
            sheet.paste(wobble(cell, 0, -(i % 2)), (i * 64, 0), wobble(cell, 0, -(i % 2)))
        save(sheet, "npcs/npc_magister_corin.png")

    # VFX — individual + pack rows
    for name, dest, frames in [
        ("vfx_ember_sigil.png", "vfx/spells/vfx_ember_sigil.png", 8),
        ("vfx_ember_bolt.png", "vfx/spells/vfx_ember_bolt.png", 6),
    ]:
        img = load_ai(name)
        if img is not None:
            save(vfx_strip(img, frames), dest)

    pack = load_ai("vfx_spells_pack.png")
    if pack is not None:
        # 2x3 grid of spell VFX cards → use as single-frame strips expanded
        cells = grid_cells(pack, 3, 2)
        vfx_names = [
            ("vfx_veil_step.png", 8),
            ("vfx_rootbind.png", 8),
            ("vfx_arc_step.png", 8),
            ("vfx_rune_anchor.png", 10),
            ("vfx_ember_sigil.png", 8),
            ("vfx_ember_bolt.png", 6),
        ]
        for cell, (fname, frames) in zip(cells, vfx_names):
            strip = Image.new("RGBA", (frames * 128, 128), (0, 0, 0, 0))
            base = pixelize(trim(cell), (128, 128), palette=True)
            for i in range(frames):
                variant = wobble(base, (i % 3) - 1, 0, 0.95 + (i % 4) * 0.02)
                strip.paste(variant, (i * 128, 0), variant)
            save(strip, f"vfx/spells/{fname}")

    # HUD singles
    hud_pixel("ui_hud_portrait_frame.png", "ui/hud/ui_hud_portrait_frame.png", (56, 56))
    hud_pixel("ui_hud_hp_pip_filled.png", "ui/hud/ui_hud_hp_pip_filled.png", (12, 14))
    hud_pixel("ui_hud_hp_pip_empty.png", "ui/hud/ui_hud_hp_pip_empty.png", (12, 14))
    hud_pixel("ui_hud_spell_slot.png", "ui/hud/ui_hud_spell_slot.png", (40, 40))
    hud_pixel("ui_hud_spell_slot.png", "ui/hud/ui_hud_spell_slot_active.png", (40, 40))
    hud_pixel("ui_hud_skull_icon.png", "ui/hud/ui_hud_skull_icon.png", (16, 16))
    hud_pixel("ui_hud_minimap_frame.png", "ui/hud/ui_hud_minimap_frame.png", (72, 72))
    # Mana bar → bg + fill
    mana = load_ai("ui_hud_mana_bar.png")
    if mana is not None:
        mana = trim(remove_near_black_bg(mana))
        save(pixelize(mana, (140, 16), palette=True), "ui/hud/ui_hud_mana_bar_bg.png")
        # Inner fill approximation
        fill = mana.crop((int(mana.width * 0.05), int(mana.height * 0.25), int(mana.width * 0.95), int(mana.height * 0.75)))
        save(pixelize(fill, (8, 8), palette=True), "ui/hud/ui_hud_mana_bar_fill.png")
        save(pixelize(mana.crop((0, mana.height - 4, mana.width, mana.height)), (140, 4), palette=True), "ui/hud/ui_hud_overcast_edge.png")

    misc = load_ai("ui_hud_misc_pack.png")
    if misc is not None:
        cells = grid_cells(misc, 3, 2)
        mapping = [
            ("ui/hud/ui_hud_player_marker.png", (8, 8)),
            ("ui/hud/ui_hud_compass_icon.png", (12, 12)),
            ("ui/hud/ui_hud_currency_endcap.png", (32, 32)),
            ("ui/hud/ui_hud_shard_icon.png", (16, 16)),
            ("ui/hud/ui_hud_overcast_edge.png", (140, 4)),
        ]
        for cell, (dest, size) in zip(cells, mapping):
            save(pixelize(trim(cell), size, palette=True), dest)

    vig = load_ai("vignette_overlay.png")
    if vig is not None:
        # Keep soft alpha — lighter palette pass
        out = vig.convert("RGBA").resize((960, 540), Image.Resampling.LANCZOS)
        save(out, "ui/vignette_overlay.png")

    # Spell icons 3x2
    spell_pack = load_ai("ui_spell_icons_pack.png")
    if spell_pack is not None:
        names = [
            "ui_spell_icon_ember_sigil.png",
            "ui_spell_icon_ember_bolt.png",
            "ui_spell_icon_veil_step.png",
            "ui_spell_icon_rootbind.png",
            "ui_spell_icon_arc_step.png",
            "ui_spell_icon_rune_anchor.png",
        ]
        for cell, name in zip(grid_cells(spell_pack, 3, 2), names):
            save(pixelize(trim(remove_near_black_bg(cell)), (48, 48), palette=True), f"ui/icons/{name}")

    relic_pack = load_ai("ui_relic_icons_pack.png")
    if relic_pack is not None:
        names = [
            "ui_relic_icon_cinder_heart.png",
            "ui_relic_icon_frost_nail.png",
            "ui_relic_icon_gloom_lens.png",
            "ui_relic_icon_iron_grip.png",
            "ui_relic_icon_mist_walker.png",
            "ui_relic_icon_thornseed_charm.png",
        ]
        for cell, name in zip(grid_cells(relic_pack, 3, 2), names):
            save(pixelize(trim(remove_near_black_bg(cell)), (48, 48), palette=True), f"ui/icons/{name}")

    # World props
    for name, dest, size in [
        ("world_focus_crucible.png", "world/world_focus_crucible.png", (32, 48)),
        ("world_brazier_gate.png", "world/world_brazier_gate.png", (32, 96)),
    ]:
        img = load_ai(name)
        if img is not None:
            save(pixelize(trim(remove_near_black_bg(img)), size, palette=True), dest)

    wpack = load_ai("world_props_pack.png")
    if wpack is not None:
        cells = grid_cells(wpack, 3, 1)
        mapping = [
            ("world/world_pickup_glow.png", (36, 36)),
            ("world/world_vine_gate.png", (32, 128)),
            ("world/world_anchor_point.png", (24, 24)),
        ]
        for cell, (dest, size) in zip(cells, mapping):
            save(pixelize(trim(remove_near_black_bg(cell)), size, palette=True), dest)

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
