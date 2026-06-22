extends State
## 3-hit melee combo with active hitbox windows.


enum Phase { WINDUP, ACTIVE, RECOVERY }

var _phase: Phase = Phase.WINDUP
var _timer: float = 0.0
var _step: Dictionary = {}
var _queued_next: bool = false


func enter(_payload: Dictionary) -> void:
	var player := _get_player()
	if player.combo_reset_timer <= 0.0:
		player.combo_index = 0
	_step = Player.COMBO_STEPS[player.combo_index]
	_phase = Phase.WINDUP
	_timer = float(_step["windup"])
	_queued_next = false
	player.velocity.x = 0.0
	var input_axis := player.get_move_input()
	if input_axis != 0.0:
		player.facing_direction = 1 if input_axis > 0.0 else -1
		player.animated_sprite.flip_h = player.facing_direction < 0
	var anim_names: Array[StringName] = [&"melee_1", &"melee_2", &"melee_3"]
	player.play_animation(anim_names[player.combo_index], true)
	player.play_melee_windup_sfx(player.combo_index)


func exit() -> void:
	var player := _get_player()
	player.melee_hitbox.disable_hitbox()


func physics_update(delta: float) -> void:
	var player := _get_player()
	_timer -= delta

	if player.is_attack_pressed():
		_queued_next = true

	if _phase == Phase.WINDUP and _timer <= 0.0:
		_phase = Phase.ACTIVE
		_timer = float(_step["active"])
		player.play_melee_swing(player.combo_index)
		_enable_hitbox(player)
	elif _phase == Phase.ACTIVE and _timer <= 0.0:
		_phase = Phase.RECOVERY
		_timer = float(_step["recovery"])
		player.melee_hitbox.disable_hitbox()
	elif _phase == Phase.RECOVERY and _timer <= 0.0:
		_advance_combo(player)
		return

	player.apply_gravity(delta)
	player.move_and_slide()

	if not player.is_on_floor():
		state_machine.transition_to(&"Fall", {})


func _advance_combo(player: Player) -> void:
	player.combo_reset_timer = Player.COMBO_RESET_TIME
	if _queued_next and player.combo_index < Player.COMBO_STEPS.size() - 1:
		player.combo_index += 1
		enter({})
		return
	player.combo_index = 0
	if player.is_on_floor():
		state_machine.transition_to(&"Idle", {})
	else:
		state_machine.transition_to(&"Fall", {})


func _enable_hitbox(player: Player) -> void:
	player.melee_hitbox.configure_melee(player.facing_direction, Vector2(6.0, -6.0))
	player.melee_hitbox.damage = int(_step["damage"])
	player.melee_hitbox.damage_type = &"physical"
	player.melee_hitbox.knockback_vector = _step["knockback"] as Vector2
	player.melee_hitbox.enable_hitbox()


func _get_player() -> Player:
	return state_machine.get_parent() as Player
