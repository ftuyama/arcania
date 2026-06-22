extends ParallaxBackground
class_name RegionBackdrop
## Region parallax layers — scroll factors per art bible §1.

@export var region_id: StringName = &"ashen_threshold"

const REGION_PARALLAX: Dictionary = {
	&"ashen_threshold": {
		"layers": [
			{"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_0_sky.png", "scroll": Vector2(0.1, 0.0)},
			{"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_1_far_ruins.png", "scroll": Vector2(0.25, 0.0)},
			{"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_2_mid_fog.png", "scroll": Vector2(0.45, 0.0)},
			{"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_3_near_occluders.png", "scroll": Vector2(0.7, 0.0)},
		],
	},
	&"dev": {
		"layers": [
			{"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_0_sky.png", "scroll": Vector2(0.1, 0.0)},
			{"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_1_far_ruins.png", "scroll": Vector2(0.25, 0.0)},
			{"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_2_mid_fog.png", "scroll": Vector2(0.45, 0.0)},
			{"path": "res://assets/sprites/tilesets/01_ashen_threshold/parallax_3_near_occluders.png", "scroll": Vector2(0.7, 0.0)},
		],
	},
	&"whisperwood_hollow": {
		"layers": [
			{"path": "res://assets/sprites/tilesets/02_whisperwood_hollow/parallax_0_sky.png", "scroll": Vector2(0.1, 0.0)},
			{"path": "res://assets/sprites/tilesets/02_whisperwood_hollow/parallax_1_far_trees.png", "scroll": Vector2(0.3, 0.0)},
			{"path": "res://assets/sprites/tilesets/02_whisperwood_hollow/parallax_2_mid_canopy.png", "scroll": Vector2(0.55, 0.0)},
			{"path": "res://assets/sprites/tilesets/02_whisperwood_hollow/parallax_3_spore_fog.png", "scroll": Vector2(0.75, 0.0)},
		],
	},
}

const BACKED_REGIONS: Array[StringName] = [
	&"ashen_threshold",
	&"dev",
	&"whisperwood_hollow",
]


static func region_has_backdrop(id: StringName) -> bool:
	return id in BACKED_REGIONS


func _ready() -> void:
	scroll_base_offset = Vector2.ZERO
	_build_layers()


func _build_layers() -> void:
	for child in get_children():
		child.queue_free()

	var config: Dictionary = REGION_PARALLAX.get(region_id, REGION_PARALLAX[&"ashen_threshold"])
	for layer_data: Dictionary in config.get("layers", []):
		var layer := ParallaxLayer.new()
		layer.motion_scale = layer_data.get("scroll", Vector2(0.2, 0.0))
		layer.motion_mirroring = Vector2(960, 0)

		var sprite := Sprite2D.new()
		var tex := load(layer_data["path"]) as Texture2D
		if tex:
			sprite.texture = tex
			sprite.centered = false
			sprite.position = Vector2.ZERO
		layer.add_child(sprite)
		add_child(layer)
