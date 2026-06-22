class_name ModifierStack
extends RefCounted
## Aggregates modifier entries per docs/08-technical-architecture.md §11 rules.


const MAX_MANA_CAP := 220
const IFRAME_CAP := 6


static func aggregate(entries: Array[ModifierEntry]) -> Dictionary:
	var flats: Dictionary = {}
	var multiplies: Dictionary = {}

	for entry in entries:
		if entry == null or entry.stat.is_empty():
			continue
		var key := String(entry.stat)
		match entry.op:
			ModifierEntry.ModifierOp.FLAT_ADD, ModifierEntry.ModifierOp.PERCENT_ADD:
				flats[key] = float(flats.get(key, 0.0)) + entry.value
			ModifierEntry.ModifierOp.MULTIPLY:
				multiplies[key] = float(multiplies.get(key, 1.0)) * entry.value

	var result: Dictionary = flats.duplicate()
	for key in multiplies.keys():
		if result.has(key):
			result[key] = float(result[key]) * multiplies[key]
		else:
			result[key] = multiplies[key]

	if result.has("max_mana"):
		result["max_mana"] = mini(int(result["max_mana"]), MAX_MANA_CAP)
	if result.has("i_frame_bonus"):
		result["i_frame_bonus"] = mini(int(result["i_frame_bonus"]), IFRAME_CAP)
	return result
