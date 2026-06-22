extends Node
## Camera shake child of Camera2D.


var _offset: Vector2 = Vector2.ZERO
var _camera: Camera2D


func _ready() -> void:
	_camera = get_parent() as Camera2D


func _process(_delta: float) -> void:
	if _camera:
		_camera.offset = _offset


func shake(intensity: float, duration: float) -> void:
	if _camera == null:
		return
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	var steps := maxi(int(duration / 0.03), 1)
	for i in steps:
		var strength := intensity * (1.0 - float(i) / float(steps))
		tween.tween_property(self, "_offset", Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		), duration / float(steps))
	tween.tween_property(self, "_offset", Vector2.ZERO, 0.04)
