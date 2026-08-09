extends Node2D
## Layered arc slash shown during melee active frames.


@onready var _slash: Line2D = $Slash
@onready var _afterimage: Line2D = $Afterimage
@onready var _sparks: CPUParticles2D = $Sparks

const SWING_COLORS: Array[Color] = [
	Color(0.95, 0.85, 0.55, 0.95),
	Color(0.92, 0.72, 0.42, 0.95),
	Color(1.0, 0.58, 0.28, 1.0),
]

const SWING_ROTATIONS: Array[float] = [-0.34, 0.30, -0.42]


func play_swing(facing: int, combo_index: int) -> void:
	var step := mini(combo_index, SWING_COLORS.size() - 1)
	var facing_scale := float(facing)
	var swing_rotation := SWING_ROTATIONS[step] * facing_scale
	var is_finisher := step == SWING_COLORS.size() - 1
	scale = Vector2(0.68 * facing_scale, 0.68)
	rotation = swing_rotation - 0.24 * facing_scale
	_slash.default_color = SWING_COLORS[step]
	_slash.modulate = Color.WHITE
	_afterimage.default_color = SWING_COLORS[step].darkened(0.25)
	_afterimage.modulate = Color(1.0, 1.0, 1.0, 0.0)
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
	tween.tween_property(self, "scale", Vector2(1.14 * facing_scale, 1.14), 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(_afterimage, "modulate:a", 0.72 if is_finisher else 0.48, 0.035)
	tween.tween_property(_slash, "modulate:a", 0.0, 0.14 if is_finisher else 0.11).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(_afterimage, "modulate:a", 0.0, 0.13 if is_finisher else 0.10).set_delay(0.035).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func() -> void:
		visible = false
		_slash.modulate = Color.WHITE
		_afterimage.modulate = Color.WHITE
	)
