extends Area2D
## Save anchor — interact to rest (HP + mana), save, and set respawn point.


@export var crucible_id: StringName = &""
@export var interact_radius: float = 48.0

var _prompt: Label


func _ready() -> void:
	collision_layer = 512
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_apply_interact_radius()
	_build_prompt()


func _exit_tree() -> void:
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)
	if body_exited.is_connected(_on_body_exited):
		body_exited.disconnect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not _prompt.visible:
		return
	if not event.is_action_pressed(&"interact"):
		return
	if not _player_nearby():
		return
	_activate()
	get_viewport().set_input_as_handled()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player") and _prompt:
		_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player") and _prompt:
		_prompt.visible = false


func _player_nearby() -> bool:
	for body in get_overlapping_bodies():
		if body.is_in_group(&"player"):
			return true
	return false


func _activate() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null:
		return

	player.health_component.current_hp = player.health_component.max_hp
	player.mana_component.restore_full()
	player.set_respawn_position(global_position)
	GameManager.bind_crucible_rest(crucible_id, GameManager.current_room_id, global_position)

	var saved := SaveManager.save_game(&"save_01")
	SaveManager.save_game(&"autosave")
	if saved:
		EventBus.anchor_activated.emit(crucible_id)
		AudioManager.play_sfx("res://assets/audio/sfx/ui/ui_menu_confirm.wav", global_position)
		EventBus.ui_toast.emit("Rested at Focus Crucible.")


func _apply_interact_radius() -> void:
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node and shape_node.shape is CircleShape2D:
		(shape_node.shape as CircleShape2D).radius = interact_radius


func _build_prompt() -> void:
	_prompt = Label.new()
	_prompt.text = "[E] Rest at Focus Crucible"
	_prompt.position = Vector2(-80, -56)
	_prompt.visible = false
	_prompt.add_theme_font_size_override(&"font_size", 12)
	add_child(_prompt)
