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
	_build_ambient_fx()


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
	HudStyle.apply_hud_font(_prompt, 12)
	add_child(_prompt)


func _build_ambient_fx() -> void:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.35, 1.0])
	gradient.colors = PackedColorArray([
		Color(1.0, 0.42, 0.16, 0.7),
		Color(0.55, 0.18, 0.05, 0.22),
		Color(0.0, 0.0, 0.0, 0.0),
	])
	var light_texture := GradientTexture2D.new()
	light_texture.width = 96
	light_texture.height = 96
	light_texture.fill = GradientTexture2D.FILL_RADIAL
	light_texture.fill_from = Vector2(0.5, 0.5)
	light_texture.fill_to = Vector2(1.0, 0.5)
	light_texture.gradient = gradient

	var glow := PointLight2D.new()
	glow.name = &"EmberGlow"
	glow.position = Vector2(0, -29)
	glow.color = Color(1.0, 0.42, 0.16, 1.0)
	glow.energy = 0.45
	glow.texture = light_texture
	add_child(glow)

	var embers := CPUParticles2D.new()
	embers.name = &"Embers"
	embers.position = Vector2(0, -32)
	embers.amount = 8
	embers.lifetime = 1.4
	embers.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	embers.emission_sphere_radius = 5.0
	embers.direction = Vector2.UP
	embers.spread = 24.0
	embers.gravity = Vector2(0, -7)
	embers.initial_velocity_min = 6.0
	embers.initial_velocity_max = 13.0
	embers.scale_amount_min = 1.0
	embers.scale_amount_max = 2.0
	embers.color = Color(1.0, 0.42, 0.16, 0.9)
	add_child(embers)

	var sprite := get_node_or_null("Sprite") as Sprite2D
	var pulse := create_tween().set_loops()
	pulse.tween_property(glow, "energy", 0.62, 0.65).set_trans(Tween.TRANS_SINE)
	if sprite:
		pulse.parallel().tween_property(sprite, "scale", Vector2(1.03, 1.03), 0.65).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(glow, "energy", 0.42, 0.65).set_trans(Tween.TRANS_SINE)
	if sprite:
		pulse.parallel().tween_property(sprite, "scale", Vector2.ONE, 0.65).set_trans(Tween.TRANS_SINE)
