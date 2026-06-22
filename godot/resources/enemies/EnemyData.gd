class_name EnemyData
extends Resource
## Data-driven enemy stats and rewards.


@export var id: StringName = &""
@export var display_name: String = ""
@export var max_hp: int = 40
@export var move_speed: float = 80.0
@export var chase_speed: float = 120.0
@export var contact_damage: int = 10
@export var attack_damage: int = 12
@export var detection_radius: float = 160.0
@export var attack_range: float = 48.0
@export var poise: float = 10.0
@export var xp_reward: int = 18
@export var essence_reward: int = 8
@export var damage_multipliers: Dictionary = {
	&"physical": 0.8,
	&"fire": 1.5,
}
