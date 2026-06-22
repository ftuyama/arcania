class_name BossData
extends Resource
## Boss stats and phase metadata. See docs/08-technical-architecture.md §8.

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export var region_id: StringName = &""

@export_group("Combat")
@export var max_hp: int = 400
@export var poise: float = 100.0
@export var essence_reward: int = 120
@export var phase_thresholds: Array[float] = [0.5]

@export_group("Rewards")
@export var spell_unlock: StringName = &""
@export var world_flag: StringName = &""
