#!/usr/bin/env python3.11
"""Generate Phase 0 placeholder art and audio for Arcania (P0.1–P0.7)."""

from __future__ import annotations

import math
import random
import struct
import subprocess
import wave
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
GODOT = ROOT / "godot"
ASSETS = GODOT / "assets"

# Ashen Threshold palette (docs/03-art-bible.md §4)
C_SHADOW = (0x1A, 0x1A, 0x2E, 255)
C_BASE = (0x2C, 0x2C, 0x34, 255)
C_MID = (0x4A, 0x4E, 0x69, 255)
C_WARM = (0x8B, 0x45, 0x13, 255)
C_ACCENT = (0xFF, 0x6B, 0x35, 255)
C_SKIN = (0x9D, 0x8C, 0x98, 255)
C_CYAN = (0x00, 0xD9, 0xFF, 255)
C_GOLD = (0xE9, 0xC4, 0x6A, 255)
C_PURPLE = (0x9D, 0x4E, 0xDD, 255)
C_VINE = (0x52, 0xB7, 0x88, 255)
C_LEAF_DARK = (0x38, 0x59, 0x3D, 255)
C_YELLOW = (0xFF, 0xD6, 0x0A, 255)
C_NULL_WHITE = (0xE8, 0xE8, 0xE8, 255)
C_INK = (0x0B, 0x09, 0x0A, 255)
C_ASH_GREY = (0x8D, 0x99, 0xAE, 255)
C_BEARD = (0x9A, 0x9A, 0xA8, 255)
C_TRANSPARENT = (0, 0, 0, 0)

# Implemented spells — icons (48×48) + VFX sheets (128×128 cells)
SPELL_SPECS: dict[str, dict] = {
    "ember_sigil": {"vfx_frames": 8, "color": C_ACCENT, "color2": C_YELLOW},
    "veil_step": {"vfx_frames": 8, "color": C_PURPLE, "color2": (255, 255, 255, 255)},
    "ember_bolt": {"vfx_frames": 6, "color": C_ACCENT, "color2": C_YELLOW},
    "rootbind": {"vfx_frames": 8, "color": C_VINE, "color2": C_LEAF_DARK},
    "arc_step": {"vfx_frames": 8, "color": C_CYAN, "color2": (180, 240, 255, 255)},
    "rune_anchor": {"vfx_frames": 10, "color": C_GOLD, "color2": C_WARM},
}

# Tier-I relics — 48×48 inventory / pickup icons
RELIC_SPECS: dict[str, tuple] = {
    "cinder_heart": (C_ACCENT, C_WARM, C_YELLOW),
    "thornseed_charm": (C_VINE, C_LEAF_DARK, (0x6B, 0x8E, 0x4A, 255)),
    "iron_grip": (C_MID, C_BASE, C_WARM),
    "gloom_lens": ((0x72, 0x7A, 0x9A, 255), C_PURPLE, C_CYAN),
    "frost_nail": (C_CYAN, (0xB8, 0xE8, 0xFF, 255), C_MID),
    "mist_walker": ((0x8A, 0x95, 0xA8, 255), (0xC8, 0xD4, 0xE0, 255), C_MID),
}

SAMPLE_RATE = 44100


def ensure_dirs() -> None:
    paths = [
        ASSETS / "sprites/player",
        ASSETS / "sprites/enemies/e01_ash_wisp",
        ASSETS / "sprites/enemies/e03_bramble_stalker",
        ASSETS / "sprites/bosses/mb_01_thornweft_matron",
        ASSETS / "sprites/bosses/boss_01_root_warden",
        ASSETS / "sprites/tilesets/01_ashen_threshold",
        ASSETS / "sprites/tilesets/02_whisperwood_hollow",
        ASSETS / "sprites/vfx/spells",
        ASSETS / "sprites/ui",
        ASSETS / "sprites/ui/icons",
        ASSETS / "sprites/world",
        ASSETS / "sprites/npcs",
        ASSETS / "audio/ambient",
        ASSETS / "audio/sfx/player",
        ASSETS / "audio/sfx/ui",
        ASSETS / "audio/sfx/footsteps",
        ASSETS / "audio/sfx/spells",
        ASSETS / "audio/music",
    ]
    for path in paths:
        path.mkdir(parents=True, exist_ok=True)


def draw_elara_frame(draw: ImageDraw.ImageDraw, frame: int, anim: str) -> None:
    """Draw a 64×64 Elara frame — readable silhouette, art-bible palette."""
    ox, oy = 32, 62  # feet pivot

    bob = 0
    leg_l = 0
    leg_r = 0
    arm_swing = 0
    robe_flare = 0
    lean = 0
    squash = 1.0
    glow_pulse = 0.6 + 0.4 * math.sin(frame * 0.8)

    if anim == "idle":
        bob = int(math.sin(frame * 0.7) * 1.5)
        glow_pulse = 0.5 + 0.5 * math.sin(frame * 0.9)
    elif anim == "walk":
        bob = int(math.sin(frame * 1.2) * 2)
        leg_l = int(math.sin(frame * 1.2) * 4)
        leg_r = int(math.sin(frame * 1.2 + math.pi) * 4)
        arm_swing = int(math.sin(frame * 1.2) * 3)
        robe_flare = int(abs(math.sin(frame * 1.2)) * 3)
    elif anim == "jump":
        squash = 1.1 if frame < 2 else 0.95
        leg_l = -3 if frame < 3 else 2
        leg_r = -3 if frame < 3 else 2
    elif anim == "fall":
        leg_l = 4
        leg_r = -2
        arm_swing = -4
    elif anim == "dash":
        squash = 0.82 if frame < 2 else 0.9
        robe_flare = 4 + frame
        bob = -3 if frame < 3 else -1
        lean = -4 - frame * 2
    elif anim == "melee_1":
        squash = 0.92 if frame < 2 else (1.06 if frame < 4 else 0.98)
        arm_swing = [-8, -4, 10, 12, 6, 2][min(frame, 5)]
        bob = 2 if frame in (2, 3) else 0
        robe_flare = 3 if frame in (2, 3) else 0
    elif anim == "melee_2":
        squash = 0.94 if frame < 2 else (1.04 if frame < 4 else 1.0)
        arm_swing = [-6, -2, 12, 14, 8, 3][min(frame, 5)]
        robe_flare = 4 if frame in (2, 3) else 1
        bob = 1 if frame == 3 else 0
    elif anim == "melee_3":
        squash = 1.12 if frame < 2 else (0.88 if frame < 4 else 0.95)
        arm_swing = [-10, -12, 14, 16, 8, 2][min(frame, 5)]
        bob = -4 if frame < 2 else (2 if frame == 3 else 0)
        robe_flare = 5 if frame in (2, 3) else 2
    elif anim == "cast":
        squash = 1.08 if frame in (2, 3) else (0.96 if frame == 0 else 1.0)
        arm_swing = [0, 2, 6, 10, 8, 4][min(frame, 5)]
        glow_pulse = 0.65 + 0.35 * math.sin(frame * 1.6)
        bob = -2 if frame in (2, 3) else 0
        robe_flare = 2 + frame if frame < 4 else 3
    elif anim == "hit":
        squash = 0.9 if frame < 2 else 0.95
        lean = [-6, -8, -4, -2][min(frame, 3)]
        bob = 2 if frame < 2 else 0
        arm_swing = [4, 6, 2, 0][min(frame, 3)]
        glow_pulse = 0.25 + 0.15 * (3 - frame)

    body_h = int(22 * squash)
    body_top = oy - 28 - bob
    draw_ox = ox + lean

    # Robe hem / legs
    hem_y = oy - 10 - bob
    draw.polygon(
        [
            (draw_ox - 10 - robe_flare, hem_y),
            (draw_ox + 10 + robe_flare, hem_y),
            (draw_ox + 8 + leg_r, oy),
            (draw_ox - 8 + leg_l, oy),
        ],
        fill=C_BASE,
        outline=C_SHADOW,
    )

    # Torso
    draw.rectangle(
        (draw_ox - 9, body_top + 8, draw_ox + 9, hem_y),
        fill=C_BASE,
        outline=C_MID,
    )

    # Trim line
    draw.line((draw_ox - 7, body_top + 14, draw_ox + 7, body_top + 14), fill=C_MID, width=1)

    # Hood + head
    head_cy = body_top + 4
    draw.ellipse((draw_ox - 8, head_cy - 10, draw_ox + 8, head_cy + 6), fill=C_SHADOW, outline=C_MID)
    draw.ellipse((draw_ox - 5, head_cy - 4, draw_ox + 5, head_cy + 2), fill=C_SKIN)

    # Left arm + ember sigil palm
    palm_x = draw_ox - 12 - arm_swing
    palm_y = body_top + 16
    draw.line((draw_ox - 6, body_top + 12, palm_x, palm_y), fill=C_MID, width=2)
    glow = tuple(int(c * glow_pulse) for c in C_ACCENT[:3]) + (255,)
    draw.ellipse((palm_x - 3, palm_y - 3, palm_x + 3, palm_y + 3), fill=glow)
    draw.ellipse((palm_x - 1, palm_y - 1, palm_x + 1, palm_y + 1), fill=(255, 220, 180, 255))

    # Right arm (combat hand)
    right_x = draw_ox + 12 + arm_swing
    right_y = body_top + 18
    if anim == "melee_3" and frame < 2:
        right_y = body_top + 6 - frame * 2
        right_x = draw_ox + 8 + frame * 2
    elif anim == "cast" and frame >= 2:
        right_x = draw_ox + 18 + arm_swing
        right_y = body_top + 14
    elif anim == "hit":
        right_x = draw_ox + 6 + arm_swing
        right_y = body_top + 20 + frame
    draw.line((draw_ox + 6, body_top + 12, right_x, right_y), fill=C_MID, width=2)
    if anim == "cast" and frame >= 2:
        cast_glow = tuple(int(c * glow_pulse) for c in C_ACCENT[:3]) + (255,)
        draw.ellipse((right_x - 4, right_y - 4, right_x + 4, right_y + 4), fill=cast_glow)
        # Sigil bloom ring
        ring_r = 6 + frame
        draw.ellipse(
            (right_x - ring_r, right_y - ring_r, right_x + ring_r, right_y + ring_r),
            outline=(*C_CYAN[:3], 100),
            width=1,
        )

    if anim == "dash":
        # Cyan after-image streaks — Arc Step read
        for streak in range(3):
            sx = draw_ox - 14 - streak * 10 - frame * 4
            sy = body_top + 12 + streak * 2
            alpha = 140 - streak * 40
            draw.line((sx, sy, sx + 18, sy), fill=(*C_CYAN[:3], alpha), width=2)
            draw.ellipse((sx - 4, sy - 6, sx + 4, sy + 2), fill=(*C_PURPLE[:3], alpha // 2))

    if anim == "hit" and frame < 2:
        # Crimson impact flash on torso
        draw.ellipse(
            (draw_ox - 6, body_top + 10, draw_ox + 6, body_top + 22),
            fill=(*C_ACCENT[:3], 80),
        )


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
    sheet_w = max_frames * 64
    sheet_h = len(anims) * 64
    sheet = Image.new("RGBA", (sheet_w, sheet_h), C_TRANSPARENT)
    regions: dict[str, list[tuple[int, int, int, int]]] = {}

    for row, (name, count) in enumerate(anims.items()):
        regions[name] = []
        for f in range(count):
            frame_img = Image.new("RGBA", (64, 64), C_TRANSPARENT)
            draw = ImageDraw.Draw(frame_img)
            draw_elara_frame(draw, f, name)
            x = f * 64
            y = row * 64
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


def write_sprite_frames_tres(
    tex_path: Path,
    out_path: Path,
    regions: dict[str, list[tuple[int, int, int, int]]],
    speeds: dict[str, float],
    loop_anims: set[str] | None = None,
) -> None:
    if loop_anims is None:
        loop_anims = {"idle", "walk", "fall"}
    lines = [
        '[gd_resource type="SpriteFrames" load_steps=2 format=3]',
        "",
        f'[ext_resource type="Texture2D" path="res://{tex_path.as_posix()}" id="1_tex"]',
        "",
        "[resource]",
        "animations = [",
    ]
    anim_entries = []
    sub_id = 0
    for anim_name, rects in regions.items():
        frames = []
        for x, y, w, h in rects:
            sub_id += 1
            frames.append(
                f'{{"duration": 1.0, "texture": SubResource("AtlasTexture_{sub_id}")}}'
            )
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

    # Insert sub_resources before [resource]
    sub_lines = []
    sub_id = 0
    for anim_name, rects in regions.items():
        for x, y, w, h in rects:
            sub_id += 1
            sub_lines.extend(
                [
                    f'[sub_resource type="AtlasTexture" id="AtlasTexture_{sub_id}"]',
                    "atlas = ExtResource(\"1_tex\")",
                    f"region = Rect2({x}, {y}, {w}, {h})",
                    "",
                ]
            )

    content = (
        '[gd_resource type="SpriteFrames" load_steps='
        + str(1 + sub_id + 1)
        + ' format=3]\n\n'
        + f'[ext_resource type="Texture2D" path="res://{tex_path.as_posix()}" id="1_tex"]\n\n'
        + "\n".join(sub_lines)
        + "[resource]\n"
        + "animations = [\n"
        + ",\n".join(anim_entries)
        + "\n]\n"
    )
    out_path.write_text(content)


def build_enemy_sheet() -> Path:
    """E-01 Ash Wisp — small floating ember creature."""
    frames = 4
    sheet = Image.new("RGBA", (64 * frames, 64), C_TRANSPARENT)
    for f in range(frames):
        frame = Image.new("RGBA", (64, 64), C_TRANSPARENT)
        draw = ImageDraw.Draw(frame)
        bob = int(math.sin(f * 1.5) * 3)
        cx, cy = 32, 36 + bob
        # Wispy body
        draw.ellipse((cx - 14, cy - 16, cx + 14, cy + 10), fill=(*C_MID[:3], 180))
        draw.ellipse((cx - 8, cy - 10, cx + 8, cy + 4), fill=(*C_ACCENT[:3], 200))
        # Eyes
        draw.point((cx - 4, cy - 4), fill=C_SHADOW)
        draw.point((cx + 4, cy - 4), fill=C_SHADOW)
        # Trailing embers
        for i in range(3):
            ex = cx - 6 + i * 6
            ey = cy + 8 + int(math.sin(f + i) * 2)
            draw.point((ex, ey), fill=C_ACCENT)
        sheet.paste(frame, (f * 64, 0))

    out = ASSETS / "sprites/enemies/e01_ash_wisp/e01_sheet.png"
    sheet.save(out)
    write_sprite_frames_tres(
        out.relative_to(GODOT),
        ASSETS / "sprites/enemies/e01_ash_wisp/e01_sheet.tres",
        {"idle": [(i * 64, 0, 64, 64) for i in range(frames)]},
        {"idle": 10.0},
    )
    return out


C_LEAF = (0x38, 0x59, 0x3D, 255)
C_THORN = (0x22, 0x35, 0x24, 255)
C_VINE = (0x52, 0x78, 0x46, 255)


def draw_bramble_frame(draw: ImageDraw.ImageDraw, frame: int, anim: str) -> None:
    """Draw a 64×64 Bramble Stalker frame — low thorny predator."""
    ox, oy = 32, 60
    bob = 0
    leg_l = 0
    leg_r = 0
    lean = 0

    if anim == "idle":
        bob = int(math.sin(frame * 0.8) * 1.5)
    elif anim == "walk":
        bob = int(math.sin(frame * 1.1) * 2)
        leg_l = int(math.sin(frame * 1.1) * 5)
        leg_r = int(math.sin(frame * 1.1 + math.pi) * 5)
        lean = int(math.sin(frame * 1.1) * 2)

    body_top = oy - 26 - bob
    # Legs
    draw.polygon(
        [
            (ox - 10 + leg_l, oy - 8),
            (ox - 4 + leg_l, oy),
            (ox - 8 + leg_l, oy),
        ],
        fill=C_THORN,
    )
    draw.polygon(
        [
            (ox + 4 + leg_r, oy - 8),
            (ox + 10 + leg_r, oy),
            (ox + 6 + leg_r, oy),
        ],
        fill=C_THORN,
    )
    # Hunched body
    draw.polygon(
        [
            (ox - 14 + lean, body_top + 10),
            (ox + 10 + lean, body_top + 6),
            (ox + 12 + lean, oy - 10),
            (ox - 8 + lean, oy - 8),
        ],
        fill=C_LEAF,
        outline=C_THORN,
    )
    # Thorn spikes
    for tx, ty in ((ox - 10 + lean, body_top + 8), (ox + 2 + lean, body_top + 4), (ox + 8 + lean, body_top + 10)):
        draw.polygon([(tx, ty - 6), (tx - 2, ty), (tx + 2, ty)], fill=C_VINE)
    # Head / maw
    head_x = ox + 8 + lean
    head_y = body_top + 8
    draw.ellipse((head_x - 7, head_y - 5, head_x + 7, head_y + 7), fill=C_THORN, outline=C_LEAF)
    draw.line((head_x - 3, head_y + 2, head_x + 5, head_y + 2), fill=C_SHADOW, width=2)
    # Glowing eyes
    draw.point((head_x - 2, head_y), fill=C_ACCENT)
    draw.point((head_x + 2, head_y), fill=C_ACCENT)


def draw_corin_frame(draw: ImageDraw.ImageDraw, frame: int) -> None:
    """Draw a 64×64 Magister Corin frame — weary Conclave mentor silhouette."""
    ox, oy = 32, 62  # feet pivot (matches Elara)
    bob = int(math.sin(frame * 0.65) * 1.0)
    stoop = 3

    coat_top = oy - 34 - bob - stoop
    hem_y = oy - 12 - bob

    # Boots
    draw.rectangle((ox - 8, oy - 6, ox - 1, oy), fill=C_INK, outline=C_SHADOW)
    draw.rectangle((ox + 1, oy - 6, ox + 8, oy), fill=C_INK, outline=C_SHADOW)

    # Long coat hem — faded null-white with ash staining
    draw.polygon(
        [
            (ox - 11, hem_y),
            (ox + 11, hem_y),
            (ox + 9, oy - 6),
            (ox - 9, oy - 6),
        ],
        fill=C_NULL_WHITE,
        outline=C_ASH_GREY,
    )
    draw.line((ox - 8, hem_y + 2, ox + 8, hem_y + 4), fill=C_ASH_GREY, width=1)

    # Inner robe
    draw.rectangle((ox - 7, coat_top + 14, ox + 7, hem_y), fill=C_INK, outline=C_SHADOW)

    # Outer coat panels
    draw.polygon(
        [
            (ox - 12, coat_top + 10),
            (ox - 7, coat_top + 12),
            (ox - 8, hem_y),
            (ox - 13, hem_y - 2),
        ],
        fill=(*C_NULL_WHITE[:3], 230),
        outline=C_ASH_GREY,
    )
    draw.polygon(
        [
            (ox + 12, coat_top + 10),
            (ox + 7, coat_top + 12),
            (ox + 8, hem_y),
            (ox + 13, hem_y - 2),
        ],
        fill=(*C_NULL_WHITE[:3], 230),
        outline=C_ASH_GREY,
    )

    # Null-thread belt
    draw.line((ox - 10, hem_y - 4, ox + 10, hem_y - 3), fill=C_ASH_GREY, width=2)
    draw.line((ox - 9, hem_y - 1, ox - 6, hem_y + 2), fill=C_ASH_GREY, width=1)

    # Head — slight forward stoop
    head_cx = ox + 1
    head_cy = coat_top + 6
    draw.ellipse((head_cx - 7, head_cy - 9, head_cx + 7, head_cy + 5), fill=C_SKIN, outline=C_MID)
    draw.ellipse((head_cx - 6, head_cy - 1, head_cx + 6, head_cy + 6), fill=C_BEARD)

    # Tired eyes
    draw.point((head_cx - 3, head_cy - 2), fill=C_INK)
    draw.point((head_cx + 3, head_cy - 2), fill=C_INK)
    draw.line((head_cx - 4, head_cy - 4, head_cx - 1, head_cy - 3), fill=C_MID, width=1)
    draw.line((head_cx + 1, head_cy - 3, head_cx + 4, head_cy - 4), fill=C_MID, width=1)

    # Cracked focus orb on chain
    chain_y = coat_top + 16
    draw.line((head_cx + 5, head_cy + 2, head_cx + 10, chain_y), fill=C_GOLD, width=1)
    orb_x, orb_y = head_cx + 12, chain_y + 2
    draw.ellipse((orb_x - 4, orb_y - 4, orb_x + 4, orb_y + 4), fill=(*C_CYAN[:3], 180), outline=C_GOLD)
    draw.line((orb_x - 2, orb_y - 1, orb_x + 1, orb_y + 2), fill=C_INK, width=1)


def build_corin_sheet() -> Path:
    """Magister Corin — Threshold mentor NPC."""
    frames = 4
    sheet = Image.new("RGBA", (64 * frames, 64), C_TRANSPARENT)
    regions: dict[str, list[tuple[int, int, int, int]]] = {"idle": []}
    for f in range(frames):
        frame_img = Image.new("RGBA", (64, 64), C_TRANSPARENT)
        draw = ImageDraw.Draw(frame_img)
        draw_corin_frame(draw, f)
        x = f * 64
        sheet.paste(frame_img, (x, 0))
        regions["idle"].append((x, 0, 64, 64))

    out = ASSETS / "sprites/npcs/npc_magister_corin.png"
    sheet.save(out)
    write_sprite_frames_tres(
        out.relative_to(GODOT),
        ASSETS / "sprites/npcs/npc_magister_corin.tres",
        regions,
        {"idle": 6.0},
    )
    return out


def build_bramble_stalker_sheet() -> Path:
    """E-03 Bramble Stalker — thorny ground predator."""
    anims = {"idle": 4, "walk": 6}
    max_frames = max(anims.values())
    sheet_w = max_frames * 64
    sheet_h = len(anims) * 64
    sheet = Image.new("RGBA", (sheet_w, sheet_h), C_TRANSPARENT)
    regions: dict[str, list[tuple[int, int, int, int]]] = {}

    for row, (name, count) in enumerate(anims.items()):
        regions[name] = []
        for f in range(count):
            frame_img = Image.new("RGBA", (64, 64), C_TRANSPARENT)
            draw = ImageDraw.Draw(frame_img)
            draw_bramble_frame(draw, f, name)
            x = f * 64
            y = row * 64
            sheet.paste(frame_img, (x, y))
            regions[name].append((x, y, 64, 64))

    out = ASSETS / "sprites/enemies/e03_bramble_stalker/e03_sheet.png"
    sheet.save(out)
    write_sprite_frames_tres(
        out.relative_to(GODOT),
        ASSETS / "sprites/enemies/e03_bramble_stalker/e03_sheet.tres",
        regions,
        {"idle": 8.0, "walk": 10.0},
    )
    return out


BOSS_FRAME = 96

# Whisperwood Matron palette (docs/03-art-bible.md §8.1)
C_MATRON_DARK = (0x1B, 0x43, 0x32, 255)
C_MATRON_MID = (0x40, 0x91, 0x6C, 255)
C_MATRON_SILK = (0xD8, 0xF3, 0xDC, 255)
C_MATRON_THORN = (0x2D, 0x6A, 0x4F, 255)
C_MATRON_SPORE = (0x74, 0xC6, 0x9D, 255)

# Root Warden palette — ironroot lattice fused magistrate
C_WARDEN_BARK = (0x5C, 0x4A, 0x38, 255)
C_WARDEN_ROOT = (0x3D, 0x5A, 0x42, 255)
C_WARDEN_DARK = (0x2A, 0x22, 0x18, 255)
C_WARDEN_LEY = (0x4A, 0xC8, 0xB8, 255)
C_WARDEN_RUNE = (0xE9, 0xC4, 0x6A, 255)


def _build_creature_sheet(
    out_dir: Path,
    sheet_name: str,
    anims: dict[str, int],
    draw_fn,
    speeds: dict[str, float],
    frame_size: int = BOSS_FRAME,
) -> Path:
    max_frames = max(anims.values())
    sheet_w = max_frames * frame_size
    sheet_h = len(anims) * frame_size
    sheet = Image.new("RGBA", (sheet_w, sheet_h), C_TRANSPARENT)
    regions: dict[str, list[tuple[int, int, int, int]]] = {}

    for row, (name, count) in enumerate(anims.items()):
        regions[name] = []
        for f in range(count):
            frame_img = Image.new("RGBA", (frame_size, frame_size), C_TRANSPARENT)
            draw = ImageDraw.Draw(frame_img)
            draw_fn(draw, f, name, frame_size)
            x = f * frame_size
            y = row * frame_size
            sheet.paste(frame_img, (x, y))
            regions[name].append((x, y, frame_size, frame_size))

    out = out_dir / f"{sheet_name}.png"
    sheet.save(out)
    write_sprite_frames_tres(
        out.relative_to(GODOT),
        out_dir / f"{sheet_name}.tres",
        regions,
        speeds,
        loop_anims={"idle"},
    )
    return out


def draw_matron_frame(draw: ImageDraw.ImageDraw, frame: int, anim: str, size: int) -> None:
    """MB-01 Thornweft Matron — bloated silk moth with thorn legs."""
    ox, oy = size // 2, size - 10
    bob = int(math.sin(frame * 0.7) * 2)
    wing_spread = 0
    lash = 0
    glow = 0.5 + 0.5 * math.sin(frame * 0.9)
    body_color = C_MATRON_MID
    silk_alpha = 180

    if anim == "idle":
        wing_spread = int(4 + math.sin(frame * 1.1) * 3)
    elif anim == "attack":
        lash = min(frame * 14, 42)
        wing_spread = 6
        bob = -2 if frame >= 2 else 0
    elif anim == "telegraph":
        glow = 0.7 + 0.3 * math.sin(frame * 1.6)
        wing_spread = 10 + frame * 2
        body_color = C_MATRON_SPORE
    elif anim == "phase2":
        wing_spread = 14
        body_color = (0x52, 0xA3, 0x6F, 255)
        silk_alpha = 220
        bob = int(math.sin(frame * 1.4) * 3)

    body_top = oy - 58 - bob
    body_w = 34
    body_h = 40

    # Thorn legs
    for side, phase in ((-1, 0.0), (1, math.pi * 0.5)):
        lx = ox + side * (body_w // 2 + 4)
        ly = oy - 18 - bob
        knee_y = ly + 14 + int(math.sin(frame * 1.2 + phase) * 3)
        draw.line((lx, ly, lx + side * 10, knee_y, lx + side * 6, oy - 6), fill=C_MATRON_THORN, width=3)
        draw.polygon(
            [(lx + side * 6, oy - 8), (lx + side * 10, oy - 2), (lx + side * 2, oy - 2)],
            fill=C_MATRON_DARK,
        )

    # Silk wing membranes
    for side in (-1, 1):
        wx = ox + side * (14 + wing_spread)
        draw.polygon(
            [
                (ox + side * 8, body_top + 8),
                (wx, body_top - 6),
                (wx + side * 8, body_top + 22),
                (ox + side * 10, body_top + 30),
            ],
            fill=(*C_MATRON_SILK[:3], silk_alpha),
            outline=C_MATRON_MID,
        )

    # Bloated abdomen
    draw.ellipse(
        (ox - body_w // 2, body_top + 10, ox + body_w // 2, body_top + body_h + 10),
        fill=body_color,
        outline=C_MATRON_DARK,
    )
    # Thorax / head bulb
    draw.ellipse(
        (ox - 14, body_top - 6, ox + 14, body_top + 18),
        fill=C_MATRON_MID,
        outline=C_MATRON_THORN,
    )
    # Spore core
    core_r = 5 + int(glow * 3)
    draw.ellipse(
        (ox - core_r, body_top + 20 - core_r, ox + core_r, body_top + 20 + core_r),
        fill=(*C_MATRON_SPORE[:3], int(120 + glow * 100)),
    )
    # Eyes
    draw.point((ox - 5, body_top + 4), fill=C_MATRON_SILK)
    draw.point((ox + 5, body_top + 4), fill=C_MATRON_SILK)

    if lash > 0:
        draw.line((ox + 16, body_top + 24, ox + 16 + lash, body_top + 30), fill=C_VINE, width=4)
        for i in range(3):
            tx = ox + 20 + lash - i * 8
            draw.polygon([(tx, body_top + 26), (tx - 2, body_top + 32), (tx + 2, body_top + 32)], fill=C_MATRON_THORN)


def draw_warden_frame(draw: ImageDraw.ImageDraw, frame: int, anim: str, size: int) -> None:
    """BOSS-01 Root Warden — root-lattice fused mine magistrate."""
    ox, oy = size // 2, size - 8
    bob = int(math.sin(frame * 0.6) * 1.5)
    spear = 0
    pull_glow = 0.4
    body_color = C_WARDEN_BARK
    root_color = C_WARDEN_ROOT
    ley_alpha = 160

    if anim == "idle":
        pull_glow = 0.45 + 0.35 * math.sin(frame * 0.8)
    elif anim == "attack":
        spear = min(frame * 18, 48)
        bob = -1 if frame >= 2 else 0
    elif anim == "telegraph":
        pull_glow = 0.75 + 0.25 * math.sin(frame * 1.8)
        body_color = (0x6A, 0x58, 0x44, 255)
    elif anim == "phase2":
        body_color = C_WARDEN_ROOT
        root_color = (0x2E, 0x6B, 0x55, 255)
        ley_alpha = 200
        pull_glow = 0.8
    elif anim == "phase3":
        body_color = (0x34, 0x2C, 0x24, 255)
        root_color = (0x5A, 0x38, 0x72, 255)
        pull_glow = 0.95

    torso_top = oy - 54 - bob

    # Root tendrils anchoring to ground
    for side, phase in ((-1, 0.0), (1, 1.2)):
        base_x = ox + side * 22
        sway = int(math.sin(frame * 0.9 + phase) * 4)
        draw.line((base_x, oy - 4, base_x + sway, oy - 20, base_x + side * 6, oy - 36), fill=root_color, width=4)
        draw.ellipse((base_x + side * 4 - 3, oy - 40, base_x + side * 4 + 3, oy - 34), fill=C_WARDEN_LEY)

    # Heavy torso fused with roots
    draw.polygon(
        [
            (ox - 20, torso_top + 28),
            (ox + 20, torso_top + 28),
            (ox + 16, oy - 10),
            (ox - 16, oy - 10),
        ],
        fill=body_color,
        outline=C_WARDEN_DARK,
    )
    # Shoulder lattice plates
    draw.rectangle((ox - 24, torso_top + 6, ox - 10, torso_top + 20), fill=root_color, outline=C_WARDEN_DARK)
    draw.rectangle((ox + 10, torso_top + 6, ox + 24, torso_top + 20), fill=root_color, outline=C_WARDEN_DARK)
    # Head / helm silhouette
    draw.rectangle((ox - 12, torso_top - 8, ox + 12, torso_top + 10), fill=C_WARDEN_DARK, outline=root_color)
    draw.rectangle((ox - 8, torso_top - 2, ox + 8, torso_top + 4), fill=(*C_WARDEN_LEY[:3], ley_alpha))
    # Ley core
    core_r = 4 + int(pull_glow * 4)
    draw.ellipse(
        (ox - core_r, torso_top + 14 - core_r, ox + core_r, torso_top + 14 + core_r),
        fill=(*C_WARDEN_LEY[:3], int(100 + pull_glow * 120)),
    )
    # Rune scars
    draw.line((ox - 6, torso_top + 22, ox + 6, torso_top + 30), fill=C_WARDEN_RUNE, width=2)
    draw.line((ox, torso_top + 18, ox, torso_top + 34), fill=C_WARDEN_RUNE, width=2)

    if spear > 0:
        tip_x = ox + 18 + spear
        draw.line((ox + 14, torso_top + 16, tip_x, torso_top + 20), fill=root_color, width=5)
        draw.polygon([(tip_x, torso_top + 16), (tip_x + 10, torso_top + 20), (tip_x, torso_top + 24)], fill=C_WARDEN_LEY)


def build_thornweft_matron_sheet() -> Path:
    """MB-01 Thornweft Matron — 96px boss sprite sheet."""
    out_dir = ASSETS / "sprites/bosses/mb_01_thornweft_matron"
    return _build_creature_sheet(
        out_dir,
        "mb_01_sheet",
        {"idle": 6, "attack": 5, "telegraph": 4, "phase2": 6},
        draw_matron_frame,
        {"idle": 10.0, "attack": 12.0, "telegraph": 8.0, "phase2": 10.0},
    )


def build_root_warden_sheet() -> Path:
    """BOSS-01 Root Warden — 96px boss sprite sheet."""
    out_dir = ASSETS / "sprites/bosses/boss_01_root_warden"
    return _build_creature_sheet(
        out_dir,
        "boss_01_sheet",
        {"idle": 6, "attack": 5, "telegraph": 4, "phase2": 4, "phase3": 4},
        draw_warden_frame,
        {"idle": 10.0, "attack": 12.0, "telegraph": 8.0, "phase2": 10.0, "phase3": 10.0},
    )


def build_tileset() -> Path:
    """64×64 tiles — stone floor, wall, platform top, accent rune."""
    tiles = Image.new("RGBA", (64 * 4, 64), C_TRANSPARENT)
    specs = [
        ("floor", _draw_floor_tile),
        ("wall", _draw_wall_tile),
        ("platform", _draw_platform_tile),
        ("accent", _draw_accent_tile),
    ]
    for i, (_, fn) in enumerate(specs):
        tile = Image.new("RGBA", (64, 64), C_TRANSPARENT)
        fn(ImageDraw.Draw(tile))
        tiles.paste(tile, (i * 64, 0))
    out = ASSETS / "sprites/tilesets/01_ashen_threshold/tileset.png"
    tiles.save(out)
    return out


def _draw_floor_tile(draw: ImageDraw.ImageDraw) -> None:
    draw.rectangle((0, 0, 63, 63), fill=C_BASE)
    for y in range(8, 64, 12):
        draw.line((0, y, 63, y), fill=C_SHADOW, width=1)
    for x in range(4, 64, 16):
        draw.line((x, 0, x, 63), fill=C_MID, width=1)
    # Ash specks
    random.seed(1)
    for _ in range(12):
        px, py = random.randint(2, 61), random.randint(2, 61)
        draw.point((px, py), fill=(*C_WARM[:3], 80))


def _draw_wall_tile(draw: ImageDraw.ImageDraw) -> None:
    draw.rectangle((0, 0, 63, 63), fill=C_SHADOW)
    for y in range(0, 64, 16):
        draw.rectangle((2, y + 2, 61, y + 14), fill=C_BASE, outline=C_MID)
    draw.line((0, 0, 63, 0), fill=C_MID, width=2)


def _draw_platform_tile(draw: ImageDraw.ImageDraw) -> None:
    draw.rectangle((0, 20, 63, 63), fill=C_BASE, outline=C_MID)
    draw.rectangle((0, 16, 63, 22), fill=C_MID, outline=C_WARM)
    for x in range(4, 64, 8):
        draw.point((x, 18), fill=C_ACCENT)


def _draw_accent_tile(draw: ImageDraw.ImageDraw) -> None:
    draw.rectangle((0, 0, 63, 63), fill=C_SHADOW)
    # Faded rune
    cx, cy = 32, 32
    draw.ellipse((cx - 12, cy - 12, cx + 12, cy + 12), outline=C_ACCENT, width=1)
    draw.line((cx, cy - 8, cx, cy + 8), fill=(*C_ACCENT[:3], 120))
    draw.line((cx - 8, cy, cx + 8, cy), fill=(*C_ACCENT[:3], 120))


def _blend_rgb(a: tuple, b: tuple, t: float) -> tuple[int, int, int]:
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def _draw_vertical_gradient(
    draw: ImageDraw.ImageDraw, width: int, height: int, top: tuple, bottom: tuple, *, power: float = 1.0
) -> None:
    for y in range(height):
        t = (y / max(height - 1, 1)) ** power
        color = _blend_rgb(top[:3], bottom[:3], t)
        draw.line((0, y, width - 1, y), fill=(*color, 255))


def _draw_scatter_glow(
    draw: ImageDraw.ImageDraw,
    width: int,
    height: int,
    rng: random.Random,
    count: int,
    color: tuple,
    y_range: tuple[int, int],
    sizes: tuple[int, ...] = (1, 1, 2, 2, 3),
) -> None:
    for _ in range(count):
        x = rng.randint(0, width - 1)
        y = rng.randint(y_range[0], y_range[1])
        size = rng.choice(sizes)
        alpha = rng.randint(18, 110)
        draw.ellipse((x, y, x + size, y + size), fill=(*color[:3], alpha))


def _draw_ash_ruin_silhouette(draw: ImageDraw.ImageDraw, x: int, base_y: int, rng: random.Random) -> None:
    kind = rng.choice(("arch", "tower", "wall", "spire"))
    if kind == "arch":
        w, h = rng.randint(56, 96), rng.randint(110, 190)
        left, right = x, x + w
        top = base_y - h
        draw.rectangle((left + 8, top + 24, right - 8, base_y), fill=(*C_BASE[:3], 210))
        draw.polygon(
            [(left, top + 24), (left + w // 2, top), (right, top + 24)],
            fill=(*C_SHADOW[:3], 220),
        )
        gap_w = max(18, w // 3)
        draw.rectangle(
            (left + (w - gap_w) // 2, top + 34, left + (w + gap_w) // 2, base_y - 8),
            fill=C_TRANSPARENT,
        )
        if rng.random() > 0.35:
            glow_x = left + w // 2
            draw.ellipse((glow_x - 6, top + 42, glow_x + 6, top + 54), fill=(*C_ACCENT[:3], 70))
    elif kind == "tower":
        w, h = rng.randint(34, 58), rng.randint(140, 240)
        left, top = x, base_y - h
        draw.rectangle((left, top + 18, left + w, base_y), fill=(*C_SHADOW[:3], 215))
        for notch in range(rng.randint(2, 4)):
            nx = left + rng.randint(0, max(w - 10, 1))
            draw.polygon(
                [(nx, top + notch * 16), (nx + 8, top + notch * 16 + 10), (nx + 16, top + notch * 16)],
                fill=(*C_BASE[:3], 180),
            )
        draw.rectangle((left + 8, top + 48, left + w - 8, top + 64), fill=(*C_ACCENT[:3], 45))
    elif kind == "wall":
        w, h = rng.randint(90, 150), rng.randint(70, 120)
        left, top = x, base_y - h
        draw.rectangle((left, top, left + w, base_y), fill=(*C_BASE[:3], 195))
        for crack_x in range(left + 12, left + w - 12, rng.randint(18, 28)):
            draw.line((crack_x, top + 8, crack_x + rng.randint(-6, 6), base_y - 6), fill=(*C_MID[:3], 90), width=1)
    else:
        w, h = rng.randint(24, 40), rng.randint(180, 280)
        left, top = x, base_y - h
        draw.rectangle((left, top, left + w, base_y), fill=(*C_SHADOW[:3], 205))
        draw.polygon(
            [(left - 4, top + 20), (left + w // 2, top - 8), (left + w + 4, top + 20)],
            fill=(*C_BASE[:3], 190),
        )


def _draw_ley_pavement(draw: ImageDraw.ImageDraw, width: int, base_y: int) -> None:
    draw.line((0, base_y, width - 1, base_y), fill=(*C_MID[:3], 120), width=2)
    for x in range(0, width, 64):
        draw.line((x, base_y - 10, x + 32, base_y - 2), fill=(*C_GOLD[:3], 35), width=1)
        draw.ellipse((x + 14, base_y - 6, x + 18, base_y - 2), fill=(*C_ACCENT[:3], 55))


def _draw_mist_band(
    draw: ImageDraw.ImageDraw,
    width: int,
    y0: int,
    y1: int,
    color: tuple,
    alpha_base: int,
    wave_scale: float,
) -> None:
    for y in range(y0, y1):
        wave = (math.sin(y * wave_scale) + math.sin(y * wave_scale * 0.37 + 1.4)) * 0.5
        alpha = int(alpha_base + 28 * wave)
        draw.line((0, y, width - 1, y), fill=(*color[:3], max(8, alpha)))


def build_parallax() -> list[Path]:
    outputs = []
    rng = random.Random(7)
    w, h = 960, 540
    base_y = h - 64

    sky = Image.new("RGBA", (w, h), C_SHADOW)
    draw = ImageDraw.Draw(sky)
    _draw_vertical_gradient(draw, w, h, (0x0E, 0x0E, 0x18), C_SHADOW[:3], power=0.75)
    horizon = Image.new("RGBA", (w, h), C_TRANSPARENT)
    h_draw = ImageDraw.Draw(horizon)
    for y in range(int(h * 0.45), h):
        t = (y - h * 0.45) / (h * 0.55)
        alpha = int(35 + 90 * t)
        h_draw.line((0, y, w - 1, y), fill=(*C_WARM[:3], alpha))
    sky = Image.alpha_composite(sky, horizon)
    draw = ImageDraw.Draw(sky)
    _draw_scatter_glow(draw, w, h, rng, 90, C_ACCENT, (40, int(h * 0.72)))
    _draw_scatter_glow(draw, w, h, rng, 24, C_GOLD, (80, int(h * 0.55)), sizes=(1, 2))
    p0 = ASSETS / "sprites/tilesets/01_ashen_threshold/parallax_0_sky.png"
    sky.save(p0)
    outputs.append(p0)

    ruins = Image.new("RGBA", (w, h), C_TRANSPARENT)
    draw = ImageDraw.Draw(ruins)
    x = -40
    while x < w + 40:
        _draw_ash_ruin_silhouette(draw, x, base_y, rng)
        x += rng.randint(70, 130)
    _draw_ley_pavement(draw, w, base_y - 2)
    p1 = ASSETS / "sprites/tilesets/01_ashen_threshold/parallax_1_far_ruins.png"
    ruins.save(p1)
    outputs.append(p1)

    fog = Image.new("RGBA", (w, h), C_TRANSPARENT)
    draw = ImageDraw.Draw(fog)
    _draw_mist_band(draw, w, 250, 430, C_MID, 34, 0.06)
    _draw_mist_band(draw, w, 300, 500, C_BASE, 22, 0.09)
    for x in range(0, w, 140):
        draw.ellipse((x, 360, x + 180, 430), fill=(*C_MID[:3], 18))
    p2 = ASSETS / "sprites/tilesets/01_ashen_threshold/parallax_2_mid_fog.png"
    fog.save(p2)
    outputs.append(p2)

    near = Image.new("RGBA", (w, h), C_TRANSPARENT)
    draw = ImageDraw.Draw(near)
    for side, offset in (("left", 0), ("right", w - 120)):
        for i in range(3):
            px = offset + i * 28
            pillar_h = 180 + i * 24
            draw.rectangle((px, base_y - pillar_h, px + 18, base_y), fill=(*C_SHADOW[:3], 170))
            draw.line((px + 9, base_y - pillar_h, px + 9, base_y - pillar_h + 40), fill=(*C_ACCENT[:3], 50), width=1)
    for cx in range(120, w, 220):
        draw.line((cx, 40, cx - 8, 150), fill=(*C_BASE[:3], 80), width=1)
        draw.ellipse((cx - 12, 146, cx - 4, 154), fill=(*C_ACCENT[:3], 60))
    p3 = ASSETS / "sprites/tilesets/01_ashen_threshold/parallax_3_near_occluders.png"
    near.save(p3)
    outputs.append(p3)

    vignette = Image.new("RGBA", (w, h), C_TRANSPARENT)
    draw = ImageDraw.Draw(vignette)
    for y in range(h):
        edge = min(y, h - y, y // 2, (h - y) // 2)
        alpha = int(max(0, 90 - edge * 0.45))
        if alpha > 0:
            draw.line((0, y, w - 1, y), fill=(0, 0, 0, alpha))
    for x in range(w):
        edge = min(x, w - x)
        alpha = int(max(0, 70 - edge * 0.18))
        if alpha > 0:
            draw.line((x, 0, x, h - 1), fill=(0, 0, 0, alpha))
    vignette_path = ASSETS / "sprites/ui/vignette_overlay.png"
    vignette.save(vignette_path)
    outputs.append(vignette_path)

    return outputs


def _draw_hollow_tree(draw: ImageDraw.ImageDraw, x: int, base_y: int, rng: random.Random) -> None:
    w = rng.randint(36, 64)
    h = rng.randint(180, 320)
    top = base_y - h
    draw.rectangle((x, top + 40, x + w, base_y), fill=(0x14, 0x22, 0x12, 215))
    draw.ellipse((x + w // 2 - 16, top + 18, x + w // 2 + 16, top + 52), fill=(0x0A, 0x12, 0x08, 230))
    draw.ellipse((x + w // 2 - 8, top + 28, x + w // 2 + 8, top + 44), fill=(0x52, 0x8A, 0x44, 55))
    for branch_y in range(top + 60, base_y - 40, rng.randint(40, 70)):
        direction = rng.choice((-1, 1))
        draw.line((x + w // 2, branch_y, x + w // 2 + direction * rng.randint(24, 48), branch_y - 12), fill=(0x1E, 0x34, 0x18, 170), width=2)
    if rng.random() > 0.4:
        spore_y = top + rng.randint(50, h - 40)
        draw.ellipse((x + w + 4, spore_y, x + w + 12, spore_y + 8), fill=(*C_VINE[:3], 90))


def build_whisperwood_parallax() -> list[Path]:
    outputs = []
    rng = random.Random(19)
    w, h = 960, 540
    base_y = h - 64
    forest_top = (0x08, 0x12, 0x08)
    forest_horizon = (0x12, 0x24, 0x14)

    sky = Image.new("RGBA", (w, h), forest_top + (255,))
    draw = ImageDraw.Draw(sky)
    _draw_vertical_gradient(draw, w, h, forest_top, forest_horizon, power=0.8)
    _draw_scatter_glow(draw, w, h, rng, 70, C_VINE, (60, int(h * 0.75)))
    _draw_scatter_glow(draw, w, h, rng, 18, (0xA8, 0xE8, 0xB8, 255), (100, int(h * 0.55)), sizes=(1, 2, 3))
    p0 = ASSETS / "sprites/tilesets/02_whisperwood_hollow/parallax_0_sky.png"
    sky.save(p0)
    outputs.append(p0)

    trees = Image.new("RGBA", (w, h), C_TRANSPARENT)
    draw = ImageDraw.Draw(trees)
    x = -20
    while x < w + 20:
        _draw_hollow_tree(draw, x, base_y, rng)
        x += rng.randint(80, 140)
    p1 = ASSETS / "sprites/tilesets/02_whisperwood_hollow/parallax_1_far_trees.png"
    trees.save(p1)
    outputs.append(p1)

    canopy = Image.new("RGBA", (w, h), C_TRANSPARENT)
    draw = ImageDraw.Draw(canopy)
    for cx in range(-40, w + 80, 90):
        crown_w = rng.randint(100, 160)
        crown_h = rng.randint(50, 90)
        top = 120 + rng.randint(-20, 30)
        draw.ellipse((cx, top, cx + crown_w, top + crown_h), fill=(0x1A, 0x32, 0x1C, 150))
        draw.ellipse((cx + 20, top + 10, cx + crown_w - 10, top + crown_h - 8), fill=(0x2A, 0x4A, 0x28, 110))
    p2 = ASSETS / "sprites/tilesets/02_whisperwood_hollow/parallax_2_mid_canopy.png"
    canopy.save(p2)
    outputs.append(p2)

    spores = Image.new("RGBA", (w, h), C_TRANSPARENT)
    draw = ImageDraw.Draw(spores)
    _draw_mist_band(draw, w, 280, 470, C_LEAF_DARK, 28, 0.05)
    _draw_mist_band(draw, w, 330, 520, C_VINE, 18, 0.08)
    for _ in range(16):
        vx = rng.randint(0, w)
        vy = rng.randint(200, 430)
        draw.line((vx, vy, vx + rng.randint(-8, 8), vy + rng.randint(30, 70)), fill=(*C_VINE[:3], 55), width=1)
    p3 = ASSETS / "sprites/tilesets/02_whisperwood_hollow/parallax_3_spore_fog.png"
    spores.save(p3)
    outputs.append(p3)

    return outputs


# --- Audio synthesis ---

def _write_wav(path: Path, samples: list[float]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        frames = b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767 * 0.85)) for s in samples
        )
        wf.writeframes(frames)


def _to_ogg(wav_path: Path, *, keep_wav: bool = False) -> Path:
    ogg_path = wav_path.with_suffix(".ogg")
    subprocess.run(
        [
            "ffmpeg", "-y", "-i", str(wav_path),
            "-c:a", "vorbis", "-q:a", "5",
            str(ogg_path),
        ],
        capture_output=True,
        check=True,
    )
    if not keep_wav:
        wav_path.unlink(missing_ok=True)
    return ogg_path


def _sine(freq: float, t: float, amp: float = 1.0) -> float:
    return amp * math.sin(2 * math.pi * freq * t)


def _noise(t: float, seed: int = 0) -> float:
    random.seed(int(t * 10000) + seed)
    return random.uniform(-1, 1)


def gen_ambient_threshold() -> Path:
    duration = 8.0
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Low drone + ember crackle + wind
        s = (
            _sine(55, t, 0.15)
            + _sine(82.5, t, 0.08)
            + _noise(t, 1) * 0.03 * (0.5 + 0.5 * math.sin(t * 2))
            + _sine(220, t, 0.02) * math.sin(t * 0.3)
        )
        # Seamless loop crossfade
        fade = 1.0
        if t < 0.05:
            fade = t / 0.05
        elif t > duration - 0.05:
            fade = (duration - t) / 0.05
        samples.append(s * fade)
    wav = ASSETS / "audio/ambient/amb_01_threshold.wav"
    _write_wav(wav, samples)
    return wav


def gen_footstep(name: str, base_freq: float, seed: int) -> Path:
    duration = 0.12
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 35)
        s = (_sine(base_freq, t, 0.4) + _noise(t, seed) * 0.5) * env
        samples.append(s * 0.6)
    wav = ASSETS / "audio/sfx/footsteps" / f"{name}.wav"
    _write_wav(wav, samples)
    return wav


def gen_ui_sound(name: str, freq_start: float, freq_end: float, dur: float = 0.08) -> Path:
    n = int(SAMPLE_RATE * dur)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        f = freq_start + (freq_end - freq_start) * (t / dur)
        env = math.exp(-t * 20)
        samples.append(_sine(f, t, 0.5) * env)
    wav = ASSETS / "audio/sfx/ui" / f"{name}.wav"
    _write_wav(wav, samples)
    return wav


def gen_spell_sfx(spell_id: str, phase: str) -> Path:
    """Procedural cast/impact placeholder for a spell."""
    duration = 0.2 if phase == "cast" else 0.14
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * (10 if phase == "cast" else 16))
        if spell_id in ("ember_sigil", "ember_bolt"):
            base = 300 if spell_id == "ember_sigil" else 460
            sweep = 500 if phase == "cast" else -220
            s = _sine(base + t * sweep, t, 0.45) * env + _noise(t, 1) * 0.22 * env
        elif spell_id == "rootbind":
            s = (_sine(150 + t * 140, t, 0.35) + _sine(75, t, 0.2)) * env
        elif spell_id in ("veil_step", "arc_step"):
            base = 540 if spell_id == "veil_step" else 760
            sweep = -base * 1.6 if phase == "cast" else -base * 0.5
            s = (_sine(base + t * sweep, t, 0.4) + _sine(base * 1.5, t, 0.12)) * env
        elif spell_id == "rune_anchor":
            s = _sine(260 + math.sin(t * 36) * 50, t, 0.35) * env
            if phase == "impact":
                s += _sine(520, t, 0.2) * math.exp(-t * 22)
        else:
            s = _sine(440, t, 0.3) * env
        samples.append(s * 0.7)
    wav = ASSETS / "audio/sfx/spells" / f"sfx_{spell_id}_{phase}.wav"
    _write_wav(wav, samples)
    return wav


def gen_player_sfx(name: str, kind: str) -> Path:
    duration = {
        "dash": 0.25,
        "jump": 0.15,
        "land": 0.1,
        "hurt": 0.2,
        "melee_swipe_1": 0.12,
        "melee_swipe_2": 0.1,
        "melee_swipe_3": 0.16,
        "melee_hit": 0.08,
    }.get(kind, 0.15)
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        if kind == "dash":
            s = _sine(300 + t * 800, t, 0.4) * math.exp(-t * 8) + _noise(t, 3) * 0.2
        elif kind == "jump":
            s = _sine(180 + t * 400, t, 0.5) * math.exp(-t * 12)
        elif kind == "land":
            s = (_sine(90, t, 0.5) + _noise(t, 4) * 0.3) * math.exp(-t * 25)
        elif kind == "hurt":
            s = _sine(140 - t * 200, t, 0.4) * math.exp(-t * 10)
        elif kind == "melee_swipe_1":
            s = (_sine(420 + t * 600, t, 0.35) + _noise(t, 5) * 0.15) * math.exp(-t * 18)
        elif kind == "melee_swipe_2":
            s = (_sine(520 + t * 900, t, 0.3) + _noise(t, 6) * 0.2) * math.exp(-t * 22)
        elif kind == "melee_swipe_3":
            s = (_sine(280, t, 0.45) + _sine(640 + t * 400, t, 0.25) + _noise(t, 8) * 0.25) * math.exp(-t * 14)
        elif kind == "melee_hit":
            s = (_sine(180, t, 0.5) + _noise(t, 10) * 0.35) * math.exp(-t * 35)
        else:
            s = 0.0
        samples.append(s)
    wav = ASSETS / "audio/sfx/player" / f"{name}.wav"
    _write_wav(wav, samples)
    return wav


def gen_ambient_whisperwood() -> Path:
    duration = 10.0
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Canopy wind + spore shimmer + soft insect pulse
        s = (
            _sine(82.41, t, 0.1)
            + _sine(110.0, t, 0.06) * (0.6 + 0.4 * math.sin(t * 0.17))
            + _noise(t, 2) * 0.025 * (0.5 + 0.5 * math.sin(t * 1.3))
            + _sine(880, t, 0.015) * max(0.0, math.sin(t * 5.5)) ** 4
            + _sine(1320, t, 0.01) * max(0.0, math.sin(t * 7.1 + 1.2)) ** 6
        )
        fade = 1.0
        if t < 0.05:
            fade = t / 0.05
        elif t > duration - 0.05:
            fade = (duration - t) / 0.05
        samples.append(s * fade)
    wav = ASSETS / "audio/ambient/amb_02_whisperwood.wav"
    _write_wav(wav, samples)
    return wav


def gen_music_threshold() -> Path:
    """Simple D-minor melancholic loop — mus_01_threshold."""
    duration = 16.0
    n = int(SAMPLE_RATE * duration)
    # D minor pentatonic: D E F A C
    notes = [293.66, 329.63, 349.23, 440.0, 523.25]  # D4 E4 F4 A4 C5
    melody = [0, 2, 1, 3, 2, 4, 3, 1, 0, 2, 4, 3, 2, 1, 0, 0]
    beat = duration / len(melody)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        mi = int(t / beat) % len(melody)
        freq = notes[melody[mi]]
        local_t = t % beat
        env = min(1.0, local_t * 6) * (0.35 + 0.65 * math.exp(-local_t * 0.35))
        s = (
            _sine(freq, t, 0.22 * env)
            + _sine(freq * 0.5, t, 0.14)
            + _sine(55, t, 0.12)
            + _sine(82.5, t, 0.08)
        )
        fade = 1.0
        if t < 0.02:
            fade = t / 0.02
        elif t > duration - 0.02:
            fade = (duration - t) / 0.02
        samples.append(s * fade)
    wav = ASSETS / "audio/music/mus_01_threshold.wav"
    _write_wav(wav, samples)
    return wav


def gen_music_whisperwood() -> Path:
    """E-minor organic forest loop — mus_02_whisperwood."""
    duration = 20.0
    n = int(SAMPLE_RATE * duration)
    # E minor pentatonic: E G A B D
    notes = [164.81, 196.0, 220.0, 246.94, 293.66]  # E3 G3 A3 B3 D4
    melody = [0, 2, 4, 2, 1, 0, 3, 2, 4, 3, 1, 0, 2, 1, 4, 3, 2, 1, 0, 0]
    beat = duration / len(melody)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        mi = int(t / beat) % len(melody)
        freq = notes[melody[mi]]
        local_t = t % beat
        env = min(1.0, local_t * 5) * (0.3 + 0.7 * math.exp(-local_t * 0.3))
        shimmer = _sine(660 + math.sin(t * 2.8) * 40, t, 0.05) * (0.4 + 0.6 * math.sin(t * 0.9))
        s = (
            _sine(freq, t, 0.2 * env)
            + _sine(freq * 1.5, t, 0.1 * env)
            + _sine(82.41, t, 0.12)
            + _sine(110.0, t, 0.08) * (0.5 + 0.5 * math.sin(t * 0.25))
            + shimmer
        )
        fade = 1.0
        if t < 0.03:
            fade = t / 0.03
        elif t > duration - 0.03:
            fade = (duration - t) / 0.03
        samples.append(s * fade)
    wav = ASSETS / "audio/music/mus_02_whisperwood.wav"
    _write_wav(wav, samples)
    return wav


def gen_music_game_over() -> Path:
    """Slow D-minor death screen loop — mus_game_over."""
    duration = 24.0
    n = int(SAMPLE_RATE * duration)
    # D minor: D E F G A Bb C
    notes = [146.83, 164.81, 174.61, 196.0, 220.0, 233.08, 261.63]  # D3..D4
    melody = [0, 2, 1, 0, 3, 2, 1, 0, 4, 3, 2, 1, 0, 5, 4, 3, 2, 1, 0, 0, 1, 2, 1, 0]
    beat = duration / len(melody)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        mi = int(t / beat) % len(melody)
        freq = notes[melody[mi]]
        local_t = t % beat
        env = min(1.0, local_t * 4) * math.exp(-local_t * 0.8)
        s = (
            _sine(freq, t, 0.14 * env)
            + _sine(freq * 0.5, t, 0.06 * env)
            + _sine(73.42, t, 0.05)
            + _sine(110.0, t, 0.03) * (0.5 + 0.5 * math.sin(t * 0.4))
        )
        fade = 1.0
        if t < 0.05:
            fade = t / 0.05
        elif t > duration - 0.05:
            fade = (duration - t) / 0.05
        samples.append(s * fade)
    wav = ASSETS / "audio/music/mus_game_over.wav"
    _write_wav(wav, samples)
    return wav


def gen_sfx_game_over() -> Path:
    """Short D-minor death sting — sfx_game_over."""
    duration = 2.4
    n = int(SAMPLE_RATE * duration)
    notes = [293.66, 261.63, 233.08, 196.0, 146.83]  # D4 down to D3
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        seg = min(int(t / (duration / len(notes))), len(notes) - 1)
        local_t = t - seg * (duration / len(notes))
        freq = notes[seg]
        env = math.exp(-local_t * 3.5) * (1.0 - t / duration)
        s = (
            _sine(freq, t, 0.22 * env)
            + _sine(freq * 0.5, t, 0.1 * env)
            + _sine(73.42, t, 0.06) * math.exp(-t * 0.6)
        )
        if t < 0.02:
            s *= t / 0.02
        samples.append(s)
    wav = ASSETS / "audio/sfx/ui/sfx_game_over.wav"
    _write_wav(wav, samples)
    return wav


def gen_stinger_main_menu() -> Path:
    duration = 3.0
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        s = (
            _sine(440, t, 0.2) * math.exp(-t * 1.2)
            + _sine(660, t, 0.15) * math.exp(-(t - 0.3) * 2) * (1 if t > 0.3 else 0)
            + _sine(880, t, 0.1) * math.exp(-(t - 0.6) * 3) * (1 if t > 0.6 else 0)
        )
        samples.append(s)
    wav = ASSETS / "audio/music/mus_stinger_main_menu.wav"
    _write_wav(wav, samples)
    return wav


def _lerp_color(c1: tuple, c2: tuple, t: float) -> tuple:
    t = max(0.0, min(1.0, t))
    return tuple(int(c1[i] + (c2[i] - c1[i]) * t) for i in range(3)) + (255,)


def _draw_spell_icon(draw: ImageDraw.ImageDraw, spell_id: str) -> None:
    """Draw a 48×48 spell wheel icon."""
    cx, cy = 24, 24
    outline = C_SHADOW

    if spell_id == "ember_sigil":
        pts = [(cx, 8), (cx + 14, cy + 4), (cx + 10, cy + 18), (cx - 10, cy + 18), (cx - 14, cy + 4)]
        draw.polygon(pts, fill=C_ACCENT, outline=outline)
        draw.ellipse((cx - 6, cy - 4, cx + 6, cy + 8), fill=C_YELLOW, outline=C_WARM)
        for i in range(4):
            angle = i * math.pi / 2 + 0.3
            ex = cx + int(math.cos(angle) * 10)
            ey = cy + int(math.sin(angle) * 8)
            draw.point((ex, ey), fill=C_YELLOW)

    elif spell_id == "veil_step":
        draw.ellipse((cx - 12, cy - 14, cx + 12, cy + 14), fill=(*C_PURPLE[:3], 140), outline=outline)
        draw.rectangle((cx - 1, 6, cx + 1, 42), fill=(255, 255, 255, 200))
        for dy in range(8, 40, 4):
            draw.point((cx - 4, dy), fill=(*C_CYAN[:3], 120))
            draw.point((cx + 5, dy + 2), fill=(*C_PURPLE[:3], 100))

    elif spell_id == "ember_bolt":
        draw.ellipse((cx - 10, cy - 8, cx + 10, cy + 8), fill=C_ACCENT, outline=outline)
        draw.ellipse((cx - 5, cy - 4, cx + 5, cy + 4), fill=C_YELLOW)
        draw.polygon([(cx + 10, cy), (cx + 20, cy - 3), (cx + 20, cy + 3)], fill=C_WARM)

    elif spell_id == "rootbind":
        for i in range(3):
            angle = i * 2.1
            pts = []
            for t in range(0, 20, 2):
                r = 4 + t * 0.5
                px = cx + int(math.cos(angle + t * 0.25) * r)
                py = cy + int(math.sin(angle + t * 0.25) * r) - 4
                pts.append((px, py))
            if len(pts) >= 2:
                draw.line(pts, fill=C_VINE, width=2)
        draw.polygon([(cx - 3, cy + 10), (cx, cy + 4), (cx + 3, cy + 10)], fill=C_LEAF_DARK)

    elif spell_id == "arc_step":
        draw.arc((cx - 16, cy - 16, cx + 16, cy + 16), 200, 340, fill=C_CYAN, width=3)
        draw.ellipse((cx + 8, cy - 10, cx + 16, cy - 2), fill=C_CYAN, outline=outline)
        draw.line((cx - 14, cy + 6, cx - 6, cy + 6), fill=(*C_CYAN[:3], 100), width=2)

    elif spell_id == "rune_anchor":
        draw.ellipse((cx - 12, cy - 12, cx + 12, cy + 12), outline=C_GOLD, width=2)
        draw.line([(cx - 8, cy - 4), (cx + 8, cy + 4)], fill=C_GOLD, width=2)
        draw.line([(cx + 8, cy - 4), (cx - 8, cy + 4)], fill=C_GOLD, width=2)
        draw.ellipse((cx - 4, cy - 4, cx + 4, cy + 4), fill=C_WARM)
        draw.line((cx - 18, cy, cx - 12, cy), fill=C_GOLD, width=2)
        draw.line((cx + 12, cy, cx + 18, cy), fill=C_GOLD, width=2)


def _draw_relic_icon(draw: ImageDraw.ImageDraw, relic_id: str) -> None:
    """Draw a 48×48 relic icon."""
    cx, cy = 24, 26
    outline = C_SHADOW
    c1, c2, c3 = RELIC_SPECS[relic_id]

    if relic_id == "cinder_heart":
        pts = [
            (cx, cy + 10),
            (cx - 12, cy - 2),
            (cx - 8, cy - 12),
            (cx, cy - 8),
            (cx + 8, cy - 12),
            (cx + 12, cy - 2),
        ]
        draw.polygon(pts, fill=c1, outline=outline)
        draw.ellipse((cx - 5, cy - 6, cx + 5, cy + 2), fill=c3)
        draw.line([(cx - 4, cy - 4), (cx + 2, cy + 2)], fill=c2, width=1)
        draw.line([(cx + 3, cy - 5), (cx - 1, cy + 3)], fill=c2, width=1)
        for ox, oy in [(-10, -8), (8, -6), (0, -14)]:
            draw.point((cx + ox, cy + oy), fill=c3)
            draw.point((cx + ox + 1, cy + oy), fill=(*c1[:3], 180))

    elif relic_id == "thornseed_charm":
        draw.ellipse((cx - 14, cy - 14, cx + 14, cy + 14), outline=c1, width=2)
        for i in range(8):
            angle = i * math.pi / 4
            tx = cx + int(math.cos(angle) * 14)
            ty = cy + int(math.sin(angle) * 14)
            draw.polygon(
                [(tx, ty), (tx + int(math.cos(angle + 0.4) * 5), ty + int(math.sin(angle + 0.4) * 5)),
                 (tx + int(math.cos(angle - 0.4) * 5), ty + int(math.sin(angle - 0.4) * 5))],
                fill=c1,
            )
        draw.ellipse((cx - 5, cy - 5, cx + 5, cy + 5), fill=c3, outline=c2)

    elif relic_id == "iron_grip":
        draw.rounded_rectangle((cx - 10, cy - 10, cx + 10, cy + 10), radius=3, fill=c2, outline=outline)
        draw.rectangle((cx - 12, cy - 4, cx - 6, cy + 4), fill=c1, outline=outline)
        draw.rectangle((cx + 6, cy - 4, cx + 12, cy + 4), fill=c1, outline=outline)
        draw.rectangle((cx - 3, cy - 2, cx + 3, cy + 6), fill=c3)

    elif relic_id == "gloom_lens":
        draw.ellipse((cx - 14, cy - 14, cx + 14, cy + 14), fill=(*c1[:3], 160), outline=outline)
        draw.ellipse((cx - 10, cy - 10, cx + 10, cy + 10), fill=c2, outline=outline)
        draw.ellipse((cx - 5, cy - 5, cx + 5, cy + 5), fill=(*c3[:3], 200))
        draw.arc((cx - 16, cy - 16, cx + 16, cy + 16), 30, 150, fill=(*c1[:3], 120), width=2)

    elif relic_id == "frost_nail":
        draw.polygon([(cx, cy - 16), (cx + 5, cy + 12), (cx, cy + 8), (cx - 5, cy + 12)], fill=c2, outline=outline)
        draw.polygon([(cx, cy - 14), (cx + 2, cy + 4), (cx - 2, cy + 4)], fill=c1)
        draw.line((cx - 8, cy + 10, cx + 8, cy + 10), fill=c3, width=2)

    elif relic_id == "mist_walker":
        draw.ellipse((cx - 10, cy - 2, cx - 2, cy + 8), fill=c1, outline=outline)
        draw.ellipse((cx + 2, cy - 2, cx + 10, cy + 8), fill=c1, outline=outline)
        for i in range(5):
            wx = cx - 12 + i * 6
            wy = cy - 10 - (i % 2) * 2
            draw.ellipse((wx - 3, wy - 2, wx + 3, wy + 2), fill=(*c2[:3], 140))


def _draw_world_sprite(draw: ImageDraw.ImageDraw, sprite_id: str, w: int, h: int) -> None:
    """Draw a world interactable / pickup sprite."""
    cx, cy = w // 2, h // 2
    outline = C_SHADOW

    if sprite_id == "pickup_glow":
        for r in range(16, 6, -3):
            alpha = int(60 + (16 - r) * 8)
            draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=(*C_GOLD[:3], alpha))

    elif sprite_id == "focus_crucible":
        draw.polygon([(cx, 4), (cx + 12, h - 8), (cx - 12, h - 8)], fill=C_WARM, outline=outline)
        draw.rectangle((cx - 8, h - 12, cx + 8, h - 4), fill=C_BASE, outline=outline)
        draw.ellipse((cx - 6, 8, cx + 6, 20), fill=C_ACCENT)
        draw.ellipse((cx - 3, 11, cx + 3, 17), fill=C_YELLOW)
        draw.point((cx - 8, 6), fill=(*C_ACCENT[:3], 180))
        draw.point((cx + 7, 5), fill=(*C_YELLOW[:3], 160))

    elif sprite_id == "anchor_point":
        draw.ellipse((cx - 10, cy - 10, cx + 10, cy + 10), outline=C_GOLD, width=2)
        draw.line([(cx - 6, cy - 4), (cx + 6, cy + 4)], fill=C_GOLD, width=2)
        draw.line([(cx + 6, cy - 4), (cx - 6, cy + 4)], fill=C_GOLD, width=2)
        draw.ellipse((cx - 3, cy - 3, cx + 3, cy + 3), fill=C_WARM)

    elif sprite_id == "brazier_gate":
        draw.rectangle((cx - 10, 8, cx + 10, h - 6), fill=C_BASE, outline=outline)
        draw.rectangle((cx - 14, h - 10, cx + 14, h - 4), fill=C_MID, outline=outline)
        draw.ellipse((cx - 8, 4, cx + 8, 20), fill=C_WARM, outline=outline)
        draw.ellipse((cx - 5, 8, cx + 5, 16), fill=C_ACCENT)
        draw.point((cx - 6, 6), fill=C_YELLOW)
        draw.point((cx + 5, 5), fill=C_YELLOW)

    elif sprite_id == "vine_gate":
        for col in range(3):
            ox = cx - 8 + col * 8
            for seg in range(0, h - 8, 12):
                draw.line([(ox, seg + 4), (ox + (2 if col == 1 else -2), seg + 14)], fill=C_VINE, width=3)
                if seg % 24 == 0:
                    draw.polygon(
                        [(ox + 4, seg + 8), (ox + 10, seg + 10), (ox + 4, seg + 14)],
                        fill=C_LEAF_DARK,
                    )
        draw.rectangle((cx - 14, h - 8, cx + 14, h - 2), fill=C_LEAF_DARK, outline=outline)


def build_relic_icons() -> list[Path]:
    out_dir = ASSETS / "sprites/ui/icons"
    paths: list[Path] = []
    for relic_id in RELIC_SPECS:
        img = Image.new("RGBA", (48, 48), C_TRANSPARENT)
        draw = ImageDraw.Draw(img)
        _draw_relic_icon(draw, relic_id)
        out = out_dir / f"ui_relic_icon_{relic_id}.png"
        img.save(out)
        paths.append(out)
    return paths


def build_world_sprites() -> list[Path]:
    specs = {
        "pickup_glow": (36, 36),
        "focus_crucible": (32, 48),
        "anchor_point": (24, 24),
        "brazier_gate": (32, 96),
        "vine_gate": (32, 128),
    }
    out_dir = ASSETS / "sprites/world"
    paths: list[Path] = []
    for sprite_id, (w, h) in specs.items():
        img = Image.new("RGBA", (w, h), C_TRANSPARENT)
        draw = ImageDraw.Draw(img)
        _draw_world_sprite(draw, sprite_id, w, h)
        out = out_dir / f"world_{sprite_id}.png"
        img.save(out)
        paths.append(out)
    return paths


def build_spell_icons() -> list[Path]:
    out_dir = ASSETS / "sprites/ui/icons"
    paths: list[Path] = []
    for spell_id in SPELL_SPECS:
        img = Image.new("RGBA", (48, 48), C_TRANSPARENT)
        draw = ImageDraw.Draw(img)
        _draw_spell_icon(draw, spell_id)
        out = out_dir / f"ui_spell_icon_{spell_id}.png"
        img.save(out)
        paths.append(out)
    return paths


def _draw_spell_vfx_frame(
    draw: ImageDraw.ImageDraw, spell_id: str, frame: int, total: int
) -> None:
    """Draw one 128×128 VFX cell."""
    cx, cy = 64, 64
    t = frame / max(total - 1, 1)
    spec = SPELL_SPECS[spell_id]
    c1, c2 = spec["color"], spec["color2"]

    if spell_id == "ember_sigil":
        radius = int(8 + t * 40)
        alpha = int(255 * (1.0 - t * 0.7))
        col = _lerp_color(c1, c2, t)
        draw.ellipse(
            (cx - radius, cy - radius, cx + radius, cy + radius),
            fill=(*col[:3], alpha),
        )
        if frame < total // 2:
            draw.line((cx - 50, cy, cx + int(20 * t), cy), fill=(*c1[:3], 200), width=3)
        for i in range(6):
            angle = i * math.pi / 3 + frame * 0.4
            r = 12 + t * 30
            draw.point(
                (cx + int(math.cos(angle) * r), cy + int(math.sin(angle) * r)),
                fill=(*c2[:3], int(180 * (1 - t))),
            )

    elif spell_id == "veil_step":
        tear_w = int(2 + math.sin(frame * 0.8) * 2)
        tear_h = int(20 + t * 60)
        draw.rectangle(
            (cx - tear_w, cy - tear_h // 2, cx + tear_w, cy + tear_h // 2),
            fill=(255, 255, 255, int(200 * (1 - abs(t - 0.5) * 2))),
        )
        for i in range(8):
            sy = cy - tear_h // 2 + i * (tear_h // 7)
            draw.point((cx - 8 - i, sy), fill=(*c1[:3], 100))
            draw.point((cx + 8 + i, sy), fill=(*c1[:3], 100))
        if t > 0.5:
            draw.ellipse(
                (cx - 20, cy - 20, cx + 20, cy + 20),
                fill=(*c1[:3], int(80 * (1 - t))),
            )

    elif spell_id == "ember_bolt":
        bx = int(20 + t * 70)
        size = int(10 - t * 4)
        col = _lerp_color(c1, c2, t)
        draw.ellipse((bx - size, cy - size, bx + size, cy + size), fill=col)
        for i in range(4):
            tx = bx - 10 - i * 8
            draw.ellipse((tx - 3, cy - 3, tx + 3, cy + 3), fill=(*c1[:3], 150 - i * 30))

    elif spell_id == "rootbind":
        growth = int(t * 50)
        for vine in range(3):
            base_angle = vine * 2.1 - 0.5
            pts = []
            for step in range(growth):
                ang = base_angle + step * 0.12
                r = 4 + step * 0.6
                pts.append((cx + int(math.cos(ang) * r), cy + int(math.sin(ang) * r)))
            if len(pts) >= 2:
                draw.line(pts, fill=c1, width=3)
        if t > 0.6:
            draw.ellipse((cx - 8, cy - 8, cx + 8, cy + 8), fill=(*c2[:3], int(120 * t)))

    elif spell_id == "arc_step":
        arc_start = 200 + int(t * 80)
        draw.arc((cx - 40, cy - 40, cx + 40, cy + 40), arc_start, arc_start + 100, fill=c1, width=4)
        if frame % 2 == 0:
            draw.ellipse((cx - 12, cy - 12, cx + 12, cy + 12), fill=(*c2[:3], int(100 * (1 - t))))
        for i in range(5):
            px = cx + int(math.cos(arc_start * math.pi / 180 + i * 0.2) * (20 + i * 8))
            py = cy + int(math.sin(arc_start * math.pi / 180 + i * 0.2) * (20 + i * 8))
            draw.point((px, py), fill=(*c1[:3], 200 - i * 30))

    elif spell_id == "rune_anchor":
        chain_len = int(t * 55)
        draw.line((cx - chain_len, cy, cx + 10, cy), fill=c1, width=3)
        for link in range(0, chain_len, 10):
            lx = cx - chain_len + link
            draw.ellipse((lx - 4, cy - 5, lx + 4, cy + 5), outline=c1, width=2)
        pulse = 8 + int(math.sin(frame * 1.2) * 4)
        draw.ellipse((cx - pulse, cy - pulse, cx + pulse, cy + pulse), outline=c2, width=2)
        if t > 0.4:
            draw.line([(cx - 6, cy - 6), (cx + 6, cy + 6)], fill=c1, width=2)
            draw.line([(cx + 6, cy - 6), (cx - 6, cy + 6)], fill=c1, width=2)


def build_spell_vfx() -> list[Path]:
    out_dir = ASSETS / "sprites/vfx/spells"
    paths: list[Path] = []
    for spell_id, spec in SPELL_SPECS.items():
        frames = spec["vfx_frames"]
        sheet = Image.new("RGBA", (128 * frames, 128), C_TRANSPARENT)
        rects = []
        for f in range(frames):
            cell = Image.new("RGBA", (128, 128), C_TRANSPARENT)
            draw = ImageDraw.Draw(cell)
            _draw_spell_vfx_frame(draw, spell_id, f, frames)
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
        )
        paths.append(out)
    return paths


def main() -> None:
    random.seed(42)
    ensure_dirs()
    print("Generating sprites...")
    build_elara_sheet()
    build_corin_sheet()
    build_enemy_sheet()
    build_bramble_stalker_sheet()
    build_thornweft_matron_sheet()
    build_root_warden_sheet()
    build_tileset()
    build_parallax()
    build_whisperwood_parallax()
    build_spell_icons()
    build_relic_icons()
    build_world_sprites()
    build_spell_vfx()
    print("Generating audio...")
    gen_ambient_threshold()
    gen_ambient_whisperwood()
    for i in range(1, 5):
        gen_footstep(f"sfx_footstep_ash_{i}", 120 + i * 15, i)
        gen_footstep(f"sfx_footstep_stone_{i}", 200 + i * 20, i + 10)
    gen_ui_sound("ui_menu_select", 520, 680)
    gen_ui_sound("ui_menu_confirm", 440, 880, 0.12)
    gen_sfx_game_over()
    gen_player_sfx("sfx_dash", "dash")
    gen_player_sfx("sfx_jump", "jump")
    gen_player_sfx("sfx_land", "land")
    gen_player_sfx("sfx_player_hurt_1", "hurt")
    gen_player_sfx("sfx_melee_swipe_1", "melee_swipe_1")
    gen_player_sfx("sfx_melee_swipe_2", "melee_swipe_2")
    gen_player_sfx("sfx_melee_swipe_3", "melee_swipe_3")
    gen_player_sfx("sfx_melee_hit", "melee_hit")
    for spell_id in SPELL_SPECS:
        gen_spell_sfx(spell_id, "cast")
        gen_spell_sfx(spell_id, "impact")
    gen_music_threshold()
    gen_music_whisperwood()
    gen_music_game_over()
    gen_stinger_main_menu()
    print("Done — assets written to", ASSETS)


if __name__ == "__main__":
    main()
