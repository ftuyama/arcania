#!/usr/bin/env python3
"""Patch Whisperwood slice rooms for Phase 5 Sprint 1."""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ROOMS = ROOT / "godot" / "scenes" / "rooms" / "whisperwood_hollow"

ENEMIES = {
    "mothling": "res://scenes/enemies/mothling_swarm.tscn",
    "wraith": "res://scenes/enemies/bark_wraith.tscn",
    "larva": "res://scenes/enemies/thornweft_larva.tscn",
    "stalker": "res://scenes/enemies/bramble_stalker.tscn",
}


def swap_enemy(text: str, enemy_key: str) -> str:
	path = ENEMIES[enemy_key]
	match = re.search(
		r'\[ext_resource type="PackedScene" path="res://scenes/enemies/[^"]+" id="(\d+)_(\w+)"\]',
		text,
	)
	if not match:
		return text
	old_id = f"{match.group(1)}_{match.group(2)}"
	new_id = f"{match.group(1)}_enemy"
	text = re.sub(
		rf'\[ext_resource type="PackedScene" path="res://scenes/enemies/[^"]+" id="{re.escape(old_id)}"\]',
		f'[ext_resource type="PackedScene" path="{path}" id="{new_id}"]',
		text,
		count=1,
	)
	text = text.replace(f'ExtResource("{old_id}")', f'ExtResource("{new_id}")')
	text = re.sub(r"Stalker(\d+)", r"Enemy\1", text)
	return text


def add_ext(text: str, path: str, suffix: str) -> tuple[str, str]:
	if path.split("/")[-1].replace(".tscn", "") in text:
		for line in text.splitlines():
			if path in line and 'id="' in line:
				return text, line.split('id="')[1].split('"')[0]
		return text, ""
	m = re.search(r"load_steps=(\d+)", text)
	if not m:
		return text, ""
	steps = int(m.group(1))
	ext_id = f"{steps}_{suffix}"
	text = text.replace(f"load_steps={steps}", f"load_steps={steps + 1}", 1)
	insert = f'[ext_resource type="PackedScene" path="{path}" id="{ext_id}"]\n\n'
	idx = text.find("[node name=")
	return text[:idx] + insert + text[idx:], ext_id


def patch_file(name: str, enemy: str | None, append: str, extras: list[tuple[str, str]] | None = None) -> None:
	path = ROOMS / name
	text = path.read_text(encoding="utf-8")
	if enemy:
		text = swap_enemy(text, enemy)
	for ext_path, suffix in extras or []:
		text, ext_id = add_ext(text, ext_path, suffix)
		if ext_id:
			append = append.replace("5_relic", ext_id)
	if append.strip() and append.strip() not in text:
		text = text.rstrip() + "\n" + append
	path.write_text(text + "\n", encoding="utf-8")
	print(f"patched {name}")


def main() -> None:
    patch_file(
        "ww_02_whisper_path.tscn",
        "mothling",
        """
[node name="ToWhisperLoop" parent="RoomTransitions" instance=ExtResource("3_door")]
position = Vector2(320, 448)
target_room_id = &"ww_s02_whisper_loop"
spawn_marker = &"default"

[node name="from_whisper" type="Marker2D" parent="SpawnPoints"]
position = Vector2(400, 420)
""",
    )

    patch_file(
        "ww_04_branch_crossing.tscn",
        "wraith",
        """
[node name="TreePhaseMarkers" type="Node2D" parent="."]

[node name="Tree0" type="Marker2D" parent="TreePhaseMarkers" groups=["tree_phase_markers"]]
position = Vector2(300, 676)

[node name="Tree1" type="Marker2D" parent="TreePhaseMarkers" groups=["tree_phase_markers"]]
position = Vector2(800, 676)
""",
    )

    patch_file(
        "ww_05_spore_glen.tscn",
        "mothling",
        """
[node name="RelicPickup" parent="." instance=ExtResource("5_relic")]
position = Vector2(960, 500)
relic_id = &"thornseed_charm"
pickup_id = &"ww_05_thornseed"

[node name="DestructibleWall" parent="." instance=ExtResource("6_destruct")]
position = Vector2(1180, 548)
gate_id = &"ww_s01_bark_wall"
target_room_id = &"ww_s01_gardener_cache"
spawn_marker = &"default"

[node name="ToExplore" parent="RoomTransitions" instance=ExtResource("3_door")]
position = Vector2(64, 576)
target_room_id = &"ww_18_moss_bridge"
spawn_marker = &"default"

[node name="from_cache" type="Marker2D" parent="SpawnPoints"]
position = Vector2(1100, 548)
""",
        extras=[
            ("res://scenes/components/relic_pickup.tscn", "relic"),
            ("res://scenes/components/destructible_bark_wall.tscn", "destruct"),
        ],
    )

    patch_file(
        "ww_09_canopy_walk.tscn",
        "larva",
        """
[node name="ArcStepGate" parent="AbilityGates" instance=ExtResource("5_arcgate")]
position = Vector2(1400, 380)
gate_id = &"ww_s03_trunk"
target_room_id = &"ww_s03_canopy_nest"
spawn_marker = &"default"

[node name="from_nest" type="Marker2D" parent="SpawnPoints"]
position = Vector2(1500, 420)
""",
        extras=[("res://scenes/components/arc_step_gate.tscn", "arcgate")],
    )

    patch_file(
        "ww_08_vine_lift.tscn",
        None,
        """
[node name="ToUpperCanopy" parent="RoomTransitions" instance=ExtResource("3_door")]
position = Vector2(448, 200)
target_room_id = &"ww_17_upper_canopy"
spawn_marker = &"default"

[node name="from_upper" type="Marker2D" parent="SpawnPoints"]
position = Vector2(448, 220)
""",
    )

    patch_file(
        "ww_01_forest_gate.tscn",
        None,
        """
[node name="Waystone" parent="." instance=ExtResource("5_waystone")]
position = Vector2(200, 548)
waystone_id = &"ww_forest_entrance"

[node name="from_shortcut" type="Marker2D" parent="SpawnPoints"]
position = Vector2(400, 548)
""",
        extras=[("res://scenes/components/waystone.tscn", "waystone")],
    )

    patch_file(
        "ww_11_heartwood_grove.tscn",
        None,
        """
[node name="VineDropShortcut" parent="RoomTransitions" instance=ExtResource("5_gated")]
position = Vector2(576, 500)
target_room_id = &"ww_01_forest_gate"
spawn_marker = &"from_shortcut"
required_boss_id = &"mb_01_thornweft_matron"
""",
        extras=[("res://scenes/components/gated_room_transition.tscn", "gated")],
    )

    patch_file(
        "ww_15_ironroot_depths.tscn",
        None,
        """
[node name="RelicPickup" parent="." instance=ExtResource("5_relic")]
position = Vector2(200, 900)
relic_id = &"iron_grip"
pickup_id = &"ww_15_iron_grip"
""",
        extras=[("res://scenes/components/relic_pickup.tscn", "relic")],
    )

    patch_file(
        "ww_37_garden_remnant.tscn",
        None,
        """
[node name="RelicPickup" parent="." instance=ExtResource("5_relic")]
position = Vector2(480, 412)
relic_id = &"frost_nail"
pickup_id = &"ww_37_frost_nail"
""",
        extras=[("res://scenes/components/relic_pickup.tscn", "relic")],
    )

    # ww_s02 return spawn
    s02 = (ROOMS / "ww_s02_whisper_loop.tscn").read_text(encoding="utf-8")
    if "from_whisper" not in s02:
        s02 = s02.replace(
            'spawn_marker = &"from_whisper"',
            'spawn_marker = &"from_whisper"',
        )
        s02 = s02.rstrip() + """
[node name="from_whisper" type="Marker2D" parent="SpawnPoints"]
position = Vector2(80, 740)
"""
        (ROOMS / "ww_s02_whisper_loop.tscn").write_text(s02 + "\n", encoding="utf-8")
        print("patched ww_s02_whisper_loop.tscn")


if __name__ == "__main__":
    main()
