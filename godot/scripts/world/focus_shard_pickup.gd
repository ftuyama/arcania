extends Area2D
## Collectible Focus Shard — expands mana capacity by one segment (10 mana).


@export var pickup_id: StringName = &""
@export var shard_value: int = 1

@onready var _visual: ColorRect = $Visual


func _ready() -> void:
	add_to_group(&"pickups")
	collision_layer = 512
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	if pickup_id and GameManager.is_pickup_collected(pickup_id):
		queue_free()
		return
	if _visual:
		_visual.color = Color(0.0, 0.85, 0.95, 0.9)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player"):
		return
	var player := body as Player
	if player == null:
		return
	if not player.mana_component.add_focus_shards(shard_value):
		return
	if pickup_id:
		GameManager.mark_pickup_collected(pickup_id)
	AudioManager.play_sfx("res://assets/audio/sfx/ui/ui_menu_confirm.wav", global_position)
	EventBus.ui_toast.emit("Focus Shard acquired (+10 mana)")
	queue_free()
