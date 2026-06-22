extends Area2D
## Grapple target for Rune Anchor.


@export var anchor_id: StringName = &""

var is_active: bool = true


func _ready() -> void:
	add_to_group(&"anchor_points")
	collision_layer = 256
	collision_mask = 0
