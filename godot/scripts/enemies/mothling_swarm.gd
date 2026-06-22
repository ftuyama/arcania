extends BaseEnemy
## E-07 — hovering swarm with engulf AoE when close to the player.


const ENGULF_RANGE := 72.0
const HOVER_HEIGHT := -32.0

@export var orbit_mode: bool = false
@export var orbit_radius: float = 56.0
@export var orbit_speed: float = 1.4
@export var orbit_angle_start: float = 0.0

var _ai_state: StringName = &"patrol"
var _timer: float = 0.0
var _engulfing: bool = false
var _orbit_angle: float = 0.0


func _ready() -> void:
	super._ready()
	_orbit_angle = orbit_angle_start
	state_machine.set_physics_process(false)
	health_component.damaged.disconnect(_on_damaged)
	health_component.damaged.connect(_on_custom_damaged)
	health_component.died.disconnect(_on_died)
	health_component.died.connect(_on_custom_died)
	animated_sprite.modulate = Color(0.85, 0.95, 0.78, 0.9)


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
		&"engulf":
			_engulf(delta)


func _patrol(delta: float) -> void:
	var player := get_player()
	var stats := get_data()
	if player and global_position.distance_to(player.global_position) <= stats.detection_radius:
		_ai_state = &"chase"
		return
	if orbit_mode:
		_orbit_patrol(delta)
		return
	var left := home_position.x + patrol_left
	var right := home_position.x + patrol_right
	velocity = Vector2(stats.move_speed * float(facing_direction), 0.0)
	global_position.y = home_position.y + HOVER_HEIGHT
	move_and_slide()
	if global_position.x <= left:
		facing_direction = 1
	elif global_position.x >= right:
		facing_direction = -1
	update_facing()
	play_animation(&"walk")


func _orbit_patrol(delta: float) -> void:
	_orbit_angle += orbit_speed * delta
	var center := home_position + Vector2(0, HOVER_HEIGHT)
	global_position = center + Vector2(cos(_orbit_angle), sin(_orbit_angle)) * orbit_radius
	facing_direction = 1 if cos(_orbit_angle + PI * 0.5) >= 0.0 else -1
	update_facing()
	play_animation(&"walk")


func _chase(delta: float) -> void:
	var player := get_player()
	var stats := get_data()
	if player == null:
		_ai_state = &"patrol"
		return
	var to_player := player.global_position - global_position
	var dist := to_player.length()
	if dist > stats.detection_radius * 1.5:
		_ai_state = &"patrol"
		return
	if dist <= ENGULF_RANGE:
		_ai_state = &"engulf"
		_timer = 1.2
		_engulfing = true
		telegraph.visible = true
		telegraph.modulate = Color(0.85, 0.95, 0.6, 0.55)
		return
	face_player()
	velocity = to_player.normalized() * stats.chase_speed
	velocity.y = (player.global_position.y + HOVER_HEIGHT - global_position.y) * 4.0
	move_and_slide()
	play_animation(&"walk")


func _engulf(delta: float) -> void:
	var player := get_player()
	if player == null:
		_ai_state = &"patrol"
		telegraph.visible = false
		return
	velocity = Vector2.ZERO
	face_player()
	if _engulfing and global_position.distance_to(player.global_position) <= ENGULF_RANGE:
		hitbox_component.damage = get_data().attack_damage
		hitbox_component.damage_type = &"physical"
		hitbox_component.knockback_vector = Vector2.ZERO
		hitbox_component.global_position = global_position
		hitbox_component.enable_hitbox()
	else:
		hitbox_component.disable_hitbox()
	if _timer <= 0.0:
		hitbox_component.disable_hitbox()
		telegraph.visible = false
		_engulfing = false
		_ai_state = &"chase"


func _on_custom_damaged(_amount: int, source: Node) -> void:
	if health_component.current_hp <= 0:
		return
	if source and source is HitboxComponent:
		var hb := source as HitboxComponent
		if hb.damage_type == &"fire":
			_scatter()
			return
	_ai_state = &"hit"
	_timer = 0.25
	velocity = Vector2.ZERO
	hitbox_component.disable_hitbox()
	telegraph.visible = false


func _scatter() -> void:
	_ai_state = &"hit"
	_timer = 0.6
	velocity = Vector2(randf_range(-120.0, 120.0), -80.0)


func _on_custom_died() -> void:
	_ai_state = &"dead"
	hitbox_component.disable_hitbox()
	telegraph.visible = false
	finalize_custom_defeat()
