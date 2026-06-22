class_name ModifierEntry
extends Resource
## Single stat modifier on a relic or robe.

enum ModifierOp { FLAT_ADD, PERCENT_ADD, MULTIPLY }

@export var stat: StringName = &""
@export var value: float = 0.0
@export var op: ModifierOp = ModifierOp.FLAT_ADD
