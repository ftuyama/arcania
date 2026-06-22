extends Node
## Relics, robes, focus items, and modifier aggregation.


const MAX_RELIC_SLOTS := 8
const BASE_RELIC_SLOTS := 6

const RELIC_PATHS: Array[String] = [
	"res://resources/relics/cinder_heart.tres",
	"res://resources/relics/gloom_lens.tres",
	"res://resources/relics/iron_grip.tres",
	"res://resources/relics/frost_nail.tres",
	"res://resources/relics/mist_walker.tres",
	"res://resources/relics/thornseed_charm.tres",
]

var _registry: Dictionary = {}
var _owned: Array[StringName] = []
var _equipped: Array[StringName] = []
var _robe_id: StringName = &"ash_worn_novice"
var _focus_id: StringName = &""
var _currency: Dictionary = {"weave_silk": 0, "ley_residue": 0, "shard_dust": 0}
var _consumed_relics: Array[StringName] = []


func _ready() -> void:
	for path in RELIC_PATHS:
		var relic := load(path) as RelicData
		if relic:
			_registry[relic.id] = relic
	EventBus.relic_acquired.connect(_on_relic_acquired_external)


func _exit_tree() -> void:
	if EventBus.relic_acquired.is_connected(_on_relic_acquired_external):
		EventBus.relic_acquired.disconnect(_on_relic_acquired_external)


func get_relic(relic_id: StringName) -> RelicData:
	return _registry.get(relic_id) as RelicData


func owns_relic(relic_id: StringName) -> bool:
	return relic_id in _owned


func is_equipped(relic_id: StringName) -> bool:
	return relic_id in _equipped


func get_equipped_relics() -> Array[StringName]:
	return _equipped.duplicate()


func get_owned_relics() -> Array[StringName]:
	return _owned.duplicate()


func get_relic_slot_count() -> int:
	return BASE_RELIC_SLOTS


func acquire_relic(relic_id: StringName) -> void:
	if relic_id in _owned or relic_id in _consumed_relics:
		return
	if not _registry.has(relic_id):
		push_warning("InventorySystem: unknown relic %s" % relic_id)
		return
	_owned.append(relic_id)
	if _equipped.size() < BASE_RELIC_SLOTS:
		_equipped.append(relic_id)
		_apply_modifiers_to_player()
	EventBus.relic_acquired.emit(relic_id)


func equip_relic(relic_id: StringName) -> bool:
	if relic_id not in _owned:
		return false
	if relic_id in _equipped:
		return true
	if _equipped.size() >= BASE_RELIC_SLOTS:
		return false
	_equipped.append(relic_id)
	_apply_modifiers_to_player()
	return true


func unequip_relic(relic_id: StringName) -> void:
	_equipped.erase(relic_id)
	_apply_modifiers_to_player()


func add_currency(type: String, amount: int) -> void:
	if not _currency.has(type):
		_currency[type] = 0
	_currency[type] = int(_currency.get(type, 0)) + amount


func get_currency(type: String) -> int:
	return int(_currency.get(type, 0))


func get_aggregated_modifiers() -> Dictionary:
	var entries: Array[ModifierEntry] = []
	var used_tags: Dictionary = {}
	for relic_id in _equipped:
		var relic := get_relic(relic_id)
		if relic == null:
			continue
		if not relic.unique_tag.is_empty() and used_tags.has(relic.unique_tag):
			continue
		if not relic.unique_tag.is_empty():
			used_tags[relic.unique_tag] = true
		for mod in relic.modifiers:
			if mod:
				entries.append(mod)
	return ModifierStack.aggregate(entries)


func get_modifier(stat: StringName) -> Variant:
	var mods := get_aggregated_modifiers()
	return mods.get(String(stat))


func _apply_modifiers_to_player() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null:
		return
	var mods := get_aggregated_modifiers()
	var base_hp := 100
	var base_mana := player.mana_component.focus_shard_count * ManaComponent.MANA_PER_SHARD
	if mods.has("max_hp"):
		player.health_component.max_hp = maxi(base_hp + int(mods["max_hp"]), 1)
		player.health_component.current_hp = mini(
			player.health_component.current_hp,
			player.health_component.max_hp
		)
	if mods.has("max_mana"):
		player.mana_component.max_mana = maxi(base_mana + int(mods["max_mana"]), 1)
		player.mana_component.current_mana = minf(
			player.mana_component.current_mana,
			float(player.mana_component.max_mana)
		)
	if mods.has("mana_regen_mult"):
		player.mana_component.combat_regen_rate = 2.0 * float(mods["mana_regen_mult"])


func get_save_data() -> Dictionary:
	var owned_str: Array[String] = []
	var equipped_str: Array[String] = []
	for id in _owned:
		owned_str.append(String(id))
	for id in _equipped:
		equipped_str.append(String(id))
	return {
		"relics_equipped": equipped_str,
		"relics_owned": owned_str,
		"robe_id": String(_robe_id),
		"focus_id": String(_focus_id),
		"currency": _currency.duplicate(),
		"consumed_relics": _consumed_relics.map(func(id: StringName) -> String: return String(id)),
	}


func apply_save_data(data: Dictionary) -> void:
	_owned.clear()
	_equipped.clear()
	for relic_str in data.get("relics_owned", []):
		var relic_id := StringName(relic_str)
		if _registry.has(relic_id):
			_owned.append(relic_id)
	for relic_str in data.get("relics_equipped", []):
		var relic_id := StringName(relic_str)
		if relic_id in _owned and relic_id not in _equipped:
			_equipped.append(relic_id)
	_robe_id = StringName(data.get("robe_id", ""))
	_focus_id = StringName(data.get("focus_id", ""))
	_currency = data.get("currency", {"weave_silk": 0, "ley_residue": 0, "shard_dust": 0}).duplicate()
	_consumed_relics.clear()
	for relic_str in data.get("consumed_relics", []):
		_consumed_relics.append(StringName(relic_str))
	call_deferred(&"_apply_modifiers_to_player")


func reset_to_defaults() -> void:
	_owned.clear()
	_equipped.clear()
	_robe_id = &"ash_worn_novice"
	_focus_id = &""
	_currency = {"weave_silk": 0, "ley_residue": 0, "shard_dust": 0}
	_consumed_relics.clear()


func _on_relic_acquired_external(_relic_id: StringName) -> void:
	pass
