#!/usr/bin/env python3
"""Generate Phase 5 Whisperwood remainder rooms, enemy scenes, and wire slice updates."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GODOT = ROOT / "godot"
ROOMS = GODOT / "scenes" / "rooms" / "whisperwood_hollow"
ENEMIES = GODOT / "scenes" / "enemies"

TILE = 64
ROOM_SCRIPT = "res://scripts/world/room.gd"
DEV_GEOM = "res://scripts/world/dev_room_geometry.gd"
ROOM_TRANSITION = "res://scenes/components/room_transition.tscn"
CRUCIBLE = "res://scenes/components/focus_crucible.tscn"
RELIC_PICKUP = "res://scenes/components/relic_pickup.tscn"
WAYSTONE = "res://scenes/components/waystone.tscn"
DESTRUCTIBLE = "res://scenes/components/destructible_bark_wall.tscn"
ARC_GATE = "res://scenes/components/arc_step_gate.tscn"
WHISPER_STONE = "res://scenes/components/whisper_stone.tscn"
REGION_LOCKED = "res://scenes/components/region_locked_gate.tscn"

ENEMY_SCENES = {
    "stalker": "res://scenes/enemies/bramble_stalker.tscn",
    "mothling": "res://scenes/enemies/mothling_swarm.tscn",
    "wraith": "res://scenes/enemies/bark_wraith.tscn",
    "larva": "res://scenes/enemies/thornweft_larva.tscn",
    "hunter": "res://scenes/enemies/canopy_hunter.tscn",
}


def floor_y(height_tiles: int) -> int:
    return height_tiles * TILE - TILE


def spawn_y(height_tiles: int) -> int:
    return floor_y(height_tiles) - 28


def rect_platform(x: int, y: int, w_tiles: int, h_tiles: int = 1) -> str:
    return f"Rect2({x}, {y}, {w_tiles * TILE}, {h_tiles * TILE})"


def ext_id(ext_resources: list[str], keyword: str) -> str:
    for line in ext_resources:
        if keyword in line and 'id="' in line:
            return line.split('id="')[1].split('"')[0]
    return "3_door"


def geom_node(width_tiles: int, height_tiles: int, extras: list[str]) -> str:
    fy = floor_y(height_tiles)
    floor = rect_platform(0, fy, width_tiles)
    rects = ", ".join([floor] + extras)
    return f"""[node name="Geometry" type="Node2D" parent="."]
script = ExtResource("2_geom")
floor_color = Color(0.1, 0.16, 0.08, 1)
platform_color = Color(0.2, 0.34, 0.14, 1)
platform_rects = Array[Rect2]([{rects}])"""


def transition(name: str, x: int, y: int, target: str, spawn: str, ext_id_str: str) -> str:
    return f"""[node name="{name}" parent="RoomTransitions" instance=ExtResource("{ext_id_str}")]
position = Vector2({x}, {y})
target_room_id = &"{target}"
spawn_marker = &"{spawn}\""""


def enemy_node(name: str, x: int, y: int, ext_id_str: str) -> str:
    return f"""[node name="{name}" parent="Entities/Enemies" instance=ExtResource("{ext_id_str}")]
position = Vector2({x}, {y})"""


def write_enemy_scene(
    scene_name: str,
    script_path: str,
    data_path: str,
    modulate: str = "Color(1, 1, 1, 1)",
    scale: str = "Vector2(1, 1)",
) -> None:
    stalker = (ENEMIES / "bramble_stalker.tscn").read_text(encoding="utf-8")
    stalker = re.sub(
        r'\[node name="BrambleStalker" type="CharacterBody2D"\]',
        f'[node name="{scene_name}" type="CharacterBody2D"]',
        stalker,
        count=1,
    )
    stalker = re.sub(
        r'script = ExtResource\("1_enemy"\)',
        f'script = ExtResource("1_enemy")',
        stalker,
        count=1,
    )
    lines = stalker.splitlines()
    new_lines: list[str] = []
    for line in lines:
        if 'path="res://scripts/enemies/base_enemy.gd"' in line:
            new_lines.append(f'[ext_resource type="Script" path="{script_path}" id="1_enemy"]')
            continue
        if 'path="res://resources/enemies/e_03_bramble_stalker.tres"' in line:
            new_lines.append(f'[ext_resource type="Resource" path="{data_path}" id="2_data"]')
            continue
        if "modulate = " in line and "AnimatedSprite2D" in "\n".join(new_lines[-3:]):
            new_lines.append(f"modulate = {modulate}")
            continue
        if "scale = " in line and "AnimatedSprite2D" in "\n".join(new_lines[-3:]):
            new_lines.append(f"scale = {scale}")
            continue
        new_lines.append(line)
    out = ENEMIES / f"{scene_name.lower().replace('swarm', '_swarm').replace('wraith', '_wraith').replace('larva', '_larva').replace('hunter', '_hunter')}"
    if scene_name == "MothlingSwarm":
        out = ENEMIES / "mothling_swarm.tscn"
    elif scene_name == "BarkWraith":
        out = ENEMIES / "bark_wraith.tscn"
    elif scene_name == "ThornweftLarva":
        out = ENEMIES / "thornweft_larva.tscn"
    elif scene_name == "CanopyHunter":
        out = ENEMIES / "canopy_hunter.tscn"
    out.write_text("\n".join(new_lines) + "\n", encoding="utf-8")
    print(f"  wrote {out.relative_to(ROOT)}")


def write_room(spec: dict) -> None:
    rid = spec["id"]
    wt, ht = spec["width"], spec["height"]
    w_px, h_px = wt * TILE, ht * TILE
    sy = spawn_y(ht)

    extras = spec.get("platforms", [])
    ext_resources = [
        f'[ext_resource type="Script" path="{ROOM_SCRIPT}" id="1_room"]',
        f'[ext_resource type="Script" path="{DEV_GEOM}" id="2_geom"]',
        f'[ext_resource type="PackedScene" path="{ROOM_TRANSITION}" id="3_door"]',
    ]
    sub_id = 4
    optional = [
        ("enemies", ENEMY_SCENES.get(spec.get("enemy_type", "stalker"), ENEMY_SCENES["stalker"]), "_enemy"),
        ("crucible", CRUCIBLE, "_crucible"),
        ("relic", RELIC_PICKUP, "_relic"),
        ("waystone", WAYSTONE, "_waystone"),
        ("destructible", DESTRUCTIBLE, "_destruct"),
        ("arc_gate", ARC_GATE, "_arcgate"),
        ("whisper_stones", WHISPER_STONE, "_whisper"),
        ("region_gate", REGION_LOCKED, "_region"),
        ("hunter", ENEMY_SCENES["hunter"], "_hunter"),
    ]
    for key, path, suffix in optional:
        if spec.get(key):
            ext_resources.append(
                f'[ext_resource type="PackedScene" path="{path}" id="{sub_id}{suffix}"]'
            )
            sub_id += 1

    load_steps = sub_id
    lines = [
        f"[gd_scene load_steps={load_steps} format=3]",
        "",
        *ext_resources,
        "",
        f'[node name="{rid}" type="Node2D"]',
        'script = ExtResource("1_room")',
        f'room_id = &"{rid}"',
        'region_id = &"whisperwood_hollow"',
        "",
        '[node name="CameraBounds" type="ReferenceRect" parent="."]',
        f"offset_right = {w_px}.0",
        f"offset_bottom = {h_px}.0",
        "",
        geom_node(wt, ht, extras),
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

    if spec.get("tree_markers"):
        lines += ["", '[node name="TreePhaseMarkers" type="Node2D" parent="."]']
        for i, (tx, ty) in enumerate(spec["tree_markers"]):
            lines += ["", f'[node name="Tree{i}" type="Marker2D" parent="TreePhaseMarkers" groups=["tree_phase_markers"]]', f"position = Vector2({tx}, {ty})"]

    lines += ["", '[node name="Entities" type="Node2D" parent="."]', "", '[node name="Enemies" type="Node2D" parent="Entities/Enemies"]'.replace("/Enemies", "")]
    lines[-1] = '[node name="Enemies" type="Node2D" parent="Entities"]'

    if spec.get("enemies"):
        eid = ext_id(ext_resources, "_enemy")
        for i, (ex, ey) in enumerate(spec["enemies"]):
            lines += ["", enemy_node(f"Enemy{i}", ex, ey, eid)]

    if spec.get("hunter"):
        hid = ext_id(ext_resources, "_hunter")
        hx, hy = spec["hunter"]
        lines += ["", enemy_node("CanopyHunter", hx, hy, hid)]

    if spec.get("relic"):
        rid_ext = ext_id(ext_resources, "_relic")
        relic_id, rx, ry, pick_id = spec["relic"]
        lines += [
            "",
            f'[node name="RelicPickup" parent="." instance=ExtResource("{rid_ext}")]',
            f"position = Vector2({rx}, {ry})",
            f'relic_id = &"{relic_id}"',
            f'pickup_id = &"{pick_id}"',
        ]

    if spec.get("crucible"):
        cid = ext_id(ext_resources, "_crucible")
        cx, cy, crucible_id = spec["crucible"]
        lines += [
            "",
            f'[node name="FocusCrucible" parent="." instance=ExtResource("{cid}")]',
            f"position = Vector2({cx}, {cy})",
            f'crucible_id = &"{crucible_id}"',
        ]

    if spec.get("waystone"):
        wid = ext_id(ext_resources, "_waystone")
        wx, wy, ws_id = spec["waystone"]
        lines += [
            "",
            f'[node name="Waystone" parent="." instance=ExtResource("{wid}")]',
            f"position = Vector2({wx}, {wy})",
            f'waystone_id = &"{ws_id}"',
        ]

    if spec.get("destructible"):
        did = ext_id(ext_resources, "_destruct")
        dx, dy, gate_id, target, spawn = spec["destructible"]
        lines += [
            "",
            f'[node name="DestructibleWall" parent="." instance=ExtResource("{did}")]',
            f"position = Vector2({dx}, {dy})",
            f'gate_id = &"{gate_id}"',
            f'target_room_id = &"{target}"',
            f'spawn_marker = &"{spawn}"',
        ]

    if spec.get("arc_gate"):
        aid = ext_id(ext_resources, "_arcgate")
        ax, ay, gate_id, target, spawn = spec["arc_gate"]
        lines += [
            "",
            f'[node name="ArcStepGate" parent="AbilityGates" instance=ExtResource("{aid}")]',
            f"position = Vector2({ax}, {ay})",
            f'gate_id = &"{gate_id}"',
            f'target_room_id = &"{target}"',
            f'spawn_marker = &"{spawn}"',
        ]
    elif spec.get("arc_gate") is None and any(k == "arc_gate" for k in spec):
        pass
    else:
        lines += ["", '[node name="AbilityGates" type="Node2D" parent="."]']

    if spec.get("whisper_stones"):
        wid = ext_id(ext_resources, "_whisper")
        for i, (wx, wy, order) in enumerate(spec["whisper_stones"]):
            lines += [
                "",
                f'[node name="WhisperStone{i}" parent="." instance=ExtResource("{wid}")]',
                f"position = Vector2({wx}, {wy})",
                f"sequence_index = {order}",
            ]

    if spec.get("region_gate"):
        gid = ext_id(ext_resources, "_region")
        gx, gy, region_name = spec["region_gate"]
        lines += [
            "",
            f'[node name="RegionGate" parent="." instance=ExtResource("{gid}")]',
            f"position = Vector2({gx}, {gy})",
            f'required_region = &"{region_name}"',
        ]

    lines += ["", '[node name="RoomTransitions" type="Node2D" parent="."]']
    door_id = ext_id(ext_resources, "3_door")
    for t in spec.get("transitions", []):
        lines += ["", transition(t["name"], t["x"], t["y"], t["target"], t["spawn"], door_id)]

    ROOMS.mkdir(parents=True, exist_ok=True)
    out_path = ROOMS / f"{rid}.tscn"
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"  wrote {out_path.relative_to(ROOT)}")


def patch_slice_room_enemies() -> None:
    swaps = {
        "ww_02_whisper_path.tscn": ("mothling", [(500, spawn_y(8))]),
        "ww_04_branch_crossing.tscn": ("wraith", [(400, spawn_y(12))]),
        "ww_05_spore_glen.tscn": ("mothling", [(450, spawn_y(10)), (650, spawn_y(10))]),
        "ww_09_canopy_walk.tscn": ("larva", [(500, spawn_y(8)), (800, spawn_y(8))]),
    }
    for filename, (enemy_key, positions) in swaps.items():
        path = ROOMS / filename
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        enemy_path = ENEMY_SCENES[enemy_key]
        if enemy_path.split("/")[-1].replace(".tscn", "") in text:
            continue
        # Replace stalker ext_resource and instances
        text = re.sub(
            r'\[ext_resource type="PackedScene" path="res://scenes/enemies/bramble_stalker.tscn" id="(\d+)_stalker"\]',
            f'[ext_resource type="PackedScene" path="{enemy_path}" id="\\1_enemy"]',
            text,
        )
        text = text.replace("_stalker", "_enemy")
        text = text.replace("Stalker", "Enemy")
        path.write_text(text, encoding="utf-8")
        print(f"  patched enemies in {path.relative_to(ROOT)}")


def build_phase5_specs() -> list[dict]:
    fy = lambda ht: floor_y(ht)
    sy = lambda ht: spawn_y(ht)
    specs: list[dict] = []

    specs.append({
        "id": "ww_s01_gardener_cache",
        "width": 12,
        "height": 10,
        "platforms": [rect_platform(2 * TILE, fy(10) - 3 * TILE, 8)],
        "relic": ("gloom_lens", 6 * TILE, sy(10), "ww_s01_gloom_lens"),
        "transitions": [
            {"name": "Exit", "x": 12, "y": sy(10), "target": "ww_05_spore_glen", "spawn": "from_cache"},
        ],
    })

    specs.append({
        "id": "ww_s02_whisper_loop",
        "width": 14,
        "height": 12,
        "platforms": [rect_platform(TILE, fy(12) - 4 * TILE, 12)],
        "whisper_stones": [(3 * TILE, sy(12), 1), (10 * TILE, sy(12), 3), (6 * TILE, fy(12) - 3 * TILE, 2)],
        "transitions": [
            {"name": "Exit", "x": 12, "y": sy(12), "target": "ww_02_whisper_path", "spawn": "from_whisper"},
        ],
    })

    specs.append({
        "id": "ww_s03_canopy_nest",
        "width": 16,
        "height": 14,
        "platforms": [rect_platform(2 * TILE, fy(14) - 4 * TILE, 12)],
        "hunter": (8 * TILE, sy(14)),
        "relic": ("mist_walker", 8 * TILE, sy(14) - 40, "ww_s03_mist_walker"),
        "transitions": [
            {"name": "Exit", "x": 12, "y": sy(14), "target": "ww_09_canopy_walk", "spawn": "from_nest"},
        ],
    })

    specs.append({
        "id": "ww_17_upper_canopy",
        "width": 18,
        "height": 10,
        "platforms": [rect_platform(0, fy(10) - 2 * TILE, 18), rect_platform(4 * TILE, fy(10) - 5 * TILE, 10)],
        "waystone": (9 * TILE, sy(10), "ww_canopy_mid"),
        "region_gate": (17 * TILE - 20, sy(10), "lumineth_caverns"),
        "transitions": [
            {"name": "Down", "x": 12, "y": fy(10) - 2 * TILE + 20, "target": "ww_08_vine_lift", "spawn": "from_upper"},
        ],
    })

    explore_chain = [
        ("ww_18_moss_bridge", 16, 8, "ww_19_fungal_shelf"),
        ("ww_19_fungal_shelf", 14, 10, "ww_20_root_archive"),
        ("ww_20_root_archive", 18, 12, "ww_21_spore_vault"),
        ("ww_21_spore_vault", 16, 10, "ww_22_bark_gallery"),
        ("ww_22_bark_gallery", 20, 8, "ww_23_thorn_maze"),
        ("ww_23_thorn_maze", 14, 14, "ww_24_heartwood_loft"),
        ("ww_24_heartwood_loft", 16, 12, "ww_25_silk_chamber"),
        ("ww_25_silk_chamber", 18, 10, "ww_26_canopy_edge"),
        ("ww_26_canopy_edge", 22, 8, "ww_27_grove_rest"),
        ("ww_27_grove_rest", 14, 10, "ww_28_vine_cathedral"),
        ("ww_28_vine_cathedral", 16, 14, "ww_29_ironroot_overlook"),
        ("ww_29_ironroot_overlook", 18, 10, "ww_30_cart_bypass"),
        ("ww_30_cart_bypass", 20, 8, "ww_31_anchor_loft"),
        ("ww_31_anchor_loft", 14, 12, "ww_32_matron_backtrail"),
        ("ww_32_matron_backtrail", 16, 10, "ww_33_whisper_depths"),
        ("ww_33_whisper_depths", 18, 12, "ww_34_spore_sink"),
        ("ww_34_spore_sink", 14, 10, "ww_35_larva_nursery"),
        ("ww_35_larva_nursery", 16, 12, "ww_36_hunter_roost"),
        ("ww_36_hunter_roost", 18, 10, "ww_37_garden_remnant"),
        ("ww_37_garden_remnant", 16, 10, None),
    ]

    for i, (rid, wt, ht, nxt) in enumerate(explore_chain):
        entry = {
            "id": rid,
            "width": wt,
            "height": ht,
            "enemies": [(wt * TILE // 2, sy(ht))] if i % 3 == 0 else [],
            "enemy_type": ["mothling", "wraith", "larva", "stalker"][i % 4],
            "transitions": [],
        }
        if i == 0:
            entry["transitions"].append({"name": "FromGlen", "x": 12, "y": sy(ht), "target": "ww_05_spore_glen", "spawn": "from_explore"})
        if nxt:
            entry["transitions"].append({"name": "East", "x": wt * TILE - 12, "y": sy(ht), "target": nxt, "spawn": "default"})
            entry["transitions"].append({"name": "West", "x": 12, "y": sy(ht), "target": explore_chain[i - 1][0] if i > 0 else "ww_05_spore_glen", "spawn": "from_explore" if i == 0 else "default"})
        specs.append(entry)

    return specs


def patch_slice_transitions() -> None:
    """Add secret/upper-canopy transitions to existing slice rooms."""
    patches = {
        "ww_02_whisper_path.tscn": (
            '\n[node name="ToWhisperLoop" parent="RoomTransitions" instance=ExtResource("3_door")]\n'
            "position = Vector2(320, 412)\n"
            'target_room_id = &"ww_s02_whisper_loop"\n'
            'spawn_marker = &"default"\n'
        ),
        "ww_05_spore_glen.tscn": (
            '\n[node name="DestructibleWall" parent="." instance=ExtResource("5_destruct")]\n'
            "position = Vector2(960, 412)\n"
            'gate_id = &"ww_s01_bark_wall"\n'
            'target_room_id = &"ww_s01_gardener_cache"\n'
            'spawn_marker = &"default"\n'
            '\n[node name="ToExplore" parent="RoomTransitions" instance=ExtResource("3_door")]\n'
            "position = Vector2(64, 412)\n"
            'target_room_id = &"ww_18_moss_bridge"\n'
            'spawn_marker = &"default"\n'
        ),
        "ww_09_canopy_walk.tscn": (
            '\n[node name="ArcStepGate" parent="AbilityGates" instance=ExtResource("5_arcgate")]\n'
            "position = Vector2(1400, 380)\n"
            'gate_id = &"ww_s03_trunk"\n'
            'target_room_id = &"ww_s03_canopy_nest"\n'
            'spawn_marker = &"default"\n'
        ),
        "ww_08_vine_lift.tscn": (
            '\n[node name="ToUpperCanopy" parent="RoomTransitions" instance=ExtResource("3_door")]\n'
            "position = Vector2(448, 200)\n"
            'target_room_id = &"ww_17_upper_canopy"\n'
            'spawn_marker = &"default"\n'
        ),
        "ww_11_heartwood_grove.tscn": (
            '\n[node name="VineDropShortcut" parent="RoomTransitions" instance=ExtResource("3_door")]\n'
            "position = Vector2(576, 500)\n"
            'target_room_id = &"ww_01_forest_gate"\n'
            'spawn_marker = &"from_shortcut"\n'
        ),
        "ww_01_forest_gate.tscn": (
            '\n[node name="Waystone" parent="." instance=ExtResource("5_waystone")]\n'
            "position = Vector2(200, 412)\n"
            'waystone_id = &"ww_forest_entrance"\n'
            '\n[node name="from_shortcut" type="Marker2D" parent="SpawnPoints"]\n'
            "position = Vector2(400, 412)\n"
        ),
    }

    for filename, snippet in patches.items():
        path = ROOMS / filename
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        if "ww_s01" in snippet and "DestructibleWall" in snippet and "DestructibleWall" in text:
            continue
        if "ww_s02" in snippet and "ToWhisperLoop" in text:
            continue
        if "ArcStepGate" in snippet and "ArcStepGate" in text:
            continue
        if "ToUpperCanopy" in snippet and "ToUpperCanopy" in text:
            continue
        if "VineDropShortcut" in snippet and "VineDropShortcut" in text:
            continue
        if "ww_forest_entrance" in snippet and "ww_forest_entrance" in text:
            continue

        if "DestructibleWall" in snippet or "ArcStepGate" in snippet or "Waystone" in snippet:
            load_match = re.search(r"load_steps=(\d+)", text)
            if load_match:
                steps = int(load_match.group(1))
                if "DestructibleWall" in snippet and "destruct" not in text:
                    text = text.replace(
                        f"load_steps={steps}",
                        f"load_steps={steps + 1}",
                        1,
                    )
                    insert_at = text.find("[node name=")
                    ext = f'[ext_resource type="PackedScene" path="{DESTRUCTIBLE}" id="{steps}_destruct"]\n\n'
                    if "ArcStepGate" in snippet:
                        ext = f'[ext_resource type="PackedScene" path="{ARC_GATE}" id="{steps}_arcgate"]\n\n'
                    if "Waystone" in snippet:
                        ext = f'[ext_resource type="PackedScene" path="{WAYSTONE}" id="{steps}_waystone"]\n\n'
                    text = text[:insert_at] + ext + text[insert_at:]

        if "AbilityGates" not in text and "ArcStepGate" in snippet:
            rt = text.find('[node name="RoomTransitions"')
            text = text[:rt] + '[node name="AbilityGates" type="Node2D" parent="."]\n\n' + text[rt:]

        text = text.rstrip() + snippet
        path.write_text(text + "\n", encoding="utf-8")
        print(f"  patched transitions in {path.relative_to(ROOT)}")


def main() -> None:
    print("Generating enemy scenes...")
    write_enemy_scene("MothlingSwarm", "res://scripts/enemies/mothling_swarm.gd", "res://resources/enemies/e_07_mothling_swarm.tres", "Color(0.85, 0.95, 0.78, 0.9)")
    write_enemy_scene("BarkWraith", "res://scripts/enemies/bark_wraith.gd", "res://resources/enemies/e_12_bark_wraith.tres", "Color(0.45, 0.55, 0.42, 1)")
    write_enemy_scene("ThornweftLarva", "res://scripts/enemies/thornweft_larva.gd", "res://resources/enemies/e_15_thornweft_larva.tres", "Color(0.35, 0.72, 0.55, 1)")
    write_enemy_scene("CanopyHunter", "res://scripts/enemies/canopy_hunter.gd", "res://resources/enemies/e_18_canopy_hunter.tres", "Color(0.28, 0.62, 0.38, 1)", "Vector2(1.2, 1.2)")

    print("Generating Phase 5 rooms...")
    for spec in build_phase5_specs():
        write_room(spec)

    print("Patching slice rooms...")
    patch_slice_room_enemies()
    patch_slice_transitions()
    print("Done.")


if __name__ == "__main__":
    main()
