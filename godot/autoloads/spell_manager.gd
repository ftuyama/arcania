extends Node
## Spell wheel loadout, quick slots, and casting helpers.


const STARTER_SPELLS: Array[StringName] = [&"ember_sigil", &"ember_bolt"]
const WHEEL_SIZE := 8
const QUICK_SLOT_COUNT := 4

const SPELL_PATHS: Array[String] = [
	"res://resources/spells/ember_sigil.tres",
	"res://resources/spells/veil_step.tres",
	"res://resources/spells/ember_bolt.tres",
	"res://resources/spells/rootbind.tres",
	"res://resources/spells/arc_step.tres",
	"res://resources/spells/rune_anchor.tres",
]

var _registry: Dictionary = {}
var _acquired: Array[StringName] = []
var _cooldowns: Dictionary = {}
var _wheel: Array[StringName] = []
var _quick_slots: Array[StringName] = []


func _ready() -> void:
	_wheel.resize(WHEEL_SIZE)
	_quick_slots.resize(QUICK_SLOT_COUNT)
	for path in SPELL_PATHS:
		var spell := load(path) as SpellData
		if spell:
			_registry[spell.id] = spell
	for spell_id in STARTER_SPELLS:
		if spell_id in _registry:
			_acquired.append(spell_id)
			_cooldowns[spell_id] = 0.0
	_init_default_loadout()


func _init_default_loadout() -> void:
	var defaults: Array[StringName] = [&"ember_sigil", &"ember_bolt", &"rootbind", &"veil_step"]
	for i in QUICK_SLOT_COUNT:
		if i < defaults.size() and has_spell(defaults[i]):
			_quick_slots[i] = defaults[i]
		else:
			_quick_slots[i] = &""
	for i in WHEEL_SIZE:
		if i < _acquired.size():
			_wheel[i] = _acquired[i]
		else:
			_wheel[i] = &""


func _process(delta: float) -> void:
	for spell_id in _cooldowns.keys():
		if _cooldowns[spell_id] > 0.0:
			_cooldowns[spell_id] = maxf(_cooldowns[spell_id] - delta, 0.0)


func get_spell(spell_id: StringName) -> SpellData:
	return _registry.get(spell_id) as SpellData


func has_spell(spell_id: StringName) -> bool:
	return spell_id in _acquired


func acquire_spell(spell_id: StringName) -> void:
	if spell_id in _acquired:
		return
	if not _registry.has(spell_id):
		push_warning("SpellManager: unknown spell %s" % spell_id)
		return
	_acquired.append(spell_id)
	_cooldowns[spell_id] = 0.0
	for i in WHEEL_SIZE:
		if _wheel[i].is_empty():
			_wheel[i] = spell_id
			break
	if spell_id == &"veil_step" and _quick_slots[2].is_empty():
		_quick_slots[2] = spell_id
	EventBus.spell_acquired.emit(spell_id)


func get_wheel_slot(index: int) -> StringName:
	if index < 0 or index >= WHEEL_SIZE:
		return &""
	return _wheel[index]


func set_wheel_slot(index: int, spell_id: StringName) -> void:
	if index < 0 or index >= WHEEL_SIZE:
		return
	if not spell_id.is_empty() and not has_spell(spell_id):
		return
	_wheel[index] = spell_id


func get_quick_slot(index: int) -> StringName:
	if index < 0 or index >= QUICK_SLOT_COUNT:
		return &""
	return _quick_slots[index]


func set_quick_slot(index: int, spell_id: StringName) -> void:
	if index < 0 or index >= QUICK_SLOT_COUNT:
		return
	if not spell_id.is_empty() and not has_spell(spell_id):
		return
	_quick_slots[index] = spell_id


func get_wheel_spells() -> Array[StringName]:
	return _wheel.duplicate()


func get_acquired_spells() -> Array[StringName]:
	return _acquired.duplicate()


func is_on_cooldown(spell_id: StringName) -> bool:
	return float(_cooldowns.get(spell_id, 0.0)) > 0.0


func get_cooldown_remaining(spell_id: StringName) -> float:
	return float(_cooldowns.get(spell_id, 0.0))


func can_cast(spell_id: StringName, caster_mana: float) -> bool:
	if not has_spell(spell_id):
		return false
	if is_on_cooldown(spell_id):
		return false
	var spell := get_spell(spell_id)
	if spell == null:
		return false
	var cost := get_effective_cost(spell_id)
	return caster_mana >= float(cost) or spell.can_overcast


func get_effective_cost(spell_id: StringName) -> int:
	var spell := get_spell(spell_id)
	if spell == null:
		return 0
	return spell.get_effective_cost(InventorySystem.get_aggregated_modifiers())


func get_effective_cooldown(spell_id: StringName) -> float:
	var spell := get_spell(spell_id)
	if spell == null:
		return 0.0
	var mods := InventorySystem.get_aggregated_modifiers()
	var cd := spell.cooldown
	if spell_id == &"veil_step" and mods.has("veil_step_cooldown_flat"):
		cd += float(mods["veil_step_cooldown_flat"])
	return maxf(cd, 0.1)


func start_cooldown(spell_id: StringName) -> void:
	_cooldowns[spell_id] = get_effective_cooldown(spell_id)


func get_save_data() -> Dictionary:
	var acquired_str: Array[String] = []
	var wheel_str: Array[String] = []
	var quick_str: Array[String] = []
	for id in _acquired:
		acquired_str.append(String(id))
	for id in _wheel:
		wheel_str.append(String(id))
	for id in _quick_slots:
		quick_str.append(String(id))
	return {
		"acquired": acquired_str,
		"wheel": wheel_str,
		"quick_slots": quick_str,
		"upgrades": {},
	}


func apply_save_data(data: Dictionary) -> void:
	_acquired.clear()
	for spell_str in data.get("acquired", []):
		var spell_id := StringName(spell_str)
		if _registry.has(spell_id):
			_acquired.append(spell_id)
			_cooldowns[spell_id] = 0.0
	_wheel.clear()
	for spell_str in data.get("wheel", []):
		_wheel.append(StringName(spell_str))
	while _wheel.size() < WHEEL_SIZE:
		_wheel.append(&"")
	_quick_slots.clear()
	for spell_str in data.get("quick_slots", []):
		_quick_slots.append(StringName(spell_str))
	while _quick_slots.size() < QUICK_SLOT_COUNT:
		_quick_slots.append(&"")
	if _wheel[0].is_empty() and not _acquired.is_empty():
		_init_default_loadout()


func reset_to_defaults() -> void:
	_acquired.clear()
	_cooldowns.clear()
	for spell_id in STARTER_SPELLS:
		if spell_id in _registry:
			_acquired.append(spell_id)
			_cooldowns[spell_id] = 0.0
	_init_default_loadout()
