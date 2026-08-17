extends BaseBoss
## MB-01 Thornweft Matron — 2-phase vine boss with Phase II arena shrink.


const ARENA_SHRINK_SCALE := 0.72
const MOVE_SPEED := 68.0
const MOVE_ACCELERATION := 240.0
const PATROL_RANGE := 168.0
const PATROL_MIN_DURATION := 0.8
const PATROL_MAX_DURATION := 1.6
const IDLE_SWAY_SPEED := 2.4
const IDLE_SWAY_HEIGHT := 3.0

var _arena_shape: RectangleShape2D
var _arena_base_size: Vector2 = Vector2(1152, 540)
var _arena_base_position: Vector2 = Vector2(576, 270)
var _sprite_base_position := Vector2.ZERO
var _idle_time := 0.0
var _home_position := Vector2.ZERO
var _patrol_direction := 1.0
var _patrol_time := 0.0


func _ready() -> void:
	super._ready()
	_sprite_base_position = animated_sprite.position
	_home_position = global_position
	if arena_boundary:
		var shape_node := arena_boundary.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_node and shape_node.shape is RectangleShape2D:
			_arena_shape = shape_node.shape as RectangleShape2D
			_arena_base_size = _arena_shape.size
			_arena_base_position = shape_node.position


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_idle_time += delta
	animated_sprite.position = _sprite_base_position + Vector2(
		0.0,
		roundf(sin(_idle_time * IDLE_SWAY_SPEED) * IDLE_SWAY_HEIGHT)
	)
	animated_sprite.rotation = sin(_idle_time * IDLE_SWAY_SPEED * 0.5) * 0.025
	if not _fight_active or _defeated or player == null:
		return
	_update_patrol(delta)
	velocity.y = 0.0
	move_and_slide()
	global_position.x = clampf(
		global_position.x,
		_home_position.x - PATROL_RANGE,
		_home_position.x + PATROL_RANGE
	)


func start_fight() -> void:
	if _fight_active:
		return
	_fight_active = true
	EventBus.boss_fight_started.emit(data.id if data else &"")


func _update_patrol(delta: float) -> void:
	_patrol_time -= delta
	var left_bound := _home_position.x - PATROL_RANGE
	var right_bound := _home_position.x + PATROL_RANGE
	if global_position.x <= left_bound:
		_patrol_direction = 1.0
	elif global_position.x >= right_bound:
		_patrol_direction = -1.0
	elif _patrol_time <= 0.0:
		_patrol_direction = signf(player.global_position.x - global_position.x)
		if is_zero_approx(_patrol_direction):
			_patrol_direction = 1.0 if randf() > 0.5 else -1.0
		_patrol_time = randf_range(PATROL_MIN_DURATION, PATROL_MAX_DURATION)
	face_player()
	velocity.x = move_toward(velocity.x, _patrol_direction * MOVE_SPEED, MOVE_ACCELERATION * delta)


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
	if player == null:
		return
	var rain_pos := player.global_position
	var indicator := telegraph as Node2D
	var indicator_position := indicator.position
	indicator.global_position = rain_pos + Vector2(-22.0, -28.0)
	indicator.scale.x = 1.0
	play_animation(&"telegraph")
	indicator.visible = true
	indicator.modulate = Color(0.95, 0.22, 0.18, 0.95)
	CombatJuice.on_boss_telegraph(2)
	await get_tree().create_timer(0.55).timeout
	if not is_instance_valid(indicator):
		return
	if player == null:
		indicator.visible = false
		indicator.position = indicator_position
		return
	hitbox_component.damage = 10
	hitbox_component.damage_type = &"nature"
	hitbox_component.knockback_vector = Vector2(0, -80)
	hitbox_component.global_position = rain_pos
	hitbox_component.enable_hitbox()
	await get_tree().create_timer(0.22).timeout
	hitbox_component.disable_hitbox()
	indicator.visible = false
	indicator.position = indicator_position
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
