extends Node2D
## Tile-textured platforms with collision — replaces greybox ColorRects.


@export var platform_rects: Array[Rect2] = []
@export var tileset_path := "res://assets/sprites/tilesets/01_ashen_threshold/tileset.png"
@export var floor_tile_index := 0
@export var platform_tile_index := 1
@export var west_transition: bool = false
@export var east_transition: bool = false

const TILE_SIZE := 64
## Production platform tiles start at their top edge; collision uses rect top (y=0).
const PLATFORM_SURFACE_Y := 0
const PLATFORM_BODY_Y := 16
const PLATFORM_CAP_HEIGHT := TILE_SIZE - PLATFORM_SURFACE_Y
const PLATFORM_BODY_HEIGHT := TILE_SIZE - PLATFORM_BODY_Y

var _tileset: Texture2D


func _ready() -> void:
	_tileset = load(tileset_path) as Texture2D
	if _tileset == null:
		push_error("StyledRoomGeometry: missing tileset %s" % tileset_path)
		return

	if platform_rects.is_empty():
		return

	var floor_rect: Rect2 = platform_rects[0]
	var extras := platform_rects.slice(1)

	add_child(_make_platform(floor_rect, true))

	for rect: Rect2 in extras:
		add_child(_make_platform(rect, false))
func _make_platform(rect: Rect2, is_floor: bool) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.position = rect.position

	var shape_node := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = rect.size
	shape_node.position = rect.size * 0.5
	shape_node.shape = rect_shape
	body.add_child(shape_node)

	var visuals := Node2D.new()
	body.add_child(visuals)

	var tile_index := floor_tile_index if is_floor else platform_tile_index
	_tile_rect(visuals, rect.size, tile_index, is_floor)

	return body


func _tile_rect(parent: Node2D, size: Vector2, tile_index: int, is_floor: bool) -> void:
	if is_floor:
		_tile_floor_rect(parent, size, tile_index)
		return

	_add_platform_cap_strip(parent, size.x, 0.0)

	var body_remaining := maxf(0.0, size.y - float(PLATFORM_CAP_HEIGHT))
	var y_cursor := float(PLATFORM_CAP_HEIGHT)
	while body_remaining > 0.0:
		var slice_h := minf(float(PLATFORM_BODY_HEIGHT), body_remaining)
		_add_platform_body_strip(parent, size.x, y_cursor, slice_h)
		y_cursor += slice_h
		body_remaining -= slice_h


func _tile_floor_rect(parent: Node2D, size: Vector2, tile_index: int) -> void:
	var cols := int(ceil(size.x / float(TILE_SIZE)))
	var rows := int(ceil(size.y / float(TILE_SIZE)))

	for row in rows:
		for col in cols:
			_add_tile_sprite(
				parent,
				_tile_region(tile_index),
				Vector2(col * TILE_SIZE, row * TILE_SIZE)
			)


func _add_platform_cap_strip(parent: Node2D, width: float, y_pos: float) -> void:
	_add_repeated_strip(
		parent,
		_tile_region(platform_tile_index, PLATFORM_SURFACE_Y, PLATFORM_CAP_HEIGHT),
		width,
		y_pos
	)


func _add_platform_body_strip(parent: Node2D, width: float, y_pos: float, height: float) -> void:
	_add_repeated_strip(
		parent,
		_tile_region(platform_tile_index, PLATFORM_BODY_Y, height),
		width,
		y_pos
	)


func _tile_region(tile_index: int, y_offset: float = 0.0, height: float = TILE_SIZE) -> Rect2:
	var atlas_columns := maxi(1, int(_tileset.get_width() / TILE_SIZE))
	var tile_column := tile_index % atlas_columns
	var tile_row := floori(float(tile_index) / float(atlas_columns))
	return Rect2(
		Vector2(tile_column * TILE_SIZE, tile_row * TILE_SIZE + y_offset),
		Vector2(TILE_SIZE, height)
	)


func _add_repeated_strip(parent: Node2D, source_region: Rect2, width: float, y_pos: float) -> void:
	var x_pos := 0.0
	while x_pos < width:
		var slice_width := minf(float(TILE_SIZE), width - x_pos)
		var region := Rect2(source_region.position, Vector2(slice_width, source_region.size.y))
		_add_tile_sprite(parent, region, Vector2(x_pos, y_pos))
		x_pos += slice_width


func _add_tile_sprite(
	parent: Node2D,
	region: Rect2,
	position: Vector2,
	scale: Vector2 = Vector2.ONE
) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = _tileset
	sprite.region_enabled = true
	sprite.region_rect = region
	sprite.centered = false
	sprite.position = position
	sprite.scale = scale
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(sprite)
