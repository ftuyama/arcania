extends Control
## Layered title atmosphere — slow parallax drift over Ashen Threshold art.


const LAYERS: Array[Dictionary] = [
	{
		"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_0_sky.png",
		"drift": Vector2(0.0, 0.0),
		"modulate": Color(1.0, 1.0, 1.0, 1.0),
	},
	{
		"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_1_far_ruins.png",
		"drift": Vector2(6.0, 0.0),
		"modulate": Color(0.95, 0.92, 0.88, 1.0),
	},
	{
		"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_2_mid_fog.png",
		"drift": Vector2(-4.0, 0.0),
		"modulate": Color(0.9, 0.9, 0.95, 0.85),
	},
	{
		"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_3_near_occluders.png",
		"drift": Vector2(10.0, 0.0),
		"modulate": Color(0.82, 0.8, 0.78, 0.75),
	},
]

const VIGNETTE_PATH := "res://assets/sprites/ui/vignette_overlay.png"
const EMBER_GLOW_COLOR := Color(0.55, 0.28, 0.12, 0.22)

var _layer_nodes: Array[TextureRect] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_layers()
	_start_drift()
	_start_ember_pulse()


func _build_layers() -> void:
	for layer_data: Dictionary in LAYERS:
		var rect := TextureRect.new()
		rect.name = layer_data["path"].get_file().get_basename()
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		rect.texture = load(layer_data["path"]) as Texture2D
		rect.modulate = layer_data.get("modulate", Color.WHITE)
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(rect)
		_layer_nodes.append(rect)

	var vignette := TextureRect.new()
	vignette.name = "Vignette"
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	vignette.stretch_mode = TextureRect.STRETCH_SCALE
	vignette.texture = load(VIGNETTE_PATH) as Texture2D
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vignette)

	var ember_glow := ColorRect.new()
	ember_glow.name = "EmberGlow"
	ember_glow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ember_glow.color = EMBER_GLOW_COLOR
	ember_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(ember_glow)
	ember_glow.set_meta(&"pulse_target", ember_glow)


func _start_drift() -> void:
	for i in _layer_nodes.size():
		var rect := _layer_nodes[i]
		var drift: Vector2 = LAYERS[i].get("drift", Vector2.ZERO)
		if drift == Vector2.ZERO:
			continue
		var start_offset := rect.position
		var tween := create_tween().set_loops()
		tween.tween_property(rect, "position", start_offset + drift, 18.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(rect, "position", start_offset - drift, 18.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _start_ember_pulse() -> void:
	var ember_glow := get_node_or_null("EmberGlow") as ColorRect
	if ember_glow == null:
		return
	var base_alpha := EMBER_GLOW_COLOR.a
	var tween := create_tween().set_loops()
	tween.tween_property(ember_glow, "color:a", base_alpha * 0.55, 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(ember_glow, "color:a", base_alpha, 2.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
