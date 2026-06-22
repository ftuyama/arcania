extends Node
## Applies brief hit-flash feedback to a CanvasItem target.


@export var flash_duration: float = 0.12

var _target: CanvasItem
var _material: ShaderMaterial
var _flash_timer: float = 0.0


func setup(target: CanvasItem) -> void:
	_target = target
	_material = ShaderMaterial.new()
	_material.shader = load("res://assets/shaders/hit_flash.gdshader")
	_target.material = _material


func flash() -> void:
	if _material == null:
		return
	_flash_timer = flash_duration
	_material.set_shader_parameter(&"flash", 1.0)


func _process(delta: float) -> void:
	if _flash_timer <= 0.0:
		return
	_flash_timer = maxf(_flash_timer - delta, 0.0)
	var t := _flash_timer / flash_duration
	_material.set_shader_parameter(&"flash", t)
