#!/usr/bin/env python3
"""Generate Phase 3 vertical slice rooms — Ashen Threshold + Whisperwood."""

from __future__ import annotations

import os
from pathlib import Path

TILE = 64
DOOR_GAP = TILE
ROOT = Path(__file__).resolve().parents[1]
GODOT = ROOT / "godot"
ROOMS = GODOT / "scenes" / "rooms"

ROOM_SCRIPT = "res://scripts/world/room.gd"
DEV_GEOM = "res://scripts/world/dev_room_geometry.gd"
STYLED_GEOM = "res://scripts/world/styled_room_geometry.gd"
ROOM_TRANSITION = "res://scenes/components/room_transition.tscn"
STALKER = "res://scenes/enemies/bramble_stalker.tscn"
CRUCIBLE = "res://scenes/components/focus_crucible.tscn"
VINE_GATE = "res://scenes/components/vine_gate.tscn"
SPELL_PICKUP = "res://scenes/components/spell_pickup.tscn"
ANCHOR = "res://scenes/components/anchor_point.tscn"
MATRON = "res://scenes/bosses/thornweft_matron.tscn"
WARDEN = "res://scenes/bosses/root_warden.tscn"
ASH_TILESET = "res://assets/sprites/tilesets/01_ashen_threshold/tileset.png"


def floor_y(height_tiles: int) -> int:
    return height_tiles * TILE - TILE


def spawn_y(height_tiles: int) -> int:
    return floor_y(height_tiles) - 28


def door_y(height_tiles: int) -> int:
    return floor_y(height_tiles)


def door_x(edge: str, width_tiles: int) -> int:
    w_px = width_tiles * TILE
    if edge == "west":
        return DOOR_GAP // 2
    return w_px - DOOR_GAP // 2


def rect_platform(x: int, y: int, w_tiles: int, h_tiles: int = 1) -> str:
    w, h = w_tiles * TILE, h_tiles * TILE
    return f"Rect2({x}, {y}, {w}, {h})"


LEDGE_H = 20


def ledge(x: int, y: int, width_px: int) -> str:
    return f"Rect2({x}, {y}, {width_px}, {LEDGE_H})"


def room_platforms(room_id: str, width_tiles: int, height_tiles: int) -> list[str]:
    """Per-room platforming layout — first rect in scene is still the floor."""
    fy = floor_y(height_tiles)
    w = width_tiles * TILE

    layouts: dict[str, list[str]] = {
        # --- Ashen Threshold ---
        "at_01_threshold_hub": [
            ledge(128, fy - 128, 192),
            ledge(512, fy - 192, 256),
            ledge(768, fy - 96, 128),
            ledge(960, fy - 224, 160),
        ],
        "at_03_east_road": [
            ledge(320, fy - 96, 160),
            ledge(640, fy - 160, 128),
            ledge(960, fy - 96, 192),
            ledge(1152, fy - 192, 160),
            ledge(1280, fy - 128, 128),
        ],
        # --- Whisperwood ---
        "ww_01_forest_gate": [
            ledge(256, fy - 96, 128),
            ledge(512, fy - 160, 192),
            ledge(832, fy - 96, 160),
            ledge(1024, fy - 192, 128),
        ],
        "ww_02_whisper_path": [
            ledge(192, fy - 80, 192),
            ledge(512, fy - 128, 128),
            ledge(768, fy - 64, 256),
            ledge(1152, fy - 160, 160),
            ledge(1408, fy - 96, 128),
        ],
        "ww_03_thorn_hollow": [
            ledge(64, fy - 128, 128),
            ledge(512, fy - 192, 160),
            ledge(128, fy - 256, 192),
            ledge(640, fy - 320, 128),
            ledge(256, fy - 384, 160),
            ledge(768, fy - 448, 128),
        ],
        "ww_04_branch_crossing": [
            ledge(256, fy - 160, 192),
            ledge(640, fy - 224, 128),
            ledge(448, fy - 288, 256),
            ledge(896, fy - 160, 160),
            ledge(512, fy - 352, 128),
        ],
        "ww_05_spore_glen": [
            ledge(192, fy - 128, 128),
            ledge(448, fy - 192, 96),
            ledge(640, fy - 96, 128),
            ledge(832, fy - 224, 160),
            ledge(1024, fy - 128, 128),
            ledge(1152, fy - 256, 96),
        ],
        "ww_06_root_pit": [
            ledge(0, fy - 384, 192),
            ledge(w - 192, fy - 448, 192),
            ledge(0, fy - 576, 192),
            ledge(w - 192, fy - 640, 192),
            ledge(128, fy - 768, 256),
            ledge(384, fy - 896, 192),
            ledge(128, fy - 1024, 256),
        ],
        "ww_07_heartwood_chamber": [
            ledge(128, fy - 192, 192),
            ledge(896, fy - 192, 192),
            ledge(384, fy - 288, 320),
            ledge(512, fy - 384, 128),
            ledge(704, fy - 448, 160),
        ],
        "ww_08_vine_lift": [
            ledge(0, fy - 320, 128),
            ledge(64, fy - 448, 128),
            ledge(0, fy - 576, 128),
            ledge(64, fy - 704, 128),
            ledge(0, fy - 832, 192),
            ledge(512, fy - 256, 256),
            ledge(640, fy - 384, 128),
        ],
        "ww_09_canopy_walk": [
            ledge(128, fy - 160, 384),
            ledge(640, fy - 192, 256),
            ledge(1024, fy - 224, 320),
            ledge(1536, fy - 160, 256),
            ledge(256, fy - 288, 128),
            ledge(1280, fy - 288, 128),
        ],
        "ww_10_matron_approach": [
            ledge(256, fy - 96, 128),
            ledge(512, fy - 144, 96),
            ledge(768, fy - 96, 128),
            ledge(960, fy - 160, 96),
        ],
        "ww_11_heartwood_grove": [
            ledge(128, fy - 192, 160),
            ledge(w - 288, fy - 192, 160),
            ledge(384, fy - 288, 128),
            ledge(704, fy - 288, 128),
            ledge(512, fy - 384, 96),
        ],
        "ww_12_ironroot_gate": [
            ledge(192, fy - 128, 128),
            ledge(384, fy - 192, 128),
            ledge(576, fy - 128, 128),
        ],
        "ww_13_cart_tunnel": [
            ledge(128, fy - 192, 320),
            ledge(640, fy - 224, 256),
            ledge(1024, fy - 192, 384),
            ledge(384, fy - 320, 96),
            ledge(896, fy - 320, 128),
        ],
        "ww_14_anchor_tutorial": [
            ledge(256, fy - 160, 128),
            ledge(512, fy - 224, 160),
            ledge(768, fy - 288, 128),
            ledge(384, fy - 352, 128),
            ledge(896, fy - 352, 128),
        ],
        "ww_15_ironroot_depths": [
            ledge(256, fy - 256, 192),
            ledge(w - 448, fy - 256, 192),
            ledge(512, fy - 384, 256),
            ledge(128, fy - 384, 128),
            ledge(w - 256, fy - 384, 128),
            ledge(384, fy - 512, 96),
            ledge(768, fy - 512, 96),
        ],
        "ww_16_post_warden": [
            ledge(320, fy - 128, 128),
            ledge(576, fy - 96, 96),
            ledge(832, fy - 128, 128),
        ],
    }
    return layouts.get(room_id, [])


def geom_node(
    region: str,
    width_tiles: int,
    height_tiles: int,
    extras: list[str],
    west_door: bool = False,
    east_door: bool = False,
) -> str:
    fy = floor_y(height_tiles)
    floor = rect_platform(0, fy, width_tiles)
    rects = [floor] + extras
    arr = ", ".join(rects)
    door_flags = ""
    if west_door or east_door:
        door_flags = f"\nwest_transition = {str(west_door).lower()}\neast_transition = {str(east_door).lower()}"
    if region == "ashen_threshold":
        return f"""[node name="Geometry" type="Node2D" parent="."]
script = ExtResource("2_geom")
tileset_path = "{ASH_TILESET}"
platform_rects = Array[Rect2]([{arr}]){door_flags}"""
    colors = {
        "whisperwood_hollow": ("Color(0.1, 0.16, 0.08, 1)", "Color(0.2, 0.34, 0.14, 1)"),
    }
    fc, pc = colors.get(region, ("Color(0.18, 0.17, 0.2, 1)", "Color(0.28, 0.26, 0.32, 1)"))
    return f"""[node name="Geometry" type="Node2D" parent="."]
script = ExtResource("2_geom")
floor_color = {fc}
platform_color = {pc}
platform_rects = Array[Rect2]([{arr}]){door_flags}"""


def transition(name: str, x: int, y: int, target: str, spawn: str, ext_id: str = "3_door") -> str:
    edge = "west" if name.lower() == "west" else "east"
    return f"""[node name="{name}" parent="RoomTransitions" instance=ExtResource("{ext_id}")]
position = Vector2({x}, {y})
target_room_id = &"{target}"
spawn_marker = &"{spawn}"
edge = &"{edge}\""""


def stalker(name: str, x: int, y: int, ext_id: str = "4_stalker") -> str:
    return f"""[node name="{name}" parent="Entities/Enemies" instance=ExtResource("{ext_id}")]
position = Vector2({x}, {y})"""


def ext_id(ext_resources: list[str], keyword: str) -> str:
    for line in ext_resources:
        if keyword in line and 'id="' in line:
            return line.split('id="')[1].split('"')[0]
    return "3_door"


def write_room(spec: dict) -> None:
    rid = spec["id"]
    region = spec["region"]
    wt, ht = spec["width"], spec["height"]
    w_px, h_px = wt * TILE, ht * TILE
    fy = floor_y(ht)
    sy = spawn_y(ht)

    extras = spec.get("platforms", [])
    geom_script = STYLED_GEOM if region == "ashen_threshold" else DEV_GEOM
    transitions = spec.get("transitions", [])
    has_west = any(t["name"].lower() == "west" for t in transitions)
    has_east = any(t["name"].lower() == "east" for t in transitions)

    load_steps = 4
    ext_resources = [
        f'[ext_resource type="Script" path="{ROOM_SCRIPT}" id="1_room"]',
        f'[ext_resource type="Script" path="{geom_script}" id="2_geom"]',
        f'[ext_resource type="PackedScene" path="{ROOM_TRANSITION}" id="3_door"]',
    ]
    sub_id = 4

    nodes_extra: list[str] = []
    has_stalker = bool(spec.get("enemies"))
    has_crucible = bool(spec.get("crucible"))
    has_vine = bool(spec.get("vine_gates"))
    has_pickup = bool(spec.get("spell_pickup"))
    has_anchor = bool(spec.get("anchors"))
    has_matron = spec.get("boss") == "matron"
    has_warden = spec.get("boss") == "warden"

    if has_stalker:
        ext_resources.append(f'[ext_resource type="PackedScene" path="{STALKER}" id="{sub_id}_stalker"]')
        sub_id += 1
    if has_crucible:
        ext_resources.append(f'[ext_resource type="PackedScene" path="{CRUCIBLE}" id="{sub_id}_crucible"]')
        sub_id += 1
    if has_vine:
        ext_resources.append(f'[ext_resource type="PackedScene" path="{VINE_GATE}" id="{sub_id}_vine"]')
        sub_id += 1
    if has_pickup:
        ext_resources.append(f'[ext_resource type="PackedScene" path="{SPELL_PICKUP}" id="{sub_id}_pickup"]')
        sub_id += 1
    if has_anchor:
        ext_resources.append(f'[ext_resource type="PackedScene" path="{ANCHOR}" id="{sub_id}_anchor"]')
        sub_id += 1
    if has_matron:
        ext_resources.append(f'[ext_resource type="PackedScene" path="{MATRON}" id="{sub_id}_matron"]')
        sub_id += 1
    if has_warden:
        ext_resources.append(f'[ext_resource type="PackedScene" path="{WARDEN}" id="{sub_id}_warden"]')
        sub_id += 1

    load_steps = sub_id

    stalker_ext = "4_stalker" if has_stalker else None
  # fix stalker ext id dynamically below

    lines = [
        f'[gd_scene load_steps={load_steps} format=3]',
        "",
        *ext_resources,
        "",
        f'[node name="{rid}" type="Node2D"]',
        'script = ExtResource("1_room")',
        f"room_id = &\"{rid}\"",
        f"region_id = &\"{region}\"",
        "",
        f'[node name="CameraBounds" type="ReferenceRect" parent="."]',
        f"offset_right = {w_px}.0",
        f"offset_bottom = {h_px}.0",
        "",
        geom_node(region, wt, ht, extras, has_west, has_east),
        "",
        '[node name="SpawnPoints" type="Node2D" parent="."]',
        "",
        f'[node name="default" type="Marker2D" parent="SpawnPoints"]',
        f"position = Vector2(80, {sy})",
    ]

    for spawn_name, (sx, sy_pos) in spec.get("spawns", {}).items():
        if spawn_name == "default":
            continue
        lines += ["", f'[node name="{spawn_name}" type="Marker2D" parent="SpawnPoints"]', f"position = Vector2({sx}, {sy_pos})"]

    lines += ["", '[node name="Entities" type="Node2D" parent="."]', "", '[node name="Enemies" type="Node2D" parent="Entities"]']

    stalker_id = ext_id(ext_resources, "stalker")
    for i, (ex, ey) in enumerate(spec.get("enemies", [])):
        lines += ["", stalker(f"Stalker{i}", ex, ey, stalker_id)]

    if has_matron:
        mid = ext_id(ext_resources, "matron")
        lines += ["", f'[node name="ThornweftMatron" parent="Entities" instance=ExtResource("{mid}")]', f"position = Vector2({w_px // 2}, {sy})"]
    if has_warden:
        wid = ext_id(ext_resources, "warden")
        lines += ["", f'[node name="RootWarden" parent="Entities" instance=ExtResource("{wid}")]', f"position = Vector2({w_px // 2}, {sy})"]

    lines += ["", '[node name="AbilityGates" type="Node2D" parent="."]']
    if has_vine:
        vid = ext_id(ext_resources, "vine")
        for i, (gx, gy, gid) in enumerate(spec.get("vine_gates", [])):
            lines += [
                "",
                f'[node name="VineGate{i}" parent="AbilityGates" instance=ExtResource("{vid}")]',
                f"position = Vector2({gx}, {gy})",
                f'gate_id = &"{gid}"',
            ]

    if has_pickup:
        pid = ext_id(ext_resources, "pickup")
        spell_id, px, py, pick_id = spec["spell_pickup"]
        lines += [
            "",
            f'[node name="SpellPickup" parent="." instance=ExtResource("{pid}")]',
            f"position = Vector2({px}, {py})",
            f"spell_id = &\"{spell_id}\"",
            f'pickup_id = &"{pick_id}"',
        ]

    if has_anchor:
        aid = ext_id(ext_resources, "anchor")
        for i, (ax, ay) in enumerate(spec.get("anchors", [])):
            lines += ["", f'[node name="Anchor{i}" parent="." instance=ExtResource("{aid}")]', f"position = Vector2({ax}, {ay})"]

    if has_crucible:
        cid = ext_id(ext_resources, "crucible")
        cx, cy, crucible_id = spec["crucible"]
        lines += [
            "",
            f'[node name="FocusCrucible" parent="." instance=ExtResource("{cid}")]',
            f"position = Vector2({cx}, {cy})",
            f'crucible_id = &"{crucible_id}"',
        ]

    lines += ["", '[node name="RoomTransitions" type="Node2D" parent="."]']
    for t in spec.get("transitions", []):
        lines += ["", transition(t["name"], t["x"], t["y"], t["target"], t["spawn"])]

    out_dir = ROOMS / region
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{rid}.tscn"
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"  wrote {out_path.relative_to(ROOT)}")


def build_specs() -> list[dict]:
    specs: list[dict] = []

    # --- Ashen Threshold ---
    at_hub = {
        "id": "at_01_threshold_hub",
        "region": "ashen_threshold",
        "width": 16,
        "height": 12,
        "platforms": room_platforms("at_01_threshold_hub", 16, 12),
        "crucible": (200, floor_y(12) - 28, "at_hub_crucible"),
        "transitions": [{"name": "East", "x": door_x("east", 16), "y": door_y(12), "target": "at_03_east_road", "spawn": "from_left"}],
    }
    specs.append(at_hub)

    specs.append({
        "id": "at_03_east_road",
        "region": "ashen_threshold",
        "width": 24,
        "height": 8,
        "platforms": room_platforms("at_03_east_road", 24, 8),
        "enemies": [(480, spawn_y(8)), (720, spawn_y(8)), (640, 260), (1100, 228)],
        "spell_pickup": ("veil_step", 19 * 64, 228, "at_03_veil_step"),
        "spawns": {"from_left": (80, spawn_y(8)), "from_right": (24 * 64 - 100, spawn_y(8))},
        "transitions": [
            {"name": "West", "x": door_x("west", 24), "y": door_y(8), "target": "at_01_threshold_hub", "spawn": "default"},
            {"name": "East", "x": door_x("east", 24), "y": door_y(8), "target": "ww_01_forest_gate", "spawn": "from_left"},
        ],
    })

    # --- Whisperwood ww_01 – ww_16 ---
    ww_chain = [
        ("ww_01_forest_gate", 20, 10, {"enemies": [(400, None), (640, None)], "next": "ww_02_whisper_path"}),
        ("ww_02_whisper_path", 24, 8, {"enemies": [(500, None)], "next": "ww_03_thorn_hollow"}),
        ("ww_03_thorn_hollow", 16, 14, {"enemies": [(350, None)], "next": "ww_04_branch_crossing"}),
        ("ww_04_branch_crossing", 18, 12, {"enemies": [(400, None)], "next": "ww_05_spore_glen"}),
        ("ww_05_spore_glen", 20, 10, {"enemies": [(450, None), (650, None)], "next": "ww_06_root_pit"}),
        ("ww_06_root_pit", 12, 20, {"next": "ww_07_heartwood_chamber"}),
        ("ww_07_heartwood_chamber", 18, 16, {"spell_pickup": ("rootbind", 9 * 64, spawn_y(16), "ww_07_rootbind"), "next": "ww_08_vine_lift"}),
        ("ww_08_vine_lift", 14, 18, {"vine_gates": [(14 * 64 - 48, spawn_y(18), "ww_08_vine_wall")], "next": "ww_09_canopy_walk"}),
        ("ww_09_canopy_walk", 28, 8, {"enemies": [(500, None), (800, None)], "next": "ww_10_matron_approach"}),
        ("ww_10_matron_approach", 16, 10, {"enemies": [(350, None), (550, None)], "crucible": (120, spawn_y(10) - 20, "ww_10_crucible"), "next": "ww_11_heartwood_grove"}),
        ("ww_11_heartwood_grove", 18, 14, {"boss": "matron", "next": "ww_12_ironroot_gate"}),
        ("ww_12_ironroot_gate", 12, 10, {"next": "ww_13_cart_tunnel"}),
        ("ww_13_cart_tunnel", 22, 10, {"enemies": [(500, None)], "next": "ww_14_anchor_tutorial"}),
        ("ww_14_anchor_tutorial", 16, 12, {"anchors": [(10 * 64, spawn_y(12) - 80), (12 * 64, spawn_y(12) - 120)], "next": "ww_15_ironroot_depths"}),
        ("ww_15_ironroot_depths", 20, 16, {"boss": "warden", "anchors": [(4 * 64, spawn_y(16) - 100), (16 * 64, spawn_y(16) - 100)], "next": "ww_16_post_warden"}),
        ("ww_16_post_warden", 14, 10, {"crucible": (200, spawn_y(10) - 20, "ww_16_crucible")}),
    ]

    prev_id = "at_03_east_road"
    for entry in ww_chain:
        rid, wt, ht, meta = entry
        sy = spawn_y(ht)
        enemies = [(ex, sy if ey is None else ey) for ex, ey in meta.get("enemies", [])]
        spec: dict = {
            "id": rid,
            "region": "whisperwood_hollow",
            "width": wt,
            "height": ht,
            "enemies": enemies,
            "platforms": meta.get("platforms", room_platforms(rid, wt, ht)),
            "spawns": {"from_left": (80, sy), "from_right": (wt * TILE - 100, sy)},
        }
        if meta.get("spell_pickup"):
            spec["spell_pickup"] = meta["spell_pickup"]
        if meta.get("vine_gates"):
            spec["vine_gates"] = [(gx, gy if gy != spawn_y(ht) else sy, gid) for gx, gy, gid in meta["vine_gates"]]
        if meta.get("crucible"):
            cx, cy, cid = meta["crucible"]
            spec["crucible"] = (cx, cy, cid)
        if meta.get("boss"):
            spec["boss"] = meta["boss"]
        if meta.get("anchors"):
            spec["anchors"] = meta["anchors"]

        transitions = []
        dy = door_y(ht)
        if prev_id:
            transitions.append({"name": "West", "x": door_x("west", wt), "y": dy, "target": prev_id, "spawn": "from_right"})
        if meta.get("next"):
            transitions.append({"name": "East", "x": door_x("east", wt), "y": dy, "target": meta["next"], "spawn": "from_left"})
        spec["transitions"] = transitions

        if rid == "ww_01_forest_gate":
            spec["transitions"] = [
                {"name": "West", "x": door_x("west", wt), "y": dy, "target": "at_03_east_road", "spawn": "from_right"},
                {"name": "East", "x": door_x("east", wt), "y": dy, "target": meta["next"], "spawn": "from_left"},
            ]

        specs.append(spec)
        prev_id = rid

    return specs


def main() -> None:
    print("Generating Phase 3 rooms...")
    specs = build_specs()
    for spec in specs:
        write_room(spec)
    print(f"Done — {len(specs)} rooms.")


if __name__ == "__main__":
    main()
