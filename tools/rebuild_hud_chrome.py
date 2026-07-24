#!/usr/bin/env python3.11
"""Rebuild HUD chrome PNGs to match docs/images/screenshot.png UI clusters.

Clean procedural pixel art — avoids muddy AI downscales for small UI icons.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
HUD = ROOT / "godot" / "assets" / "sprites" / "ui" / "hud"
ICONS = ROOT / "godot" / "assets" / "sprites" / "ui" / "icons"

# Screenshot-derived tokens
C_BG = (0x1A, 0x1A, 0x2E, 255)
C_METAL = (0x5A, 0x55, 0x4A, 255)
C_GOLD = (0xC4, 0x9A, 0x4A, 255)
C_GOLD_HI = (0xE8, 0xC8, 0x78, 255)
C_GOLD_LO = (0x8B, 0x62, 0x24, 255)
C_SHADOW = (0x0B, 0x09, 0x0A, 255)
C_HP = (0xE5, 0x38, 0x3B, 255)
C_HP_HI = (0xFF, 0x6B, 0x6B, 255)
C_HP_EMPTY = (0x2C, 0x2C, 0x34, 255)
C_MANA = (0x00, 0xE5, 0xE5, 255)
C_MANA_HI = (0x7A, 0xFF, 0xFF, 255)
C_EMBER = (0xFF, 0x6B, 0x35, 255)
C_EMBER_HI = (0xFF, 0xB0, 0x4A, 255)
C_BONE = (0xE8, 0xE0, 0xD8, 255)
TRANSPARENT = (0, 0, 0, 0)


def save(img: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)
    print(f"  wrote {path.relative_to(ROOT)} {img.size}")


def portrait_frame(size: int = 56) -> Image.Image:
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    d = ImageDraw.Draw(img)
    cx = cy = size // 2
    # Outer spikes (sunburst)
    for i in range(12):
        import math
        ang = i * math.pi * 2 / 12 - math.pi / 2
        # alternate long/short
        r0, r1 = (18, 26) if i % 2 == 0 else (18, 22)
        x0 = cx + int(math.cos(ang) * r0)
        y0 = cy + int(math.sin(ang) * r0)
        x1 = cx + int(math.cos(ang) * r1)
        y1 = cy + int(math.sin(ang) * r1)
        d.line([(x0, y0), (x1, y1)], fill=C_GOLD_LO, width=2)
        d.point((x1, y1), fill=C_GOLD_HI)
    # Rings
    d.ellipse([6, 6, size - 7, size - 7], outline=C_SHADOW, width=3)
    d.ellipse([8, 8, size - 9, size - 9], outline=C_GOLD, width=2)
    d.ellipse([11, 11, size - 12, size - 12], outline=C_GOLD_LO, width=1)
    d.ellipse([13, 13, size - 14, size - 14], outline=C_METAL, width=1)
    # Inner dark well (transparent center for sigil)
    return img


def ember_sun_sigil(size: int = 32) -> Image.Image:
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    d = ImageDraw.Draw(img)
    cx = cy = size // 2
    import math
    for i in range(8):
        ang = i * math.pi / 4
        x1 = cx + int(math.cos(ang) * 13)
        y1 = cy + int(math.sin(ang) * 13)
        d.line([(cx, cy), (x1, y1)], fill=C_EMBER, width=2)
    d.ellipse([cx - 8, cy - 8, cx + 8, cy + 8], outline=C_EMBER_HI, width=2)
    d.ellipse([cx - 5, cy - 5, cx + 5, cy + 5], outline=C_EMBER, width=1)
    d.ellipse([cx - 2, cy - 2, cx + 2, cy + 2], fill=C_EMBER_HI)
    return img


def hp_pip(filled: bool, w: int = 12, h: int = 14) -> Image.Image:
    img = Image.new("RGBA", (w, h), TRANSPARENT)
    d = ImageDraw.Draw(img)
    # Diamond polygon
    pts = [(w // 2, 1), (w - 2, h // 2), (w // 2, h - 2), (1, h // 2)]
    if filled:
        d.polygon(pts, fill=C_HP)
        d.line([pts[0], pts[1]], fill=C_HP_HI, width=1)
        d.polygon(pts, outline=C_SHADOW)
    else:
        d.polygon(pts, fill=C_HP_EMPTY)
        d.polygon(pts, outline=C_METAL)
    return img


def mana_bar_bg(w: int = 140, h: int = 16) -> Image.Image:
    img = Image.new("RGBA", (w, h), TRANSPARENT)
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, w - 1, h - 1], radius=2, fill=C_BG, outline=C_GOLD_LO, width=1)
    d.rounded_rectangle([1, 1, w - 2, h - 2], radius=2, outline=C_METAL, width=1)
    # Inner trough
    d.rectangle([8, 4, w - 9, h - 5], fill=C_SHADOW)
    return img


def mana_bar_fill(w: int = 8, h: int = 8) -> Image.Image:
    img = Image.new("RGBA", (w, h), TRANSPARENT)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, w - 1, h - 1], fill=C_MANA)
    d.line([(0, 0), (w - 1, 0)], fill=C_MANA_HI)
    return img


def overcast_edge(w: int = 140, h: int = 4) -> Image.Image:
    img = Image.new("RGBA", (w, h), TRANSPARENT)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, w - 1, h - 1], fill=(0xE5, 0x38, 0x3B, 200))
    return img


def minimap_frame(size: int = 72) -> Image.Image:
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    d = ImageDraw.Draw(img)
    # Thin ornate rect — center transparent
    d.rectangle([0, 0, size - 1, size - 1], outline=C_GOLD_LO, width=2)
    d.rectangle([2, 2, size - 3, size - 3], outline=C_METAL, width=1)
    # Corner ticks
    for x, y in [(3, 3), (size - 8, 3), (3, size - 8), (size - 8, size - 8)]:
        d.rectangle([x, y, x + 4, y + 4], outline=C_GOLD, width=1)
    return img


def player_marker(size: int = 8) -> Image.Image:
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    d = ImageDraw.Draw(img)
    pts = [(size // 2, 0), (size - 1, size // 2), (size // 2, size - 1), (0, size // 2)]
    d.polygon(pts, fill=C_BONE)
    return img


def spell_slot(active: bool = False, size: int = 40) -> Image.Image:
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    d = ImageDraw.Draw(img)
    border = C_EMBER if active else C_GOLD_LO
    d.rectangle([0, 0, size - 1, size - 1], fill=C_BG, outline=border, width=2 if active else 1)
    d.rectangle([3, 3, size - 4, size - 4], outline=C_METAL, width=1)
    if active:
        d.rectangle([1, 1, size - 2, size - 2], outline=C_EMBER_HI, width=1)
    return img


def skull_icon(size: int = 16) -> Image.Image:
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    d = ImageDraw.Draw(img)
    d.ellipse([2, 1, size - 3, size - 5], fill=C_BONE, outline=C_SHADOW)
    d.ellipse([4, 5, 7, 8], fill=C_SHADOW)  # eyes
    d.ellipse([size - 8, 5, size - 5, 8], fill=C_SHADOW)
    d.rectangle([6, size - 6, size - 7, size - 3], fill=C_BONE)
    d.point((size // 2, 10), fill=C_SHADOW)
    return img


def currency_endcap(size: int = 28) -> Image.Image:
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    d = ImageDraw.Draw(img)
    cx = cy = size // 2
    d.ellipse([2, 2, size - 3, size - 3], outline=C_GOLD_LO, width=2)
    d.ellipse([5, 5, size - 6, size - 6], outline=C_GOLD, width=1)
    d.ellipse([8, 8, size - 9, size - 9], fill=C_METAL, outline=C_GOLD_HI)
    # tiny ember gem center
    d.ellipse([cx - 3, cy - 3, cx + 3, cy + 3], fill=C_EMBER)
    return img


def compass_icon(size: int = 12) -> Image.Image:
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    d = ImageDraw.Draw(img)
    cx = cy = size // 2
    d.line([(cx, 1), (cx, size - 2)], fill=C_GOLD, width=1)
    d.line([(1, cy), (size - 2, cy)], fill=C_GOLD_LO, width=1)
    d.polygon([(cx, 1), (cx + 2, cy), (cx, cy - 1), (cx - 2, cy)], fill=C_EMBER)
    return img


def shard_icon(size: int = 16) -> Image.Image:
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    d = ImageDraw.Draw(img)
    pts = [(size // 2, 1), (size - 2, size // 2), (size // 2, size - 2), (2, size // 2)]
    d.polygon(pts, fill=C_EMBER)
    d.line([pts[0], pts[1]], fill=C_EMBER_HI, width=1)
    return img


def ember_bolt_icon(size: int = 48) -> Image.Image:
    img = Image.new("RGBA", (size, size), TRANSPARENT)
    d = ImageDraw.Draw(img)
    # Flaming spearhead / shard pointing right-up
    d.polygon([(8, size - 10), (size - 10, 8), (size - 14, 14), (14, size - 8)], fill=C_EMBER)
    d.polygon([(size - 10, 8), (size - 6, 12), (size - 14, 14)], fill=C_EMBER_HI)
    d.ellipse([6, size - 16, 16, size - 6], fill=C_EMBER_HI)
    return img


def main() -> int:
    print("Rebuilding screenshot-matched HUD chrome...")
    save(portrait_frame(56), HUD / "ui_hud_portrait_frame.png")
    save(ember_sun_sigil(32), ICONS / "ui_spell_icon_ember_sigil.png")
    save(hp_pip(True), HUD / "ui_hud_hp_pip_filled.png")
    save(hp_pip(False), HUD / "ui_hud_hp_pip_empty.png")
    save(mana_bar_bg(), HUD / "ui_hud_mana_bar_bg.png")
    save(mana_bar_fill(), HUD / "ui_hud_mana_bar_fill.png")
    save(overcast_edge(), HUD / "ui_hud_overcast_edge.png")
    save(minimap_frame(72), HUD / "ui_hud_minimap_frame.png")
    save(player_marker(8), HUD / "ui_hud_player_marker.png")
    save(spell_slot(False, 40), HUD / "ui_hud_spell_slot.png")
    save(spell_slot(True, 40), HUD / "ui_hud_spell_slot_active.png")
    save(skull_icon(16), HUD / "ui_hud_skull_icon.png")
    save(currency_endcap(28), HUD / "ui_hud_currency_endcap.png")
    save(compass_icon(12), HUD / "ui_hud_compass_icon.png")
    save(shard_icon(16), HUD / "ui_hud_shard_icon.png")
    save(ember_bolt_icon(48), ICONS / "ui_spell_icon_ember_bolt.png")
    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
