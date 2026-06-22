extends BaseEnemy
## E-12 — phases through trees, emerges to strike, then re-phases.


const PHASE_DURATION := 1.8
const EMERGE_DURATION := 0.35
const STRIKE_DURATION := 0.22

var _ai_state: StringName = &"patrol"
var _timer: float = 0.0
var _phase_target: Vector2 = Vector2.ZERO


func _ready() -> void:
	super._ready()
	state_machine.set_physics_process(false)
	health_component.damaged.disconnect(_on_damaged)
	health_component.damaged.connect(_on_custom_damaged)
	health_component.died.disconnect(_on_died)
	health_component.died.connect(_on_custom_died)
	animated_sprite.modulate = Color(0.45, 0.55, 0.42, 1.0)


func _physics_process(delta: float) -> void:
	if _ai_state == &"dead":
		return
	_timer -= delta
	if _ai_state == &"hit":
		if _timer <= 0.0:
			_ai_state = &"patrol"
		return
	match _ai_state:
		&"patrol":
			_patrol(delta)
		&"chase":
			_chase(delta)
		&"phase":
			_phase(delta)
		&"emerge":
			_emerge(delta)
		&"strike":
			_strike(delta)


func _patrol(delta: float) -> void:
	var player := get_player()
	var stats := get_data()
	if player and global_position.distance_to(player.global_position) <= stats.detection_radius:
		_ai_state = &"chase"
		return
	var left := home_position.x + patrol_left
	var right := home_position.x + patrol_right
	velocity = Vector2(stats.move_speed * float(facing_direction), 0.0)
	move_and_slide()
	if global_position.x <= left:
		facing_direction = 1
	elif global_position.x >= right:
		facing_direction = -1
	update_facing()
	play_animation(&"walk")


func _chase(_delta: float) -> void:
	var player := get_player()
	var stats := get_data()
	if player == null:
		_ai_state = &"patrol"
		return
	var dist := global_position.distance_to(player.global_position)
	if dist > stats.detection_radius * 1.5:
		_ai_state = &"patrol"
		modulate = Color.WHITE
		return
	if dist <= stats.attack_range:
		_begin_phase()
		return
	face_player()
	velocity = (player.global_position - global_position).normalized() * stats.chase_speed
	move_and_slide()
	play_animation(&"walk")


func _begin_phase() -> void:
	_ai_state = &"phase"
	_timer = PHASE_DURATION
	modulate = Color(1, 1, 1, 0.15)
	hurtbox_component.monitorable = false
	velocity = Vector2.ZERO
	_phase_target = _find_nearest_tree_marker()
	if _phase_target != Vector2.ZERO:
		global_position = _phase_target


func _phase(delta: float) -> void:
	velocity = Vector2.ZERO
	var player := get_player()
	if player and global_position.distance_to(player.global_position) <= get_data().attack_range * 1.2:
		_ai_state = &"emerge"
		_timer = EMERGE_DURATION
		modulate = Color(1, 1, 1, 0.6)
		telegraph.visible = true
		telegraph.modulate = Color(0.32, 0.72, 0.53, 0.7)
	elif _timer <= 0.0:
		_ai_state = &"chase"
		modulate = Color.WHITE
		hurtbox_component.monitorable = true


func _emerge(_delta: float) -> void:
	if _timer <= 0.0:
		_ai_state = &"strike"
		_timer = STRIKE_DURATION
		modulate = Color.WHITE
		hurtbox_component.monitorable = true
		telegraph.visible = false
		face_player()
		hitbox_component.damage = get_data().attack_damage
		hitbox_component.damage_type = &"physical"
		hitbox_component.knockback_vector = Vector2(140.0 * float(facing_direction), -60.0)
		hitbox_component.global_position = global_position + Vector2(18.0 * float(facing_direction), 0.0)
		hitbox_component.enable_hitbox()


func _strike(_delta: float) -> void:
	velocity.x = 180.0 * float(facing_direction)
	move_and_slide()
	if _timer <= 0.0:
		hitbox_component.disable_hitbox()
		_begin_phase()


func _find_nearest_tree_marker() -> Vector2:
	var markers := get_tree().get_nodes_in_group(&"tree_phase_markers")
	if markers.is_empty():
		return global_position
	var best: Vector2 = Vector2.ZERO
	var best_dist := INF
	for marker in markers:
		if marker is Node2D:
			var pos := (marker as Node2D).global_position
			var d := global_position.distance_to(pos)
			if d < best_dist:
				best_dist = d
				best = pos
	return best


func _on_custom_damaged(_amount: int, _source: Node) -> void:
	if health_component.current_hp <= 0:
		return
	if _ai_state == &"phase":
		return
	_ai_state = &"hit"
	_timer = 0.3
	modulate = Color.WHITE
	hurtbox_component.monitorable = true
	hitbox_component.disable_hitbox()
	telegraph.visible = false


func _on_custom_died() -> void:
	_ai_state = &"dead"
	modulate = Color.WHITE
	hitbox_component.disable_hitbox()
	finalize_custom_defeat()
