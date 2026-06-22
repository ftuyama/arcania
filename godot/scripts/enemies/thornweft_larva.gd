extends BaseEnemy
## E-15 — anchors and spits silk projectiles at range.


const PROJECTILE_SCENE := preload("res://scenes/enemies/enemy_projectile.tscn")
const SPIT_COOLDOWN := 1.4

var _ai_state: StringName = &"patrol"
var _timer: float = 0.0
var _spit_ready: bool = true


func _ready() -> void:
	super._ready()
	state_machine.set_physics_process(false)
	health_component.damaged.disconnect(_on_damaged)
	health_component.damaged.connect(_on_custom_damaged)
	health_component.died.disconnect(_on_died)
	health_component.died.connect(_on_custom_died)
	animated_sprite.modulate = Color(0.35, 0.72, 0.55, 1.0)


func _physics_process(delta: float) -> void:
	if _ai_state == &"dead":
		return
	_timer -= delta
	if not _spit_ready and _timer <= 0.0:
		_spit_ready = true
	if _ai_state == &"hit":
		if _timer <= 0.0:
			_ai_state = &"patrol"
		return
	match _ai_state:
		&"patrol":
			_patrol(delta)
		&"chase":
			_chase(delta)
		&"spit":
			_spit(delta)


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
	face_player()
	if dist <= stats.attack_range and _spit_ready:
		_ai_state = &"spit"
		_timer = 0.5
		velocity = Vector2.ZERO
		telegraph.visible = true
		telegraph.modulate = Color(0.32, 0.72, 0.53, 0.75)
		return
	if dist > stats.attack_range * 0.7:
		velocity = (player.global_position - global_position).normalized() * stats.chase_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	play_animation(&"walk")


func _spit(_delta: float) -> void:
	velocity = Vector2.ZERO
	if _timer <= 0.0 and _spit_ready:
		_fire_spit()
		_spit_ready = false
		_timer = SPIT_COOLDOWN
		telegraph.visible = false
		_ai_state = &"chase"


func _fire_spit() -> void:
	var player := get_player()
	if player == null:
		return
	var projectile := PROJECTILE_SCENE.instantiate()
	get_parent().add_child(projectile)
	var aim := player.global_position - global_position + Vector2(0, -8)
	projectile.launch(global_position + Vector2(0, -12), aim, get_data().attack_damage, &"physical")
	projectile.knockback = Vector2(80.0 * signf(aim.x), -20.0)


func _on_custom_damaged(_amount: int, _source: Node) -> void:
	if health_component.current_hp <= 0:
		return
	_ai_state = &"hit"
	_timer = 0.25
	telegraph.visible = false


func _on_custom_died() -> void:
	_ai_state = &"dead"
	finalize_custom_defeat()
