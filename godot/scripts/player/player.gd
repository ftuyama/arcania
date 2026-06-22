class_name Player
extends CharacterBody2D
## Elara — movement, melee combo, and spell casting.

const MOVE_SPEED := 180.0
const JUMP_VELOCITY := -450.0
const GRAVITY := 980.0
const MAX_FALL_SPEED := 500.0
const DASH_SPEED := 400.0
const DASH_DURATION := 0.2
const COMBO_RESET_TIME := 0.55
const FOOTSTEP_INTERVAL := 0.32
const HURT_SFX := "res://assets/audio/sfx/player/sfx_player_hurt_1.wav"

const COMBO_STEPS: Array[Dictionary] = [
	{"windup": 0.08, "active": 0.10, "recovery": 0.12, "damage": 8, "knockback": Vector2(120, -40)},
	{"windup": 0.06, "active": 0.08, "recovery": 0.10, "damage": 8, "knockback": Vector2(120, -40)},
	{"windup": 0.12, "active": 0.14, "recovery": 0.20, "damage": 14, "knockback": Vector2(180, -80)},
]

@onready var state_machine: StateMachine = $StateMachine
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var health_component: HealthComponent = $HealthComponent
@onready var mana_component: ManaComponent = $ManaComponent
@onready var spell_caster: Node = $SpellCaster
@onready var melee_hitbox: HitboxComponent = $MeleeHitbox
@onready var hurtbox: HurtboxComponent = $HurtboxComponent
@onready var hit_flash: Node = $HitFlash
@onready var melee_swing_vfx: Node2D = $MeleeSwingVFX

var facing_direction: int = 1
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var is_invulnerable: bool = false
var is_phasing: bool = false
var dash_unlocked: bool = false
var combo_index: int = 0
var combo_reset_timer: float = 0.0
var essence_collected: int = 0
var respawn_position: Vector2 = Vector2.ZERO

var _coyote_frames: int = 6
var _jump_buffer_frames: int = 8
var _dash_iframes: int = 14
var _footstep_timer: float = 0.0
var _current_anim: StringName = &""
var _was_on_floor: bool = true


func _ready() -> void:
	add_to_group(&"player")
	_coyote_frames = int(ProjectSettings.get_setting("gameplay/coyote_frames", 6))
	_jump_buffer_frames = int(ProjectSettings.get_setting("gameplay/jump_buffer_frames", 8))
	_dash_iframes = int(ProjectSettings.get_setting("gameplay/dash_iframes", 14))
	camera.enabled = true
	dash_unlocked = SpellManager.has_spell(&"veil_step")
	respawn_position = global_position
	health_component.damaged.connect(_on_damaged)
	health_component.died.connect(_on_died)
	hit_flash.setup(animated_sprite)
	melee_hitbox.hit_landed.connect(_on_melee_hit_landed)
	play_animation(&"idle")
	EventBus.player_spawned.emit(self)
	EventBus.enemy_defeated.connect(_on_enemy_defeated)
	EventBus.spell_acquired.connect(_on_spell_acquired)


func _exit_tree() -> void:
	if EventBus.spell_acquired.is_connected(_on_spell_acquired):
		EventBus.spell_acquired.disconnect(_on_spell_acquired)
	if EventBus.enemy_defeated.is_connected(_on_enemy_defeated):
		EventBus.enemy_defeated.disconnect(_on_enemy_defeated)
	if melee_hitbox.hit_landed.is_connected(_on_melee_hit_landed):
		melee_hitbox.hit_landed.disconnect(_on_melee_hit_landed)


func _physics_process(delta: float) -> void:
	_update_timers(delta)
	_update_landing_audio()
	_check_locked_spell_feedback()
	if combo_reset_timer > 0.0:
		combo_reset_timer = maxf(combo_reset_timer - delta, 0.0)
		if combo_reset_timer == 0.0:
			combo_index = 0
	_apply_pixel_snap()
	_was_on_floor = is_on_floor()


func get_move_input() -> float:
	return Input.get_axis(&"move_left", &"move_right")


func get_aim_direction() -> Vector2:
	var aim := Vector2(
		Input.get_axis(&"aim_left", &"aim_right"),
		Input.get_axis(&"aim_up", &"aim_down")
	)
	if aim.length_squared() < 0.01:
		aim = Vector2(float(facing_direction), 0.0)
	return aim.normalized()


func is_jump_pressed() -> bool:
	return Input.is_action_just_pressed(&"jump")


func is_dash_pressed() -> bool:
	return dash_unlocked and Input.is_action_just_pressed(&"dash")


func is_attack_pressed() -> bool:
	return Input.is_action_just_pressed(&"melee_attack")


func get_spell_input() -> StringName:
	if Input.is_action_just_pressed(&"quick_spell_1"):
		return SpellManager.get_quick_slot(0)
	if Input.is_action_just_pressed(&"quick_spell_2"):
		return SpellManager.get_quick_slot(1)
	if Input.is_action_just_pressed(&"quick_spell_3"):
		return SpellManager.get_quick_slot(2)
	if Input.is_action_just_pressed(&"quick_spell_4"):
		return SpellManager.get_quick_slot(3)
	if Input.is_action_just_pressed(&"cast_spell"):
		var primary := SpellManager.get_quick_slot(0)
		return primary if not primary.is_empty() else &"ember_sigil"
	return &""


func can_coyote_jump() -> bool:
	return coyote_timer > 0.0 and not is_on_floor()


func can_buffer_jump() -> bool:
	return jump_buffer_timer > 0.0


func consume_jump_buffer() -> void:
	jump_buffer_timer = 0.0
	coyote_timer = 0.0


func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)


func apply_horizontal_movement(input_axis: float) -> void:
	velocity.x = input_axis * MOVE_SPEED
	if input_axis != 0.0:
		facing_direction = 1 if input_axis > 0.0 else -1
	_update_facing()


func set_invulnerable(value: bool) -> void:
	is_invulnerable = value
	health_component.is_invulnerable = value


func set_phasing(value: bool) -> void:
	is_phasing = value


func set_respawn_position(position: Vector2) -> void:
	respawn_position = position


func respawn() -> void:
	health_component.current_hp = health_component.max_hp
	mana_component.restore_full()
	global_position = respawn_position
	velocity = Vector2.ZERO
	combo_index = 0
	animated_sprite.modulate = Color.WHITE
	set_invulnerable(false)
	state_machine.transition_to(&"Idle", {})


func add_essence(amount: int) -> void:
	essence_collected += amount


func play_animation(anim_name: StringName, force: bool = false) -> void:
	if animated_sprite == null:
		return
	if not force and _current_anim == anim_name:
		return
	if not animated_sprite.sprite_frames or not animated_sprite.sprite_frames.has_animation(anim_name):
		return
	_current_anim = anim_name
	animated_sprite.play(anim_name)
	if force:
		animated_sprite.frame = 0


func play_footstep(surface: StringName = &"ash") -> void:
	AudioManager.play_footstep(surface, global_position)


func play_jump_sfx() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/player/sfx_jump.wav", global_position)


func play_land_sfx() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/player/sfx_land.wav", global_position)


func play_dash_sfx() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/player/sfx_dash.wav", global_position)


func play_melee_windup_sfx(combo_index: int) -> void:
	var path := "res://assets/audio/sfx/player/sfx_melee_swipe_%d.wav" % (combo_index + 1)
	AudioManager.play_sfx(path, global_position)


func play_melee_swing(combo_index: int) -> void:
	if melee_swing_vfx and melee_swing_vfx.has_method(&"play_swing"):
		melee_swing_vfx.play_swing(facing_direction, combo_index)
	var tween := create_tween()
	var punch := 1.08 if combo_index < 2 else 1.12
	animated_sprite.scale = Vector2(punch, punch)
	tween.tween_property(animated_sprite, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_QUAD)


func play_melee_hit_sfx() -> void:
	AudioManager.play_sfx("res://assets/audio/sfx/player/sfx_melee_hit.wav", global_position)


func play_hurt_sfx() -> void:
	AudioManager.play_sfx(HURT_SFX, global_position)


func tick_footsteps(delta: float, moving: bool) -> void:
	if not moving or not is_on_floor():
		_footstep_timer = 0.0
		return
	_footstep_timer -= delta
	if _footstep_timer <= 0.0:
		play_footstep(&"ash")
		_footstep_timer = FOOTSTEP_INTERVAL


func _on_damaged(amount: int, source: Node) -> void:
	hit_flash.flash()
	play_hurt_sfx()
	_spawn_hurt_impact(source)
	CombatJuice.on_player_hurt()
	EventBus.player_damaged.emit(amount, source)
	if health_component.current_hp <= 0 or is_invulnerable:
		return
	var current := state_machine.current_state
	if current and current.name != &"Hit" and current.name != &"Dead":
		state_machine.transition_to(&"Hit", {"source": source})


func _on_died() -> void:
	EventBus.player_died.emit()
	state_machine.transition_to(&"Dead", {})


func _on_enemy_defeated(_enemy_id: StringName, _position: Vector2) -> void:
	pass


func _on_spell_acquired(spell_id: StringName) -> void:
	if spell_id == &"veil_step":
		dash_unlocked = true


func _on_melee_hit_landed(_target: Node, _damage: int) -> void:
	play_melee_hit_sfx()
	CombatJuice.request_hit_stop(2)


func get_dash_iframe_duration() -> float:
	return float(_dash_iframes) / 60.0


func _update_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = float(_coyote_frames) / 60.0
	else:
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed(&"jump"):
		jump_buffer_timer = float(_jump_buffer_frames) / 60.0
	else:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)


func _update_landing_audio() -> void:
	if is_on_floor() and not _was_on_floor and velocity.y > 80.0:
		play_land_sfx()


func _update_facing() -> void:
	animated_sprite.flip_h = facing_direction < 0


func _apply_pixel_snap() -> void:
	global_position = global_position.round()


func _check_locked_spell_feedback() -> void:
	if Input.is_action_just_pressed(&"dash") and not dash_unlocked:
		EventBus.ui_toast.emit("Veil Step not learned — find the shrine on the East Road")
		return
	if not Input.is_action_just_pressed(&"quick_spell_4"):
		return
	if SpellManager.has_spell(&"rootbind") or SpellManager.has_spell(&"rune_anchor"):
		return
	EventBus.ui_toast.emit("Rootbind not acquired — explore Whisperwood")


func _spawn_hurt_impact(source: Node) -> void:
	var world := get_parent()
	if world == null:
		return
	var impact_pos := global_position + Vector2(0, -12)
	var away_dir := Vector2(-float(facing_direction), -0.15)
	if source is Node2D:
		var src_pos := (source as Node2D).global_position
		impact_pos = impact_pos.lerp(src_pos, 0.4)
		away_dir = (global_position - src_pos).normalized()
	HurtImpactVFX.spawn(world, impact_pos, away_dir)
