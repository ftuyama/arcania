#!/usr/bin/env python3.11
"""High-fidelity rebuild: AI/screenshot sources → Godot without crushing to 9 colors.

Root cause of muddy look: previous build quantized every pixel to a 10-color
Ashen table. This pass keeps LANCZOS resize + mild adaptive quantize (48–96
colors) and proper alpha keying for layered parallax.
"""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
INCOMING = ROOT / "docs" / "art-batches" / "incoming"
CURSOR = Path.home() / ".cursor" / "projects" / "Users-felipe-tuyama-arcania" / "assets"
SPRITES = ROOT / "godot" / "assets" / "sprites"
SHOT = ROOT / "docs" / "images" / "screenshot.png"


def load(name: str) -> Image.Image | None:
    for base in (INCOMING, CURSOR):
        p = base / name
        if p.exists():
            return Image.open(p).convert("RGBA")
    return None


def save(img: Image.Image, rel: str) -> None:
    path = SPRITES / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)
    # unique opaque colors for QA
    colors = {(r, g, b) for r, g, b, a in img.getdata() if a > 20}
    print(f"  {rel} {img.size} colors≈{len(colors)}")


def resize_hq(img: Image.Image, size: tuple[int, int], max_colors: int | None = 96) -> Image.Image:
    """Resize preserving detail. Optional mild adaptive palette (NOT 10-color crush)."""
    img = img.convert("RGBA")
    out = img.resize(size, Image.Resampling.LANCZOS)
    if max_colors and max_colors > 0:
        # Quantize RGB only, restore alpha
        alpha = out.split()[-1]
        q = out.convert("RGB").quantize(colors=max_colors, method=Image.Quantize.MEDIANCUT)
        out = q.convert("RGBA")
        out.putalpha(alpha)
    return out


def knock_light_bg(img: Image.Image, luma_cut: int = 210, sat_cut: int = 35) -> Image.Image:
    """Make near-white / flat studio backgrounds transparent (parallax layers)."""
    img = img.convert("RGBA")
    px = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 8:
                continue
            mx, mn = max(r, g, b), min(r, g, b)
            if mx >= luma_cut and (mx - mn) <= sat_cut:
                px[x, y] = (0, 0, 0, 0)
            # cream panels
            elif r > 175 and g > 165 and b > 140 and abs(r - g) < 40:
                px[x, y] = (0, 0, 0, 0)
    return img


def knock_near_black(img: Image.Image, thresh: int = 18) -> Image.Image:
    """Key pure black only — never use on dark-robed characters (eats silhouette)."""
    img = img.convert("RGBA")
    px = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a > 0 and r <= thresh and g <= thresh and b <= thresh:
                px[x, y] = (0, 0, 0, 0)
    return img


def trim(img: Image.Image, pad: int = 1) -> Image.Image:
    bbox = img.getbbox()
    if not bbox:
        return img
    l, t, r, b = bbox
    return img.crop((max(0, l - pad), max(0, t - pad), min(img.width, r + pad), min(img.height, b + pad)))


def fit_subject(
    img: Image.Image,
    cell: tuple[int, int] = (64, 64),
    body_h: int = 54,
    *,
    key_black: bool = False,
) -> Image.Image:
    """Fit character into cell. Do NOT key near-black for dark robes."""
    img = knock_light_bg(img)
    if key_black:
        img = knock_near_black(img, thresh=8)
    img = trim(img)
    if img.width < 2 or img.height < 2:
        return Image.new("RGBA", cell, (0, 0, 0, 0))
    scale = body_h / img.height
    nw = max(1, int(img.width * scale))
    nh = body_h
    if nw > cell[0] - 2:
        scale = (cell[0] - 2) / img.width
        nw = cell[0] - 2
        nh = max(1, int(img.height * scale))
    resized = resize_hq(img, (nw, nh), max_colors=64)
    canvas = Image.new("RGBA", cell, (0, 0, 0, 0))
    x = (cell[0] - nw) // 2
    y = cell[1] - nh - 2
    canvas.paste(resized, (x, max(0, y)), resized)
    return canvas


def wobble(img: Image.Image, dx: int = 0, dy: int = 0, squash: float = 1.0) -> Image.Image:
    w, h = img.size
    nh = max(1, int(h * squash))
    nw = max(1, int(w / max(squash, 0.01)))
    scaled = img.resize((nw, nh), Image.Resampling.NEAREST)
    canvas = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    canvas.paste(scaled, ((w - nw) // 2 + dx, h - nh + dy), scaled)
    return canvas


def build_elara() -> None:
    """Prefer adjusted idle + cast heroes; never knock_near_black on robes."""
    idle_src = load("elara_idle_stand.png") or load("elara_idle_hero.png") or load("elara_cast_hero.png")
    cast_src = load("elara_cast_hero.png") or idle_src
    if idle_src is None:
        print("  WARN: missing Elara source art")
        return

    idle_cell = fit_subject(idle_src, body_h=54, key_black=False)
    cast_cell = fit_subject(cast_src, body_h=54, key_black=False)

    rows: list[list[Image.Image]] = []
    # Gentle idle bob — no artificial shredding
    rows.append([wobble(idle_cell, 0, -(i % 2), 1.0) for i in range(8)])
    walk = []
    for i in range(8):
        phase = math.sin(i / 8 * math.pi * 2)
        walk.append(wobble(idle_cell, int(phase * 1.5), 0, 1.0))
    rows.append(walk)
    rows.append([wobble(idle_cell, 0, -2 - i // 2, 0.98) for i in range(6)])
    rows.append([wobble(idle_cell, 0, i // 2, 1.02) for i in range(4)])
    rows.append([wobble(idle_cell, 1 + i // 2, 0, 0.96) for i in range(6)])
    for _ in range(3):
        rows.append([wobble(idle_cell, min(i, 2), 0, 1.0) for i in range(6)])
    rows.append([cast_cell if i >= 2 else idle_cell for i in range(6)])
    rows.append([wobble(idle_cell, -1, 0, 1.0) for i in range(4)])

    sheet = Image.new("RGBA", (512, 640), (0, 0, 0, 0))
    for ri, row in enumerate(rows):
        for ci, cell in enumerate(row):
            sheet.paste(cell, (ci * 64, ri * 64), cell)
    save(sheet, "player/elara_core.png")
    save(fit_subject(cast_src, (48, 48), body_h=42, key_black=False), "player/elara_portrait_48.png")


def _matte_purple_bg(img: Image.Image) -> Image.Image:
    """Unused legacy helper kept for reference."""
    return img


def knock_flat_backdrop(img: Image.Image, tol: int = 18) -> Image.Image:
    """Make flat studio/sky fill transparent using corner sample (parallax mid layers)."""
    img = img.convert("RGBA")
    px = img.load()
    w, h = img.size
    samples = [px[0, 0], px[w - 1, 0], px[0, h - 1], px[w - 1, h - 1], px[w // 2, 0]]
    # Pick darkest corner as backdrop ref (sky/void)
    ref = min(samples, key=lambda c: c[0] + c[1] + c[2])
    rr, gg, bb, _ = ref
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a < 8:
                continue
            if abs(r - rr) <= tol and abs(g - gg) <= tol and abs(b - bb) <= tol:
                # Keep warm ember accents even if near corners
                if r > 140 and g < 120:
                    continue
                px[x, y] = (0, 0, 0, 0)
    return img


def build_parallax() -> None:
    layers = [
        ("parallax_0_sky.png", "tilesets/01_ashen_threshold/parallax_0_sky.png", False, 128),
        ("parallax_1_far_ruins.png", "tilesets/01_ashen_threshold/parallax_1_far_ruins.png", True, 96),
        ("parallax_2_mid_architecture.png", "tilesets/01_ashen_threshold/parallax_2_mid_architecture.png", True, 96),
        ("parallax_3_mid_fog.png", "tilesets/01_ashen_threshold/parallax_3_mid_fog.png", True, 64),
        ("parallax_4_near_occluders.png", "tilesets/01_ashen_threshold/parallax_4_near_occluders.png", True, 96),
        ("ww_parallax_0_sky.png", "tilesets/02_whisperwood_hollow/parallax_0_sky.png", False, 128),
        ("ww_parallax_1_far_trees.png", "tilesets/02_whisperwood_hollow/parallax_1_far_trees.png", True, 96),
        ("ww_parallax_2_mid_canopy.png", "tilesets/02_whisperwood_hollow/parallax_2_mid_canopy.png", True, 96),
        ("ww_parallax_3_spore_fog.png", "tilesets/02_whisperwood_hollow/parallax_3_spore_fog.png", True, 64),
    ]
    for src, dest, key_bg, colors in layers:
        img = load(src)
        if img is None:
            print(f"  skip {src}")
            continue
        if key_bg:
            img = knock_light_bg(img, luma_cut=200, sat_cut=40)
            img = knock_flat_backdrop(img, tol=22)
        out = resize_hq(img, (960, 540), max_colors=colors)
        if "fog" in src or "spore" in src:
            out = _soft_fog_alpha(out)
        # Sky must stay fully opaque
        if not key_bg:
            out = out.convert("RGBA")
            px = out.load()
            for y in range(out.height):
                for x in range(out.width):
                    r, g, b, a = px[x, y]
                    if a < 255:
                        px[x, y] = (r, g, b, 255)
        save(out, dest)


def _soft_fog_alpha(img: Image.Image) -> Image.Image:
    img = img.convert("RGBA")
    px = img.load()
    w, h = img.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            luma = int(0.3 * r + 0.59 * g + 0.11 * b)
            # Keep ember particles opaque; fade empty dark
            if r > 180 and g < 140:
                continue
            na = max(0, min(200, int(a * (0.15 + luma / 255.0 * 0.85))))
            px[x, y] = (r, g, b, na)
    return img


def build_tileset_from_screenshot() -> None:
    """Prefer AI stone texture; fall back to screenshot ledge samples."""
    stone = load("tileset_clean.png") or load("tileset_stone_adjusted.png") or load("tileset_v2.png")
    tileset = Image.new("RGBA", (1024, 64), (0, 0, 0, 0))
    if stone is not None:
        # Slice overlapping 64px windows from the AI stone strip
        stone = stone.convert("RGBA")
        sh = min(stone.height, max(64, stone.height // 2))
        band = stone.crop((0, stone.height - sh, stone.width, stone.height))
        for i in range(16):
            x0 = int(i * max(1, band.width - 64) / 15)
            patch = band.crop((x0, 0, min(band.width, x0 + max(64, band.width // 8)), band.height))
            tile = resize_hq(patch, (64, 64), max_colors=72)
            tileset.paste(tile, (i * 64, 0))
        save(tileset, "tilesets/01_ashen_threshold/tileset.png")
    else:
        shot = Image.open(SHOT).convert("RGBA")
        w, h = shot.size
        y0, y1 = int(h * 0.70), int(h * 0.80)
        ledge = shot.crop((0, y0, w, y1))
        for i in range(16):
            x0 = int(i * (ledge.width - 70) / 15)
            patch = ledge.crop((x0, 0, x0 + 70, ledge.height))
            tile = resize_hq(patch.resize((64, 64), Image.Resampling.LANCZOS), (64, 64), max_colors=64)
            tileset.paste(tile, (i * 64, 0))
        save(tileset, "tilesets/01_ashen_threshold/tileset.png")

    props = load("props.png")
    if props is not None:
        save(resize_hq(knock_light_bg(props), (192, 64), max_colors=72), "tilesets/01_ashen_threshold/props.png")
    else:
        shot = Image.open(SHOT).convert("RGBA")
        w, h = shot.size
        props = shot.crop((int(w * 0.01), int(h * 0.30), int(w * 0.24), int(h * 0.78)))
        save(resize_hq(props, (192, 64), max_colors=64), "tilesets/01_ashen_threshold/props.png")


def build_enemies() -> None:
    specs = [
        ("e01_sheet.png", "enemies/e01_ash_wisp/e01_sheet.png", 4, 1),
        ("e02_sheet.png", "enemies/e02_bone_crawler/e02_sheet.png", 6, 1),
        ("e03_sheet.png", "enemies/e03_bramble_stalker/e03_sheet.png", 6, 2),
        ("e04_sheet.png", "enemies/e04_ember_moth/e04_sheet.png", 4, 1),
        ("e08_sheet.png", "enemies/e08_threshold_shade/e08_sheet.png", 4, 1),
    ]
    for src, dest, frames, rows in specs:
        img = load(src)
        if img is None:
            continue
        img = knock_light_bg(img)
        # Soft key only for pure black studio voids — keep dark enemy bodies
        img = knock_near_black(img, thresh=8)
        max_cols = frames
        out = Image.new("RGBA", (max_cols * 64, rows * 64), (0, 0, 0, 0))
        counts = [4, 6] if rows == 2 else [frames]
        for ri, count in enumerate(counts):
            rh = img.height // rows
            fw = max(1, img.width // count)
            for i in range(count):
                frame = img.crop((i * fw, ri * rh, min(img.width, (i + 1) * fw), (ri + 1) * rh))
                cell = fit_subject(frame, body_h=48 if "wisp" in dest or "moth" in dest else 52, key_black=False)
                out.paste(cell, (i * 64, ri * 64), cell)
        save(out, dest)


def build_vfx_hud_rest() -> None:
    # Ember VFX from adjusted single-entity art — one glyph per frame (subtle pulse only).
    for src, dest, frames in [
        ("vfx_ember_sigil.png", "vfx/spells/vfx_ember_sigil.png", 8),
        ("vfx_ember_bolt.png", "vfx/spells/vfx_ember_bolt.png", 6),
    ]:
        img = load(src)
        if img is None:
            continue
        img = knock_light_bg(img, luma_cut=220, sat_cut=40)
        base = resize_hq(trim(img), (112, 112), max_colors=72)
        strip = Image.new("RGBA", (frames * 128, 128), (0, 0, 0, 0))
        for i in range(frames):
            cell = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
            pulse = 1.0 + 0.04 * math.sin(i * 0.9)
            nw = max(1, int(112 * pulse))
            nh = max(1, int(112 * pulse))
            frame = base.resize((nw, nh), Image.Resampling.NEAREST)
            cell.paste(frame, ((128 - nw) // 2, (128 - nh) // 2), frame)
            strip.paste(cell, (i * 128, 0), cell)
        save(strip, dest)

    pack = load("vfx_spells_pack.png")
    if pack is not None:
        pack = knock_light_bg(pack)
        cw, ch = pack.width // 3, pack.height // 2
        # Other spells only — do not overwrite adjusted ember bolt/sigil
        names = [
            ("vfx/spells/vfx_veil_step.png", 8),
            ("vfx/spells/vfx_rootbind.png", 8),
            ("vfx/spells/vfx_arc_step.png", 8),
            ("vfx/spells/vfx_rune_anchor.png", 10),
        ]
        idx = 0
        for r in range(2):
            for c in range(3):
                if idx >= len(names):
                    break
                cell = pack.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
                dest, frames = names[idx]
                base = resize_hq(trim(knock_light_bg(cell)), (120, 120), max_colors=64)
                strip = Image.new("RGBA", (frames * 128, 128), (0, 0, 0, 0))
                for i in range(frames):
                    frame = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
                    frame.paste(base, (4, 4), base)
                    strip.paste(frame, (i * 128, 0), frame)
                save(strip, dest)
                idx += 1

    # Bosses / NPC — full color resize
    for src, dest, size in [
        ("boss_01_sheet.png", "bosses/boss_01_root_warden/boss_01_sheet.png", (576, 480)),
        ("mb_01_sheet.png", "bosses/mb_01_thornweft_matron/mb_01_sheet.png", (576, 384)),
    ]:
        img = load(src)
        if img is not None:
            save(resize_hq(knock_light_bg(img), size, max_colors=96), dest)

    npc = load("npc_magister_corin.png")
    if npc is not None:
        cell = fit_subject(npc, body_h=54)
        sheet = Image.new("RGBA", (256, 64), (0, 0, 0, 0))
        for i in range(4):
            sheet.paste(wobble(cell, 0, -(i % 2)), (i * 64, 0), wobble(cell, 0, -(i % 2)))
        save(sheet, "npcs/npc_magister_corin.png")

    # HUD — preserve metallic/gold detail
    hud = [
        ("ui_hud_portrait_frame.png", "ui/hud/ui_hud_portrait_frame.png", (56, 56)),
        ("ui_hud_hp_pip_filled.png", "ui/hud/ui_hud_hp_pip_filled.png", (12, 14)),
        ("ui_hud_hp_pip_empty.png", "ui/hud/ui_hud_hp_pip_empty.png", (12, 14)),
        ("ui_hud_spell_slot.png", "ui/hud/ui_hud_spell_slot.png", (40, 40)),
        ("ui_hud_spell_slot.png", "ui/hud/ui_hud_spell_slot_active.png", (40, 40)),
        ("ui_hud_skull_icon.png", "ui/hud/ui_hud_skull_icon.png", (16, 16)),
        ("ui_hud_minimap_frame.png", "ui/hud/ui_hud_minimap_frame.png", (72, 72)),
    ]
    for src, dest, size in hud:
        img = load(src)
        if img is None:
            continue
        img = knock_near_black(knock_light_bg(trim(img)))
        save(resize_hq(img, size, max_colors=48), dest)

    mana = load("ui_hud_mana_bar.png")
    if mana is not None:
        mana = trim(knock_light_bg(mana))
        save(resize_hq(mana, (140, 16), max_colors=32), "ui/hud/ui_hud_mana_bar_bg.png")
        save(resize_hq(mana, (8, 8), max_colors=16), "ui/hud/ui_hud_mana_bar_fill.png")
        save(resize_hq(mana.crop((0, mana.height - 6, mana.width, mana.height)), (140, 4), max_colors=16), "ui/hud/ui_hud_overcast_edge.png")

    misc = load("ui_hud_misc_pack.png")
    if misc is not None:
        misc = knock_light_bg(misc)
        cw, ch = misc.width // 3, misc.height // 2
        mapping = [
            ("ui/hud/ui_hud_player_marker.png", (8, 8)),
            ("ui/hud/ui_hud_compass_icon.png", (12, 12)),
            ("ui/hud/ui_hud_currency_endcap.png", (32, 32)),
            ("ui/hud/ui_hud_shard_icon.png", (16, 16)),
        ]
        i = 0
        for r in range(2):
            for c in range(3):
                if i >= len(mapping):
                    break
                cell = misc.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
                dest, size = mapping[i]
                save(resize_hq(trim(cell), size, max_colors=24), dest)
                i += 1

    vig = load("vignette_overlay.png")
    if vig is not None:
        save(vig.resize((960, 540), Image.Resampling.LANCZOS), "ui/vignette_overlay.png")

    spell_pack = load("ui_spell_icons_pack.png")
    if spell_pack is not None:
        names = [
            "ui_spell_icon_ember_sigil.png",
            "ui_spell_icon_ember_bolt.png",
            "ui_spell_icon_veil_step.png",
            "ui_spell_icon_rootbind.png",
            "ui_spell_icon_arc_step.png",
            "ui_spell_icon_rune_anchor.png",
        ]
        spell_pack = knock_light_bg(spell_pack)
        cw, ch = spell_pack.width // 3, spell_pack.height // 2
        i = 0
        for r in range(2):
            for c in range(3):
                cell = spell_pack.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
                save(resize_hq(trim(cell), (48, 48), max_colors=48), f"ui/icons/{names[i]}")
                i += 1

    relic_pack = load("ui_relic_icons_pack.png")
    if relic_pack is not None:
        names = [
            "ui_relic_icon_cinder_heart.png",
            "ui_relic_icon_frost_nail.png",
            "ui_relic_icon_gloom_lens.png",
            "ui_relic_icon_iron_grip.png",
            "ui_relic_icon_mist_walker.png",
            "ui_relic_icon_thornseed_charm.png",
        ]
        relic_pack = knock_light_bg(relic_pack)
        cw, ch = relic_pack.width // 3, relic_pack.height // 2
        i = 0
        for r in range(2):
            for c in range(3):
                cell = relic_pack.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))
                save(resize_hq(trim(cell), (48, 48), max_colors=48), f"ui/icons/{names[i]}")
                i += 1

    for src, dest, size in [
        ("world_focus_crucible.png", "world/world_focus_crucible.png", (32, 48)),
        ("world_brazier_gate.png", "world/world_brazier_gate.png", (32, 96)),
    ]:
        img = load(src)
        if img is not None:
            save(resize_hq(trim(knock_light_bg(img)), size, max_colors=48), dest)

    wpack = load("world_props_pack.png")
    if wpack is not None:
        wpack = knock_light_bg(wpack)
        cw = wpack.width // 3
        mapping = [
            ("world/world_pickup_glow.png", (36, 36)),
            ("world/world_vine_gate.png", (32, 128)),
            ("world/world_anchor_point.png", (24, 24)),
        ]
        for i, (dest, size) in enumerate(mapping):
            cell = wpack.crop((i * cw, 0, (i + 1) * cw, wpack.height))
            save(resize_hq(trim(cell), size, max_colors=48), dest)


def main() -> int:
    print("HQ rebuild (no 10-color crush)...")
    build_parallax()
    build_tileset_from_screenshot()
    build_elara()
    build_enemies()
    build_vfx_hud_rest()
    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
