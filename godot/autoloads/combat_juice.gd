extends Node
## Hit-stop, screen shake, and combat feedback orchestration.


const DEFAULT_HIT_STOP_FRAMES := 3
const DEFAULT_SHAKE_INTENSITY := 4.0
const DEFAULT_SHAKE_DURATION := 0.12

var _hit_stop_active: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.enemy_defeated.connect(_on_enemy_defeated)


func _exit_tree() -> void:
	if EventBus.enemy_defeated.is_connected(_on_enemy_defeated):
		EventBus.enemy_defeated.disconnect(_on_enemy_defeated)


func request_hit_stop(frames: int = DEFAULT_HIT_STOP_FRAMES) -> void:
	if _hit_stop_active or frames <= 0:
		return
	_hit_stop_active = true
	var previous_scale := Engine.time_scale
	Engine.time_scale = 0.05
	await get_tree().create_timer(float(frames) / 60.0 / 0.05, true, false, true).timeout
	Engine.time_scale = previous_scale
	_hit_stop_active = false


func request_screen_shake(intensity: float = DEFAULT_SHAKE_INTENSITY, duration: float = DEFAULT_SHAKE_DURATION) -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Player
	if player == null or player.camera == null:
		return
	var shaker := player.camera.get_node_or_null("CameraShake")
	if shaker and shaker.has_method(&"shake"):
		shaker.shake(intensity, duration)


func play_telegraph_sfx(tier: int = 2) -> void:
	var path := "res://assets/audio/sfx/ui/ui_menu_select.wav"
	if tier >= 3:
		path = "res://assets/audio/sfx/spells/sfx_ember_cast.wav"
	AudioManager.play_sfx(path)


func on_heavy_hit() -> void:
	request_hit_stop(2)
	request_screen_shake(3.0, 0.08)


func on_player_hurt() -> void:
	request_screen_shake(2.5, 0.1)


func on_boss_telegraph(tier: int = 2) -> void:
	play_telegraph_sfx(tier)


func _on_enemy_defeated(_enemy_id: StringName, _position: Vector2) -> void:
	request_screen_shake(5.0, 0.15)
