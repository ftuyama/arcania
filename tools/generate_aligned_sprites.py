#!/usr/bin/env python3.11
"""Generate hi-bit placeholder sprites aligned to docs/images/screenshot.png.

Interim production art per docs/art-pipeline.md until AI → Aseprite batches land.
Enforces Ashen Threshold 5-color palette + style-lock rules.
"""

from __future__ import annotations

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
GODOT = ROOT / "godot"
ASSETS = GODOT / "assets"

# Ashen Threshold — art-style-lock §1
C_SHADOW = (0x1A, 0x1A, 0x2E, 255)
C_BASE = (0x2C, 0x2C, 0x34, 255)
C_MID = (0x4A, 0x4E, 0x69, 255)
C_WARM = (0x8B, 0x45, 0x13, 255)
C_ACCENT = (0xFF, 0x6B, 0x35, 255)
C_SKIN = (0x9D, 0x8C, 0x98, 255)
C_TRIM = (0xA0, 0x35, 0x18, 255)  # robe lining — warm family
C_TRANSPARENT = (0, 0, 0, 0)

ASHEN_PALETTE = [C_SHADOW, C_BASE, C_MID, C_WARM, C_ACCENT]

# Whisperwood enemies reuse green accents on Ashen canvas when placed in hub tests
C_LEAF = (0x38, 0x59, 0x3D, 255)
C_THORN = (0x22, 0x35, 0x24, 255)
C_VINE = (0x52, 0x78, 0x46, 255)

BAYER_4 = (
    (0, 8, 2, 10),
    (12, 4, 14, 6),
    (3, 11, 1, 9),
    (15, 7, 13, 5),
)


def px(img: Image.Image, x: int, y: int, color: tuple) -> None:
    if 0 <= x < img.width and 0 <= y < img.height:
        img.putpixel((x, y), color)


def blend(a: tuple, b: tuple, t: float) -> tuple[int, ...]:
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(min(len(a), len(b))))


def dither_fill(img: Image.Image, x0: int, y0: int, x1: int, y1: int, c1: tuple, c2: tuple) -> None:
    """Ordered dither — backgrounds/props only."""
    for y in range(y0, y1):
        for x in range(x0, x1):
            t = (BAYER_4[x & 3][y & 3] / 16.0) * 0.55 + 0.225
            rgb = blend(c1[:3], c2[:3], t)
            px(img, x, y, (*rgb, 255))


def write_sprite_frames_tres(
    tex_path: Path,
    out_path: Path,
    regions: dict[str, list[tuple[int, int, int, int]]],
    speeds: dict[str, float],
    loop_anims: set[str] | None = None,
) -> None:
    if loop_anims is None:
        loop_anims = {"idle", "walk", "fall"}
    sub_id = 0
    sub_lines: list[str] = []
    anim_entries: list[str] = []
    for anim_name, rects in regions.items():
        frames = []
        for x, y, w, h in rects:
            sub_id += 1
            sub_lines.extend(
                [
                    f'[sub_resource type="AtlasTexture" id="AtlasTexture_{sub_id}"]',
                    'atlas = ExtResource("1_tex")',
                    f"region = Rect2({x}, {y}, {w}, {h})",
                    "",
                ]
            )
            frames.append(f'{{"duration": 1.0, "texture": SubResource("AtlasTexture_{sub_id}")}}')
        loop = "true" if anim_name in loop_anims else "false"
        speed = speeds.get(anim_name, 10.0)
        anim_entries.append(
            "{\n"
            f'"frames": [{", ".join(frames)}],\n'
            f'"loop": {loop},\n'
            f'"name": &"{anim_name}",\n'
            f'"speed": {speed}\n'
            "}"
        )
    content = (
        "[gd_resource type=\"SpriteFrames\" load_steps="
        + str(1 + sub_id + 1)
        + " format=3]\n\n"
        + f'[ext_resource type="Texture2D" path="res://{tex_path.as_posix()}" id="1_tex"]\n\n'
        + "\n".join(sub_lines)
        + "[resource]\n"
        + "animations = [\n"
        + ",\n".join(anim_entries)
        + "\n]\n"
    )
    out_path.write_text(content)


def ensure_dirs() -> None:
    for rel in (
        "sprites/player",
        "sprites/enemies/e01_ash_wisp",
        "sprites/enemies/e02_bone_crawler",
        "sprites/enemies/e03_bramble_stalker",
        "sprites/enemies/e04_ember_moth",
        "sprites/enemies/e08_threshold_shade",
        "sprites/tilesets/01_ashen_threshold",
        "sprites/vfx/spells",
        "sprites/ui",
        "sprites/npcs",
    ):
        (ASSETS / rel).mkdir(parents=True, exist_ok=True)


# ---------------------------------------------------------------------------
# Elara — hooded mage, ember sigil on left palm (screenshot north star)
# ---------------------------------------------------------------------------


def _draw_ember_sigil(img: Image.Image, cx: int, cy: int, pulse: float) -> None:
    """Filled ember wheel — single solid glyph (not a sparse wireframe)."""
    glow = tuple(int(c * (0.55 + 0.45 * pulse)) for c in C_ACCENT[:3]) + (255,)
    draw = ImageDraw.Draw(img)
    r = 8
    draw.ellipse((cx - r - 2, cy - r - 2, cx + r + 2, cy + r + 2), fill=(*C_ACCENT[:3], 55))
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(*C_WARM[:3], 220), outline=glow, width=2)
    draw.ellipse((cx - 4, cy - 4, cx + 4, cy + 4), fill=C_ACCENT, outline=C_WARM, width=1)
    draw.line((cx - 5, cy, cx + 5, cy), fill=C_TRIM, width=1)
    draw.line((cx, cy - 5, cx, cy + 5), fill=C_TRIM, width=1)


def draw_elara_frame(frame_img: Image.Image, frame: int, anim: str) -> None:
    """Hi-bit Elara — hooded mage, ember sigil brightest character point."""
    draw = ImageDraw.Draw(frame_img)
    ox, oy = 32, 62

    bob = 0
    leg_l = 0
    leg_r = 0
    arm_swing = 0
    robe_flare = 0
    lean = 0
    squash = 1.0
    glow_pulse = 0.55 + 0.45 * math.sin(frame * 0.9)
    sigil_forward = 2

    if anim == "idle":
        bob = int(math.sin(frame * 0.7) * 1.5)
    elif anim == "walk":
        bob = int(math.sin(frame * 1.2) * 2)
        leg_l = int(math.sin(frame * 1.2) * 4)
        leg_r = int(math.sin(frame * 1.2 + math.pi) * 4)
        arm_swing = int(math.sin(frame * 1.2) * 2)
        robe_flare = int(abs(math.sin(frame * 1.2)) * 4)
    elif anim == "jump":
        squash = 1.08 if frame < 2 else 0.94
        leg_l = -4 if frame < 3 else 3
        leg_r = -4 if frame < 3 else 3
    elif anim == "fall":
        leg_l, leg_r, arm_swing = 5, -3, -3
    elif anim == "dash":
        squash, lean, bob, robe_flare = 0.85, -6 - frame, -3, 5 + frame
        sigil_forward = 0
    elif anim.startswith("melee"):
        arm_swing = [-6, -2, 12, 14, 6, 2][min(frame, 5)]
        bob = 2 if frame in (2, 3) else 0
        robe_flare = 4 if frame in (2, 3) else 1
        sigil_forward = 0
    elif anim == "cast":
        arm_swing = [0, 2, 6, 10, 8, 4][min(frame, 5)]
        glow_pulse = 0.75 + 0.25 * math.sin(frame * 1.6)
        sigil_forward = 6 + frame * 2
        bob = -2 if frame in (2, 3) else 0
    elif anim == "hit":
        lean = [-5, -7, -3, -1][min(frame, 3)]
        arm_swing = [3, 5, 1, 0][min(frame, 3)]
        glow_pulse = 0.35

    body_h = int(30 * squash)
    body_top = oy - body_h - 4 - bob
    dx = ox + lean
    hood_tip = body_top - 10
    hem_y = oy - 8 - bob

    # Readability first: mid-tone robe + light rim (shadow≈sky made her look hollow).
    rim = (0x6E, 0x72, 0x8C, 255)
    robe = C_MID
    fold = C_BASE

    draw.polygon(
        [
            (dx - 2, hood_tip),
            (dx + 2, hood_tip),
            (dx + 12, body_top + 8),
            (dx + 13 + robe_flare, hem_y),
            (dx + 11 + robe_flare, oy),
            (dx - 11 - robe_flare, oy),
            (dx - 13 - robe_flare, hem_y),
            (dx - 12, body_top + 8),
        ],
        fill=robe,
        outline=rim,
    )
    # Soft folds — still mid-dark, not sky-matched shadow
    draw.polygon(
        [
            (dx - 7, body_top + 12),
            (dx - 2, body_top + 12),
            (dx - 2, oy - 4),
            (dx - 9, oy - 4),
        ],
        fill=fold,
    )
    draw.polygon(
        [
            (dx + 2, body_top + 12),
            (dx + 7, body_top + 12),
            (dx + 9, oy - 4),
            (dx + 2, oy - 4),
        ],
        fill=(0x58, 0x5C, 0x78, 255),
    )
    # Narrow sash (not a body-cutting stripe)
    draw.rectangle((dx - 8, body_top + 17, dx + 8, body_top + 19), fill=C_WARM)
    # Boots — darker than robe but lighter than sky
    draw.rectangle((dx - 10 + leg_l, oy - 5, dx - 2 + leg_l, oy), fill=fold, outline=rim)
    draw.rectangle((dx + 2 + leg_r, oy - 5, dx + 10 + leg_r, oy), fill=fold, outline=rim)
    # Face recess — charcoal, not sky twin
    draw.polygon(
        [(dx - 5, body_top + 6), (dx, body_top - 2), (dx + 5, body_top + 6)],
        fill=(0x22, 0x22, 0x32, 255),
    )
    draw.point((dx - 2, body_top + 3), fill=rim)
    draw.point((dx + 2, body_top + 3), fill=rim)

    palm_x = dx - 16 - arm_swing - sigil_forward
    palm_y = body_top + 18
    draw.line((dx - 8, body_top + 14, palm_x + 4, palm_y), fill=C_MID, width=2)
    draw.ellipse((palm_x, palm_y - 2, palm_x + 6, palm_y + 4), fill=C_BASE, outline=C_MID)
    _draw_ember_sigil(frame_img, palm_x + 2, palm_y + 1, glow_pulse)

    right_x = dx + 14 + arm_swing
    right_y = body_top + 20
    if anim == "cast" and frame >= 2:
        right_x = dx + 18 + arm_swing
        right_y = body_top + 14
    draw.line((dx + 8, body_top + 14, right_x, right_y), fill=C_MID, width=2)

    if anim == "dash":
        for streak in range(4):
            sx = dx - 10 - streak * 8 - frame * 3
            sy = body_top + 14 + streak
            draw.line((sx, sy, sx + 16, sy), fill=(*C_MID[:3], 100 - streak * 20), width=2)


def build_elara_sheet() -> Path:
    anims = {
        "idle": 8,
        "walk": 8,
        "jump": 6,
        "fall": 4,
        "dash": 6,
        "melee_1": 6,
        "melee_2": 6,
        "melee_3": 6,
        "cast": 6,
        "hit": 4,
    }
    max_frames = max(anims.values())
    sheet = Image.new("RGBA", (max_frames * 64, len(anims) * 64), C_TRANSPARENT)
    regions: dict[str, list[tuple[int, int, int, int]]] = {}

    for row, (name, count) in enumerate(anims.items()):
        regions[name] = []
        for f in range(count):
            frame_img = Image.new("RGBA", (64, 64), C_TRANSPARENT)
            draw_elara_frame(frame_img, f, name)
            x, y = f * 64, row * 64
            sheet.paste(frame_img, (x, y))
            regions[name].append((x, y, 64, 64))

    out = ASSETS / "sprites/player/elara_core.png"
    sheet.save(out)
    write_sprite_frames_tres(
        out.relative_to(GODOT),
        ASSETS / "sprites/player/elara_core.tres",
        regions,
        {
            "idle": 10.0,
            "walk": 12.0,
            "jump": 12.0,
            "fall": 10.0,
            "dash": 18.0,
            "melee_1": 16.0,
            "melee_2": 16.0,
            "melee_3": 16.0,
            "cast": 14.0,
            "hit": 14.0,
        },
    )
    return out


def build_elara_portrait() -> Path:
    img = Image.new("RGBA", (48, 48), C_TRANSPARENT)
    draw = ImageDraw.Draw(img)
    # Ornate circular frame hint
    draw.ellipse((2, 2, 45, 45), outline=C_MID, width=1)
    draw.ellipse((4, 4, 43, 43), outline=C_WARM, width=1)
    # Hood portrait
    draw.polygon([(24, 8), (10, 22), (12, 38), (36, 38), (38, 22)], fill=C_SHADOW, outline=C_MID)
    draw.ellipse((18, 24, 30, 34), fill=(0x12, 0x12, 0x20, 255))
    draw.point((21, 28), fill=C_MID)
    draw.point((27, 28), fill=C_MID)
    # Sigil glow on chest
    draw.ellipse((20, 32, 28, 40), fill=(*C_ACCENT[:3], 180))
    draw.ellipse((22, 34, 26, 38), fill=C_WARM)
    out = ASSETS / "sprites/player/elara_portrait_48.png"
    img.save(out)
    return out


# ---------------------------------------------------------------------------
# Enemies — Wave 1 Ashen roster
# ---------------------------------------------------------------------------


def _enemy_frame(fn, frames: int) -> tuple[Image.Image, list[tuple[int, int, int, int]]]:
    sheet = Image.new("RGBA", (64 * frames, 64), C_TRANSPARENT)
    rects = []
    for f in range(frames):
        frame = Image.new("RGBA", (64, 64), C_TRANSPARENT)
        fn(ImageDraw.Draw(frame), f, frame)
        x = f * 64
        sheet.paste(frame, (x, 0))
        rects.append((x, 0, 64, 64))
    return sheet, rects


def _draw_ash_wisp(draw: ImageDraw.ImageDraw, frame: int, img: Image.Image) -> None:
    bob = int(math.sin(frame * 1.4) * 3)
    cx, cy = 32, 34 + bob
    # Teardrop body — clean silhouette, no dither
    draw.polygon(
        [(cx, cy - 18), (cx + 12, cy + 4), (cx, cy + 10), (cx - 12, cy + 4)],
        fill=C_MID,
        outline=C_SHADOW,
    )
    draw.ellipse((cx - 6, cy - 8, cx + 6, cy + 2), fill=C_ACCENT)
    draw.point((cx - 3, cy - 4), fill=C_SHADOW)
    draw.point((cx + 3, cy - 4), fill=C_SHADOW)
    for i in range(4):
        ex = cx - 8 + i * 5
        ey = cy + 12 + int(math.sin(frame * 1.2 + i) * 2)
        px(img, ex, ey, C_ACCENT)
        px(img, ex, ey + 1, (*C_WARM[:3], 180))


def _draw_bone_crawler(draw: ImageDraw.ImageDraw, frame: int, img: Image.Image) -> None:
    crawl = int(math.sin(frame * 1.1) * 2)
    base_y = 52
    segments = [(14, 0), (32, -2), (50, 0)]
    for i, (sx, dy) in enumerate(segments):
        x = sx + crawl if i % 2 == frame % 2 else sx - crawl
        y = base_y - 8 + dy
        draw.rounded_rectangle((x - 8, y - 6, x + 8, y + 6), radius=3, fill=C_MID, outline=C_SHADOW)
        draw.line((x - 4, y - 2, x + 4, y + 2), fill=C_BASE, width=1)
    # Skull front
    hx, hy = 56 + crawl, base_y - 10
    draw.ellipse((hx - 7, hy - 5, hx + 3, hy + 5), fill=C_BASE, outline=C_SHADOW)
    draw.point((hx - 2, hy - 1), fill=C_SHADOW)
    draw.point((hx + 1, hy - 1), fill=C_SHADOW)


def _draw_ember_moth(draw: ImageDraw.ImageDraw, frame: int, img: Image.Image) -> None:
    flap = int(math.sin(frame * 1.8) * 6)
    cx, cy = 32, 36
    # V wings
    draw.polygon(
        [(cx, cy), (cx - 22, cy - 10 - flap), (cx - 8, cy + 2)],
        fill=(*C_MID[:3], 200),
        outline=C_SHADOW,
    )
    draw.polygon(
        [(cx, cy), (cx + 22, cy - 10 - flap), (cx + 8, cy + 2)],
        fill=(*C_MID[:3], 200),
        outline=C_SHADOW,
    )
    draw.ellipse((cx - 4, cy - 2, cx + 4, cy + 6), fill=C_WARM, outline=C_SHADOW)
    draw.ellipse((cx - 2, cy, cx + 2, cy + 4), fill=C_ACCENT)
    # Wing ember dots
    for wx in (cx - 16, cx + 14):
        px(img, wx, cy - 6, (*C_ACCENT[:3], 160))


def _draw_threshold_shade(draw: ImageDraw.ImageDraw, frame: int, img: Image.Image) -> None:
    bob = int(math.sin(frame * 0.6) * 1)
    ox, oy = 32, 58 - bob
    # Tall humanoid void — 56px
    top = oy - 48
    draw.rectangle((ox - 9, top + 12, ox + 9, oy), fill=C_SHADOW, outline=C_MID)
    draw.polygon([(ox - 11, top + 14), (ox, top - 4), (ox + 11, top + 14)], fill=C_SHADOW, outline=C_MID)
    # Ember eye slits
    eye_glow = tuple(int(c * (0.7 + 0.3 * math.sin(frame))) for c in C_ACCENT[:3]) + (255,)
    draw.line((ox - 5, top + 8, ox - 2, top + 8), fill=eye_glow, width=2)
    draw.line((ox + 2, top + 8, ox + 5, top + 8), fill=eye_glow, width=2)
    # Wispy lower body
    for i in range(5):
        wx = ox - 8 + i * 4
        wy = oy - 2 + (frame + i) % 3
        px(img, wx, wy, (*C_MID[:3], 100))


def _draw_bramble_stalker(draw: ImageDraw.ImageDraw, frame: int, img: Image.Image) -> None:
    """Walk cycle with plant-leg strides — avoids static-blob jitter."""
    ox, oy = 32, 60
    phase = frame * (math.pi / 3.0)
    bob = int(math.sin(phase) * 1)
    body_top = oy - 28 - bob
    # Body mass
    draw.polygon(
        [
            (ox - 10, body_top + 10),
            (ox + 8, body_top + 6),
            (ox + 12, oy - 14),
            (ox - 8, oy - 12),
        ],
        fill=C_LEAF,
        outline=C_THORN,
    )
    # Head
    draw.ellipse((ox + 4, body_top + 4, ox + 18, body_top + 16), fill=C_THORN, outline=C_LEAF)
    draw.point((ox + 10, body_top + 8), fill=C_ACCENT)
    draw.point((ox + 14, body_top + 8), fill=C_ACCENT)
    # Three plant legs with stride offset
    for i, base_x in enumerate((ox - 8, ox, ox + 8)):
        swing = int(math.sin(phase + i * 2.1) * 5)
        foot_x = base_x + swing
        hip_y = oy - 12
        draw.line((base_x, hip_y, foot_x, oy - 1), fill=C_THORN, width=2)
        draw.ellipse((foot_x - 2, oy - 3, foot_x + 2, oy), fill=C_LEAF)


def _save_enemy(
    out_dir: Path,
    name: str,
    sheet: Image.Image,
    anims: dict[str, list[tuple[int, int, int, int]]],
    speeds: dict[str, float],
    loop_anims: set[str] | None = None,
) -> Path:
    out_dir.mkdir(parents=True, exist_ok=True)
    out = out_dir / f"{name}.png"
    sheet.save(out)
    write_sprite_frames_tres(
        out.relative_to(GODOT),
        out_dir / f"{name}.tres",
        anims,
        speeds,
        loop_anims=loop_anims,
    )
    return out


def build_enemies() -> list[Path]:
    paths: list[Path] = []

    sheet, rects = _enemy_frame(lambda d, f, i: _draw_ash_wisp(d, f, i), 4)
    paths.append(
        _save_enemy(
            ASSETS / "sprites/enemies/e01_ash_wisp",
            "e01_sheet",
            sheet,
            {"idle": rects},
            {"idle": 6.0},
        )
    )

    sheet, rects = _enemy_frame(lambda d, f, i: _draw_bone_crawler(d, f, i), 6)
    paths.append(
        _save_enemy(
            ASSETS / "sprites/enemies/e02_bone_crawler",
            "e02_sheet",
            sheet,
            {"walk": rects},
            {"walk": 6.0},
            loop_anims={"walk"},
        )
    )

    anims_bramble = {"idle": 4, "walk": 6}
    max_f = max(anims_bramble.values())
    sheet = Image.new("RGBA", (max_f * 64, len(anims_bramble) * 64), C_TRANSPARENT)
    regions: dict[str, list[tuple[int, int, int, int]]] = {}
    for row, (anim, count) in enumerate(anims_bramble.items()):
        regions[anim] = []
        for f in range(count):
            frame = Image.new("RGBA", (64, 64), C_TRANSPARENT)
            _draw_bramble_stalker(ImageDraw.Draw(frame), f, frame)
            x, y = f * 64, row * 64
            sheet.paste(frame, (x, y))
            regions[anim].append((x, y, 64, 64))
    paths.append(
        _save_enemy(
            ASSETS / "sprites/enemies/e03_bramble_stalker",
            "e03_sheet",
            sheet,
            regions,
            {"idle": 6.0, "walk": 6.0},
        )
    )

    sheet, rects = _enemy_frame(lambda d, f, i: _draw_ember_moth(d, f, i), 4)
    paths.append(
        _save_enemy(
            ASSETS / "sprites/enemies/e04_ember_moth",
            "e04_sheet",
            sheet,
            {"idle": rects},
            {"idle": 6.0},
        )
    )

    sheet, rects = _enemy_frame(lambda d, f, i: _draw_threshold_shade(d, f, i), 4)
    paths.append(
        _save_enemy(
            ASSETS / "sprites/enemies/e08_threshold_shade",
            "e08_sheet",
            sheet,
            {"idle": rects},
            {"idle": 5.0},
        )
    )

    return paths


# ---------------------------------------------------------------------------
# Environment — 5-layer parallax + tileset + props (screenshot layout)
# ---------------------------------------------------------------------------


def _vertical_gradient(img: Image.Image, top: tuple, bottom: tuple, power: float = 1.0) -> None:
    draw = ImageDraw.Draw(img)
    h = img.height
    for y in range(h):
        t = (y / max(h - 1, 1)) ** power
        rgb = blend(top[:3], bottom[:3], t)
        draw.line((0, y, img.width - 1, y), fill=(*rgb, 255))


def _scatter_embers(img: Image.Image, rng: random.Random, count: int, y_range: tuple[int, int]) -> None:
    draw = ImageDraw.Draw(img)
    for _ in range(count):
        x = rng.randint(0, img.width - 1)
        y = rng.randint(y_range[0], y_range[1])
        size = rng.choice((1, 1, 2))
        alpha = rng.randint(40, 180)
        color = C_ACCENT if rng.random() > 0.3 else C_WARM
        draw.ellipse((x, y, x + size, y + size), fill=(*color[:3], alpha))


def _draw_city_skyline(draw: ImageDraw.ImageDraw, base_y: int, w: int) -> None:
    """Distant ruined city silhouettes — screenshot background depth."""
    rng = random.Random(13)
    x = 0
    while x < w:
        bw = rng.randint(40, 90)
        bh = rng.randint(80, 160)
        draw.rectangle((x, base_y - bh, x + bw, base_y - 20), fill=(*C_SHADOW[:3], 200))
        if rng.random() > 0.5:
            draw.rectangle((x + 8, base_y - bh - 30, x + bw - 8, base_y - bh), fill=(*C_BASE[:3], 170))
        for wx in range(x + 10, x + bw - 10, rng.randint(14, 22)):
            wh = rng.randint(12, 28)
            draw.rectangle((wx, base_y - bh + 20, wx + 6, base_y - bh + 20 + wh), fill=(*C_MID[:3], 80))
        x += bw + rng.randint(8, 20)


def _draw_ruin_silhouette(draw: ImageDraw.ImageDraw, x: int, base_y: int, rng: random.Random) -> None:
    kind = rng.choice(("spire", "wall", "arch"))
    if kind == "spire":
        rw, rh = rng.randint(28, 48), rng.randint(160, 260)
        draw.rectangle((x, base_y - rh, x + rw, base_y), fill=(*C_SHADOW[:3], 220))
        draw.polygon([(x - 4, base_y - rh + 30), (x + rw // 2, base_y - rh - 10), (x + rw + 4, base_y - rh + 30)], fill=(*C_BASE[:3], 200))
    elif kind == "wall":
        rw, rh = rng.randint(80, 140), rng.randint(60, 110)
        draw.rectangle((x, base_y - rh, x + rw, base_y), fill=(*C_BASE[:3], 190))
    else:
        rw, rh = rng.randint(70, 110), rng.randint(120, 180)
        left, top = x, base_y - rh
        draw.rectangle((left + 10, top + 30, left + rw - 10, base_y), fill=(*C_BASE[:3], 200))
        draw.polygon([(left, top + 30), (left + rw // 2, top), (left + rw, top + 30)], fill=(*C_SHADOW[:3], 210))
        gap = max(20, rw // 3)
        draw.rectangle((left + (rw - gap) // 2, top + 40, left + (rw + gap) // 2, base_y - 10), fill=C_TRANSPARENT)


def _draw_dead_tree(draw: ImageDraw.ImageDraw, x: int, base_y: int, height: int) -> None:
    draw.line((x, base_y, x, base_y - height), fill=(*C_SHADOW[:3], 200), width=2)
    for branch_y, span in ((base_y - height // 3, 18), (base_y - height // 2, 24), (base_y - 2 * height // 3, 14)):
        draw.line((x, branch_y, x + span, branch_y - 8), fill=(*C_MID[:3], 160), width=1)
        draw.line((x, branch_y, x - span // 2, branch_y - 6), fill=(*C_MID[:3], 140), width=1)


def _draw_hooded_king_statue(draw: ImageDraw.ImageDraw, x: int, base_y: int) -> None:
    """Screenshot right-side hooded skeletal king on pedestal."""
    ped_w, ped_h = 100, 32
    px = x - ped_w // 2
    draw.rectangle((px, base_y - ped_h, px + ped_w, base_y), fill=(*C_BASE[:3], 225), outline=(*C_MID[:3], 180))
    fig_x = x
    top = base_y - ped_h - 210
    # Robed body
    draw.rectangle((fig_x - 24, top + 55, fig_x + 24, base_y - ped_h), fill=(*C_SHADOW[:3], 235), outline=(*C_MID[:3], 160))
    draw.polygon([(fig_x - 28, top + 60), (fig_x, top + 8), (fig_x + 28, top + 60)], fill=(*C_SHADOW[:3], 245))
    # Crown spikes
    for i, ox in enumerate((-16, -8, 0, 8, 16)):
        draw.polygon([(fig_x + ox, top + 6), (fig_x + ox - 4, top + 24), (fig_x + ox + 4, top + 24)], fill=(*C_MID[:3], 210))
    # Skull face hint
    draw.ellipse((fig_x - 8, top + 28, fig_x + 8, top + 44), fill=(*C_BASE[:3], 180))
    draw.line((fig_x - 4, top + 34, fig_x - 1, top + 34), fill=C_SHADOW, width=1)
    draw.line((fig_x + 1, top + 34, fig_x + 4, top + 34), fill=C_SHADOW, width=1)
    # Staff with glowing gem
    draw.line((fig_x + 30, top + 35, fig_x + 34, base_y - ped_h - 8), fill=(*C_WARM[:3], 210), width=3)
    draw.ellipse((fig_x + 26, top + 24, fig_x + 38, top + 36), fill=(*C_ACCENT[:3], 200))
    draw.ellipse((fig_x + 29, top + 27, fig_x + 35, top + 33), fill=(*C_WARM[:3], 220))


def _draw_gothic_arch(draw: ImageDraw.ImageDraw, x: int, base_y: int) -> None:
    w, h = 120, 200
    left, top = x, base_y - h
    draw.rectangle((left + 12, top + 40, left + w - 12, base_y), fill=(*C_BASE[:3], 200), outline=(*C_MID[:3], 120))
    draw.polygon([(left, top + 40), (left + w // 2, top), (left + w, top + 40)], fill=(*C_SHADOW[:3], 210))
    gap = 36
    draw.rectangle((left + (w - gap) // 2, top + 50, left + (w + gap) // 2, base_y - 8), fill=C_TRANSPARENT)


def _draw_mist_band(img: Image.Image, y0: int, y1: int, alpha: int) -> None:
    draw = ImageDraw.Draw(img)
    for y in range(y0, y1):
        wave = (math.sin(y * 0.07) + math.sin(y * 0.025 + 1.2)) * 0.5
        a = int(alpha + 24 * wave)
        draw.line((0, y, img.width - 1, y), fill=(*C_MID[:3], max(10, a)))


def _draw_brazier(draw: ImageDraw.ImageDraw, x: int, base_y: int) -> None:
    draw.rectangle((x - 8, base_y - 48, x + 8, base_y), fill=(*C_BASE[:3], 220), outline=(*C_MID[:3], 180))
    draw.ellipse((x - 10, base_y - 58, x + 10, base_y - 44), fill=(*C_WARM[:3], 200))
    # Ember glow
    for r, a in ((22, 35), (14, 70), (8, 120)):
        draw.ellipse((x - r, base_y - 54 - r // 2, x + r, base_y - 54 + r // 2), fill=(*C_ACCENT[:3], a))


def build_parallax() -> list[Path]:
    rng = random.Random(7)
    w, h = 960, 540
    base_y = h - 64
    outputs: list[Path] = []
    out_dir = ASSETS / "sprites/tilesets/01_ashen_threshold"

    # Layer 0 — sky + ember motes
    sky = Image.new("RGBA", (w, h), C_SHADOW)
    _vertical_gradient(sky, (0x0E, 0x0E, 0x18, 255), C_SHADOW, power=0.75)
    _scatter_embers(sky, rng, 100, (30, int(h * 0.75)))
    p0 = out_dir / "parallax_0_sky.png"
    sky.save(p0)
    outputs.append(p0)

    # Layer 1 — far ruined city silhouettes
    far = Image.new("RGBA", (w, h), C_TRANSPARENT)
    draw = ImageDraw.Draw(far)
    _draw_city_skyline(draw, base_y - 20, w)
    x = -30
    while x < w + 40:
        _draw_ruin_silhouette(draw, x, base_y, rng)
        x += rng.randint(90, 150)
    p1 = out_dir / "parallax_1_far_ruins.png"
    far.save(p1)
    outputs.append(p1)

    # Layer 2 — mid architecture: arch, dead trees, hooded king statue
    mid = Image.new("RGBA", (w, h), C_TRANSPARENT)
    draw = ImageDraw.Draw(mid)
    _draw_gothic_arch(draw, 180, base_y)
    _draw_dead_tree(draw, 420, base_y, 220)
    _draw_dead_tree(draw, 520, base_y, 180)
    _draw_hooded_king_statue(draw, 780, base_y)
    p2 = out_dir / "parallax_2_mid_architecture.png"
    mid.save(p2)
    outputs.append(p2)

    # Layer 3 — ember fog band
    fog = Image.new("RGBA", (w, h), C_TRANSPARENT)
    _draw_mist_band(fog, 260, 420, 38)
    _draw_mist_band(fog, 300, 480, 22)
    draw = ImageDraw.Draw(fog)
    for x in range(0, w, 160):
        draw.ellipse((x, 350, x + 200, 420), fill=(*C_WARM[:3], 12))
    p3 = out_dir / "parallax_3_mid_fog.png"
    fog.save(p3)
    outputs.append(p3)

    # Layer 4 — near occluders: brazier pillar, hanging roots
    near = Image.new("RGBA", (w, h), C_TRANSPARENT)
    draw = ImageDraw.Draw(near)
    _draw_brazier(draw, 72, base_y)
    draw.rectangle((58, base_y - 120, 86, base_y), fill=(*C_SHADOW[:3], 190), outline=(*C_MID[:3], 100))
    for i in range(5):
        rx = 100 + i * 18
        draw.line((rx, 80 + i * 10, rx - 6, base_y - 40), fill=(*C_BASE[:3], 140), width=1)
    # Foreground grass tufts
    for gx in range(40, w, 90):
        draw.polygon([(gx, base_y), (gx + 6, base_y - 10), (gx + 12, base_y)], fill=(*C_MID[:3], 150))
    p4 = out_dir / "parallax_4_near_occluders.png"
    near.save(p4)
    outputs.append(p4)

    # Vignette overlay (title screen)
    vignette = Image.new("RGBA", (w, h), C_TRANSPARENT)
    vdraw = ImageDraw.Draw(vignette)
    for y in range(h):
        edge = min(y, h - y)
        alpha = int(max(0, 85 - edge * 0.42))
        if alpha > 0:
            vdraw.line((0, y, w - 1, y), fill=(0, 0, 0, alpha))
    vig_path = ASSETS / "sprites/ui/vignette_overlay.png"
    vignette.save(vig_path)
    outputs.append(vig_path)

    return outputs


def _draw_floor_tile(img: Image.Image, variant: int = 0) -> None:
    """Seamless stone fill — variant blotches so tiling doesn't form a lattice."""
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 63, 63), fill=C_BASE)
    layouts = (
        ((8, 12), (18, 40), (34, 22), (48, 50), (56, 8), (28, 56)),
        ((14, 28), (40, 10), (52, 36), (8, 48), (30, 18), (60, 54)),
        ((22, 6), (6, 34), (44, 44), (58, 20), (18, 58), (36, 30)),
    )
    blotches = layouts[variant % len(layouts)]
    for i, (y, x) in enumerate(blotches):
        c = C_SHADOW if i % 2 == 0 else (*C_MID[:3], 160)
        draw.ellipse((x - 5, y - 3, x + 5, y + 3), fill=c)
    cracks = (
        ((4, 18, 22, 20), (28, 40, 50, 38), (12, 52, 18, 60)),
        ((10, 8, 30, 14), (40, 28, 58, 34), (6, 44, 24, 50)),
        ((20, 24, 36, 20), (8, 36, 20, 48), (44, 52, 60, 46)),
    )
    for x0, y0, x1, y1 in cracks[variant % len(cracks)]:
        draw.line((x0, y0, x1, y1), fill=(*C_MID[:3], 55), width=1)


def _draw_floor_tile_v0(img: Image.Image) -> None:
    _draw_floor_tile(img, 0)


def _draw_floor_tile_v1(img: Image.Image) -> None:
    _draw_floor_tile(img, 1)


def _draw_floor_tile_v2(img: Image.Image) -> None:
    _draw_floor_tile(img, 2)

def _draw_wall_tile(img: Image.Image) -> None:
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 63, 63), fill=C_SHADOW)
    for y, x in ((10, 18), (28, 44), (50, 20)):
        draw.ellipse((x - 8, y - 5, x + 8, y + 5), fill=(*C_BASE[:3], 200))
    draw.line((3, 22, 60, 24), fill=(*C_MID[:3], 35), width=1)
    draw.line((5, 44, 58, 41), fill=(*C_MID[:3], 28), width=1)


def _draw_platform_tile(img: Image.Image) -> None:
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 20, 63, 63), fill=C_BASE)
    draw.ellipse((12, 36, 28, 52), fill=C_SHADOW)
    draw.ellipse((40, 30, 56, 46), fill=(*C_MID[:3], 180))
    # Cap without dotted grid (dots read as tile squares in-room)
    draw.rectangle((0, 14, 63, 22), fill=C_MID)
    draw.line((0, 14, 63, 14), fill=C_WARM, width=1)
    draw.line((0, 21, 63, 21), fill=(*C_SHADOW[:3], 180), width=1)
    for x in range(0, 64, 16):
        if x % 32 == 0:
            draw.line((x, 14, x + 3, 10), fill=(*C_MID[:3], 180), width=1)


def _draw_platform_left_tile(img: Image.Image) -> None:
    _draw_platform_tile(img)
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 14, 8, 63), fill=C_SHADOW)


def _draw_platform_right_tile(img: Image.Image) -> None:
    _draw_platform_tile(img)
    draw = ImageDraw.Draw(img)
    draw.rectangle((55, 14, 63, 63), fill=C_SHADOW)


def _draw_rune_tile(img: Image.Image) -> None:
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 63, 63), fill=C_SHADOW)
    draw.ellipse((18, 22, 46, 42), fill=(*C_BASE[:3], 200))
    cx, cy = 32, 32
    draw.ellipse((cx - 14, cy - 14, cx + 14, cy + 14), outline=(*C_ACCENT[:3], 140), width=1)
    draw.line((cx, cy - 10, cx, cy + 10), fill=(*C_ACCENT[:3], 100))
    draw.line((cx - 10, cy, cx + 10, cy), fill=(*C_ACCENT[:3], 100))


def _draw_brazier_tile(img: Image.Image) -> None:
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 32, 63, 63), fill=C_BASE)
    draw.ellipse((8, 40, 28, 56), fill=C_SHADOW)
    _draw_brazier(draw, 32, 62)


def _draw_vine_tile(img: Image.Image) -> None:
    draw = ImageDraw.Draw(img)
    for i in range(4):
        x = 10 + i * 14
        draw.line((x, 0, x - 4, 63), fill=(*C_MID[:3], 160), width=2)


def _draw_grass_tuft_tile(img: Image.Image) -> None:
    draw = ImageDraw.Draw(img)
    for gx in (16, 32, 48):
        draw.polygon([(gx, 58), (gx + 4, 44), (gx + 8, 58)], fill=(*C_MID[:3], 200))


def build_tileset() -> Path:
    tile_fns = [
        _draw_floor_tile_v0,
        _draw_wall_tile,
        _draw_platform_tile,
        _draw_rune_tile,
        _draw_platform_left_tile,
        _draw_platform_right_tile,
        _draw_brazier_tile,
        _draw_vine_tile,
        _draw_grass_tuft_tile,
        _draw_floor_tile_v1,
        _draw_wall_tile,
        _draw_platform_tile,
        _draw_rune_tile,
        _draw_floor_tile_v2,
        _draw_wall_tile,
        _draw_platform_tile,
    ]
    sheet = Image.new("RGBA", (64 * len(tile_fns), 64), C_TRANSPARENT)
    for i, fn in enumerate(tile_fns):
        tile = Image.new("RGBA", (64, 64), C_TRANSPARENT)
        fn(tile)
        sheet.paste(tile, (i * 64, 0))
    out = ASSETS / "sprites/tilesets/01_ashen_threshold/tileset.png"
    sheet.save(out)
    return out


def build_props() -> Path:
    """64×64 prop cells — brazier, broken pillar, hanging root."""
    props = Image.new("RGBA", (64 * 3, 64), C_TRANSPARENT)
    for i, fn in enumerate((_draw_brazier_tile, _draw_vine_tile, _draw_grass_tuft_tile)):
        cell = Image.new("RGBA", (64, 64), C_TRANSPARENT)
        fn(cell)
        props.paste(cell, (i * 64, 0))
    out = ASSETS / "sprites/tilesets/01_ashen_threshold/props.png"
    props.save(out)
    return out


# ---------------------------------------------------------------------------
# VFX — ember sigil + bolt
# ---------------------------------------------------------------------------


def _draw_ember_sigil_vfx(frame: int, total: int) -> Image.Image:
    """Single filled sigil disc — one entity per frame."""
    cell = Image.new("RGBA", (128, 128), C_TRANSPARENT)
    draw = ImageDraw.Draw(cell)
    cx, cy = 64, 64
    pulse = 0.5 + 0.5 * math.sin(frame * 0.9)
    r = int(22 + pulse * 5)
    draw.ellipse((cx - r - 6, cy - r - 6, cx + r + 6, cy + r + 6), fill=(*C_ACCENT[:3], 35))
    draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(*C_WARM[:3], 200), outline=C_ACCENT, width=3)
    draw.ellipse((cx - r + 8, cy - r + 8, cx + r - 8, cy + r - 8), fill=(*C_ACCENT[:3], 160), outline=C_WARM, width=2)
    draw.ellipse((cx - 8, cy - 8, cx + 8, cy + 8), fill=C_ACCENT)
    draw.line((cx - 14, cy, cx + 14, cy), fill=C_TRIM, width=2)
    draw.line((cx, cy - 14, cx, cy + 14), fill=C_TRIM, width=2)
    return cell


def _draw_ember_bolt_vfx(frame: int, total: int) -> Image.Image:
    """Single filled ember bolt — one projectile silhouette per frame."""
    cell = Image.new("RGBA", (128, 128), C_TRANSPARENT)
    draw = ImageDraw.Draw(cell)
    t = frame / max(total - 1, 1)
    length = int(36 + t * 40)
    x0, y0 = 28, 64
    x1 = x0 + length
    y1 = y0 - int(length * 0.12)
    # Filled shaft as a thick diamond/capsule (not a spray of dots)
    dx = x1 - x0
    dy = y1 - y0
    # Perpendicular for thickness
    nx, ny = -dy, dx
    length_n = max(math.hypot(nx, ny), 1.0)
    nx, ny = nx / length_n * 5, ny / length_n * 5
    draw.polygon(
        [
            (x0 - nx, y0 - ny),
            (x0 + nx, y0 + ny),
            (x1 + nx * 0.4, y1 + ny * 0.4),
            (x1 - nx * 0.4, y1 - ny * 0.4),
        ],
        fill=C_ACCENT,
    )
    draw.polygon(
        [
            (x0 - nx * 0.45, y0 - ny * 0.45),
            (x0 + nx * 0.45, y0 + ny * 0.45),
            (x1 + nx * 0.2, y1 + ny * 0.2),
            (x1 - nx * 0.2, y1 - ny * 0.2),
        ],
        fill=C_WARM,
    )
    draw.polygon(
        [
            (x1, y1),
            (x1 - 12, y1 - 7),
            (x1 - 10, y1 + 6),
        ],
        fill=C_ACCENT,
    )
    return cell


def build_vfx() -> list[Path]:
    paths: list[Path] = []
    out_dir = ASSETS / "sprites/vfx/spells"

    for spell_id, frames, drawer in (
        ("ember_sigil", 8, _draw_ember_sigil_vfx),
        ("ember_bolt", 6, _draw_ember_bolt_vfx),
    ):
        sheet = Image.new("RGBA", (128 * frames, 128), C_TRANSPARENT)
        rects: list[tuple[int, int, int, int]] = []
        for f in range(frames):
            cell = drawer(f, frames)
            x = f * 128
            sheet.paste(cell, (x, 0))
            rects.append((x, 0, 128, 128))
        out = out_dir / f"vfx_{spell_id}.png"
        sheet.save(out)
        write_sprite_frames_tres(
            out.relative_to(GODOT),
            out_dir / f"vfx_{spell_id}.tres",
            {"effect": rects},
            {"effect": 12.0},
            loop_anims=set(),
        )
        paths.append(out)
    return paths


def main() -> int:
    import argparse

    parser = argparse.ArgumentParser(
        description="Write PIL placeholder sprites (emergency / CI). Does not overwrite production AI art unless forced."
    )
    parser.add_argument(
        "--force-placeholders",
        action="store_true",
        help="Required to overwrite godot/assets/sprites with PIL placeholders.",
    )
    args = parser.parse_args()
    if not args.force_placeholders:
        print(
            "Refusing to overwrite production sprites.\n"
            "Use Cursor AI generation + tools/normalize_ai_sprites.py for art.\n"
            "Pass --force-placeholders only for emergency PIL stubs."
        )
        return 2

    random.seed(42)
    ensure_dirs()
    print("Generating screenshot-aligned Wave 1 PIL placeholders (--force-placeholders)...")
    build_elara_sheet()
    build_elara_portrait()
    build_enemies()
    build_tileset()
    build_props()
    build_parallax()
    build_vfx()
    print("Done — run: python3.11 tools/validate_sprite_imports.py")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
