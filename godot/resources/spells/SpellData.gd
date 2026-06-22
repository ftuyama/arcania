class_name SpellData
extends Resource
## Spell resource schema. See docs/08-technical-architecture.md §9.

enum SpellTier { BASE, ATTUNED, RESONANT }
enum SpellCategory { COMBAT, EXPLORATION, HYBRID }
enum AimMode { DIRECTIONAL_8, TARGET, SELF, AREA }

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var category: SpellCategory = SpellCategory.HYBRID

@export_group("Costs")
@export var mana_cost: int = 8
@export var cooldown: float = 0.4
@export var cast_time: float = 0.15
@export var can_overcast: bool = true

@export_group("Combat")
@export var base_damage: int = 12
@export var poise_damage: float = 8.0
@export var aim_mode: AimMode = AimMode.DIRECTIONAL_8
@export var effect_scene: PackedScene

@export_group("Exploration")
@export var gate_type: StringName = &""
@export var exploration_tags: Array[StringName] = []

@export_group("Upgrades")
@export var tier: SpellTier = SpellTier.BASE
@export var attuned_variant: SpellData
@export var resonant_variant: SpellData

@export_group("Audio / VFX")
@export var cast_sfx: AudioStream
@export var impact_sfx: AudioStream


func get_effective_cost(modifiers: Dictionary) -> int:
	var cost := mana_cost
	if modifiers.has("spell_cost_flat"):
		cost += modifiers["spell_cost_flat"]
	if modifiers.has("spell_cost_mult"):
		cost = int(cost * modifiers["spell_cost_mult"])
	return maxi(cost, 1)
