extends Node2D
## Brief arc slash shown during melee active frames.


@onready var _slash: Line2D = $Slash

const SWING_COLORS: Array[Color] = [
	Color(0.95, 0.85, 0.55, 0.95),
	Color(0.92, 0.72, 0.42, 0.95),
	Color(1.0, 0.58, 0.28, 1.0),
]


func play_swing(facing: int, combo_index: int) -> void:
	scale.x = absf(scale.x) * float(facing)
	_slash.default_color = SWING_COLORS[mini(combo_index, SWING_COLORS.size() - 1)]
	_slash.modulate = Color.WHITE
	visible = true
	var tween := create_tween()
	tween.tween_property(_slash, "modulate:a", 0.0, 0.12).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func() -> void:
		visible = false
		_slash.modulate = Color.WHITE
	)
