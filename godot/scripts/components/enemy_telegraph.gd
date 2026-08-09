extends Node2D
## Shared intent glow and directional attack marker for normal enemies.


const PULSE_SPEED := 2.5

var _pulse_time: float = 0.0


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()


func _process(delta: float) -> void:
	_pulse_time = fmod(_pulse_time + delta * PULSE_SPEED, TAU)
	queue_redraw()


func _draw() -> void:
	var pulse := (sin(_pulse_time) + 1.0) * 0.5
	var marker_tip := 44.0 + pulse * 3.0
	var marker := PackedVector2Array([
		Vector2(4, 11),
		Vector2(16, 7),
		Vector2(marker_tip - 8.0, 10),
		Vector2(marker_tip, 16),
		Vector2(marker_tip - 8.0, 22),
		Vector2(16, 25),
		Vector2(4, 20),
	])
	draw_colored_polygon(marker, Color(1.0, 1.0, 1.0, 0.12 + pulse * 0.08))
	marker.append(marker[0])
	draw_polyline(marker, Color(1.0, 1.0, 1.0, 0.72 + pulse * 0.2), 2.0)

	var aura_alpha := 0.62 + pulse * 0.26
	draw_arc(Vector2(0, -12), 20.0, -2.35, -0.78, 8, Color(1.0, 1.0, 1.0, aura_alpha), 2.0)
	draw_arc(Vector2(0, -12), 20.0, 0.78, 2.35, 8, Color(1.0, 1.0, 1.0, aura_alpha), 2.0)
	draw_arc(Vector2(0, -12), 15.0 + pulse, -0.55, 0.55, 6, Color(1.0, 1.0, 1.0, 0.36), 1.0)


func _on_visibility_changed() -> void:
	set_process(visible)
	if visible:
		_pulse_time = 0.0
		queue_redraw()
