extends Area2D
## Discoverable fast-travel anchor (Sigil Recall activation deferred).


@export var waystone_id: StringName = &""
@export var unlock_flag: StringName = &""

var _discovered: bool = false

@onready var _visual: AnimatedSprite2D = $Visual
@onready var _label: Label = $Label
@onready var _prompt: Label = $Prompt


func _ready() -> void:
	collision_layer = 128
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	HudStyle.apply_hud_font(_label, 12)
	HudStyle.apply_hud_font(_prompt, 12)
	_prompt.visible = false
	if not _is_unlocked():
		_label.text = "Dormant Waystone"
		return
	if waystone_id and GameManager.has_world_flag(StringName("waystone_%s" % waystone_id)):
		_discovered = true
		_visual.modulate = Color(0.75, 0.95, 1.0, 1.0)
		_label.text = "Waystone"


func _exit_tree() -> void:
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)
	if body_exited.is_connected(_on_body_exited):
		body_exited.disconnect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not _prompt.visible or not event.is_action_pressed(&"interact"):
		return
	if not _player_nearby():
		return
	_rest()
	get_viewport().set_input_as_handled()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player") or not _is_unlocked():
		return
	_discover()
	_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_prompt.visible = false


func _is_unlocked() -> bool:
	return unlock_flag.is_empty() or GameManager.has_world_flag(unlock_flag)


func _discover() -> void:
	if _discovered or waystone_id.is_empty():
		return
	_discovered = true
	GameManager.set_world_flag(StringName("waystone_%s" % waystone_id))
	MapManager.register_waystone(waystone_id, GameManager.current_room_id)
	_visual.modulate = Color(0.75, 0.95, 1.0, 1.0)
	_label.text = "Waystone"
	EventBus.ui_toast.emit("Waystone discovered.")


func _player_nearby() -> bool:
	for body in get_overlapping_bodies():
		if body.is_in_group(&"player"):
			return true
	return false


func _rest() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null:
		return
	player.health_component.restore_full()
	player.mana_component.restore_full()
	player.set_respawn_position(global_position)
	GameManager.bind_crucible_rest(waystone_id, GameManager.current_room_id, global_position)
	var saved := SaveManager.save_game(&"save_01")
	SaveManager.save_game(&"autosave")
	if saved:
		EventBus.anchor_activated.emit(waystone_id)
		AudioManager.play_sfx("res://assets/audio/sfx/ui/ui_menu_confirm.wav", global_position)
		EventBus.ui_toast.emit("Rested at Waystone.")
