extends Node2D
## Layered arc slash shown during melee active frames.


@onready var _slash_sprite: Sprite2D = $SlashSprite
@onready var _sparks: CPUParticles2D = $Sparks

const SWING_COLORS: Array[Color] = [
	Color(0.95, 0.85, 0.55, 0.95),
	Color(0.92, 0.72, 0.42, 0.95),
	Color(1.0, 0.58, 0.28, 1.0),
]

const SWING_ROTATIONS: Array[float] = [-0.34, 0.30, -0.42]
const SLASH_FRAME_COUNT := 4.0


func play_swing(facing: int, combo_index: int) -> void:
	var step := mini(combo_index, SWING_COLORS.size() - 1)
	var facing_scale := float(facing)
	var swing_rotation := SWING_ROTATIONS[step] * facing_scale
	var is_finisher := step == SWING_COLORS.size() - 1
	var slash_duration := 0.22 if is_finisher else 0.18
	scale = Vector2(0.55 * facing_scale, 0.55)
	rotation = swing_rotation - 0.24 * facing_scale
	_slash_sprite.flip_h = facing < 0
	_slash_sprite.frame = 0
	_slash_sprite.modulate = Color.WHITE
	_sparks.amount = 14 if is_finisher else 8
	_sparks.initial_velocity_min = 105.0 if is_finisher else 72.0
	_sparks.initial_velocity_max = 175.0 if is_finisher else 120.0
	_sparks.color = SWING_COLORS[step]
	visible = true
	_sparks.restart()
	_sparks.emitting = true
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "rotation", swing_rotation + 0.18 * facing_scale, 0.11).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(0.82 * facing_scale, 0.82), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_method(_set_slash_frame, 0.0, SLASH_FRAME_COUNT, slash_duration)
	tween.tween_property(_slash_sprite, "modulate:a", 0.0, slash_duration).set_trans(Tween.TRANS_QUAD)
	tween.chain().tween_callback(func() -> void:
		visible = false
		_slash_sprite.modulate = Color.WHITE
	)


func _set_slash_frame(value: float) -> void:
	_slash_sprite.frame = clampi(floori(value), 0, int(SLASH_FRAME_COUNT) - 1)
