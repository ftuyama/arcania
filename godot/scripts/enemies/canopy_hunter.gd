extends BaseEnemy
## E-18 — elite canopy predator with leap and double slash.


const LEAP_TELEGRAPH := 0.7
const LEAP_DURATION := 0.28
const SLASH_COUNT := 2

var _ai_state: StringName = &"patrol"
var _timer: float = 0.0
var _slash_index: int = 0
var _leap_target: Vector2 = Vector2.ZERO
var _leap_start: Vector2 = Vector2.ZERO
var _leap_progress: float = 0.0
var _summoned_pods: bool = false
var _slash_active: bool = false


func _ready() -> void:
	super._ready()
	state_machine.set_physics_process(false)
	health_component.damaged.disconnect(_on_damaged)
	health_component.damaged.connect(_on_custom_damaged)
	health_component.died.disconnect(_on_died)
	health_component.died.connect(_on_custom_died)
	animated_sprite.modulate = Color(0.28, 0.62, 0.38, 1.0)
	animated_sprite.scale = Vector2(1.2, 1.2)


func _physics_process(delta: float) -> void:
	if _ai_state == &"dead":
		return
	_timer -= delta
	if _ai_state == &"hit":
		if _timer <= 0.0:
			_ai_state = &"patrol"
		return
	if not _summoned_pods and health_component.current_hp <= health_component.max_hp / 2:
		_summon_pods()
	match _ai_state:
		&"patrol":
			_patrol(delta)
		&"chase":
			_chase(delta)
		&"leap":
			_leap(delta)
		&"slash":
			_slash(delta)


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
		return
	if dist <= stats.attack_range:
		_ai_state = &"leap"
		_timer = LEAP_TELEGRAPH
		_leap_target = player.global_position
		_leap_progress = 0.0
		telegraph.visible = true
		telegraph.modulate = Color(0.9, 0.35, 0.25, 0.85)
		return
	face_player()
	velocity = (player.global_position - global_position).normalized() * stats.chase_speed
	move_and_slide()
	play_animation(&"walk")


func _leap(delta: float) -> void:
	velocity = Vector2.ZERO
	if _timer > 0.0:
		return
	if _leap_progress <= 0.0:
		telegraph.visible = false
		_leap_start = global_position
		var player := get_player()
		if player:
			_leap_target = player.global_position
	_leap_progress += delta / LEAP_DURATION
	global_position = _leap_start.lerp(_leap_target + Vector2(0, -8), _leap_progress)
	if _leap_progress >= 1.0:
		_ai_state = &"slash"
		_slash_index = 0
		_slash_active = false
		_timer = 0.1
		_leap_progress = 0.0


func _slash(_delta: float) -> void:
	velocity = Vector2.ZERO
	if _timer > 0.0:
		return
	if not _slash_active:
		face_player()
		hitbox_component.damage = get_data().attack_damage
		hitbox_component.damage_type = &"physical"
		hitbox_component.knockback_vector = Vector2(180.0 * float(facing_direction), -90.0)
		hitbox_component.global_position = global_position + Vector2(22.0 * float(facing_direction), 0.0)
		hitbox_component.enable_hitbox()
		_slash_active = true
		_timer = 0.14
		return
	hitbox_component.disable_hitbox()
	_slash_active = false
	_slash_index += 1
	if _slash_index >= SLASH_COUNT:
		_ai_state = &"chase"
		_timer = 0.5
	else:
		_timer = 0.18


func _summon_pods() -> void:
	_summoned_pods = true
	var larva_scene := preload("res://scenes/enemies/thornweft_larva.tscn")
	for offset in [-64.0, 64.0]:
		var larva := larva_scene.instantiate()
		get_parent().add_child(larva)
		larva.global_position = global_position + Vector2(offset, 0)


func _on_custom_damaged(_amount: int, _source: Node) -> void:
	if health_component.current_hp <= 0:
		return
	_ai_state = &"hit"
	_timer = 0.35
	hitbox_component.disable_hitbox()
	telegraph.visible = false


func _on_custom_died() -> void:
	_ai_state = &"dead"
	hitbox_component.disable_hitbox()
	finalize_custom_defeat()
