extends BaseBoss
## MB-01 Thornweft Matron — 2-phase vine boss with Phase II arena shrink.


const ARENA_SHRINK_SCALE := 0.72

var _arena_shape: RectangleShape2D
var _arena_base_size: Vector2 = Vector2(1152, 540)
var _arena_base_position: Vector2 = Vector2(576, 270)


func _ready() -> void:
	super._ready()
	if arena_boundary:
		var shape_node := arena_boundary.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_node and shape_node.shape is RectangleShape2D:
			_arena_shape = shape_node.shape as RectangleShape2D
			_arena_base_size = _arena_shape.size
			_arena_base_position = shape_node.position


func _perform_attack() -> void:
	if player == null:
		return
	face_player()
	if phase_manager.current_phase == 0:
		await _vine_lash()
	else:
		if randf() > 0.5:
			await _canopy_rain()
		else:
			await _vine_lash()


func _vine_lash() -> void:
	await show_telegraph(0.25, Color(1.0, 0.7, 0.2, 0.9), 1)
	play_animation(&"attack")
	hitbox_component.damage = 12
	hitbox_component.damage_type = &"nature"
	hitbox_component.knockback_vector = Vector2(
		140.0 * (1.0 if player.global_position.x >= global_position.x else -1.0),
		-60.0
	)
	var offset_x := 48.0 * (1.0 if player.global_position.x >= global_position.x else -1.0)
	hitbox_component.global_position = global_position + Vector2(offset_x, -8.0)
	hitbox_component.enable_hitbox()
	await get_tree().create_timer(0.18).timeout
	hitbox_component.disable_hitbox()
	play_animation(&"idle")


func _canopy_rain() -> void:
	await show_telegraph(0.35, Color(0.8, 0.15, 0.2, 0.85), 2)
	if player == null:
		return
	var rain_pos := player.global_position
	hitbox_component.damage = 10
	hitbox_component.damage_type = &"nature"
	hitbox_component.knockback_vector = Vector2(0, -80)
	hitbox_component.global_position = rain_pos
	hitbox_component.enable_hitbox()
	await get_tree().create_timer(0.22).timeout
	hitbox_component.disable_hitbox()
	play_animation(&"idle")


func _on_phase_enter(phase: int) -> void:
	if phase == 1:
		play_animation(&"phase2")
		_shrink_arena()


func _shrink_arena() -> void:
	if _arena_shape == null:
		return
	var shape_node := arena_boundary.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null:
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_arena_shape, "size", _arena_base_size * ARENA_SHRINK_SCALE, 0.8)
	tween.tween_property(shape_node, "position", _arena_base_position, 0.8)
	EventBus.ui_toast.emit("The canopy closes in!")
	CombatJuice.request_screen_shake(6.0, 0.2)
