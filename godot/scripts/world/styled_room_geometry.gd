extends Node2D
## Tile-textured platforms with collision — replaces greybox ColorRects.


@export var platform_rects: Array[Rect2] = []
@export var tileset_path := "res://assets/sprites/tilesets/01_ashen_threshold/tileset.png"
@export var floor_tile_index := 0
@export var platform_tile_index := 2
@export var west_transition: bool = false
@export var east_transition: bool = false

const TILE_SIZE := 64
const SOURCE_TILE_SIZE := 128
const SOURCE_COLUMNS := 4
const SOURCE_SCALE := 0.5
const DOOR_GAP := 64.0

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

	if west_transition or east_transition:
		for segment in _split_floor(floor_rect):
			add_child(_make_platform(segment, true))
	else:
		add_child(_make_platform(floor_rect, true))

	for rect: Rect2 in extras:
		add_child(_make_platform(rect, false))


func _split_floor(floor_rect: Rect2) -> Array[Rect2]:
	var segments: Array[Rect2] = []
	var gap := DOOR_GAP
	var left := floor_rect.position.x
	var top := floor_rect.position.y
	var width := floor_rect.size.x
	var height := floor_rect.size.y

	if west_transition and east_transition:
		segments.append(Rect2(left + gap, top, width - gap * 2.0, height))
	elif west_transition:
		segments.append(Rect2(left + gap, top, width - gap, height))
	elif east_transition:
		segments.append(Rect2(left, top, width - gap, height))
	else:
		segments.append(floor_rect)

	return segments


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

	_tile_rect(visuals, rect.size, is_floor)

	return body


func _tile_rect(parent: Node2D, size: Vector2, is_floor: bool) -> void:
	var cols := int(ceil(size.x / float(TILE_SIZE)))
	var rows := int(ceil(size.y / float(TILE_SIZE)))
	for row in rows:
		for col in cols:
			var source_index := _source_index(col, cols, row, is_floor)
			var source_column := source_index % SOURCE_COLUMNS
			var source_row := source_index / SOURCE_COLUMNS
			_add_tile_sprite(parent, Rect2(
				source_column * SOURCE_TILE_SIZE,
				source_row * SOURCE_TILE_SIZE,
				SOURCE_TILE_SIZE,
				SOURCE_TILE_SIZE
			), Vector2(col * TILE_SIZE, row * TILE_SIZE))


func _source_index(column: int, column_count: int, row: int, is_floor: bool) -> int:
	if row > 0 or is_floor:
		return 4 + ((column + row) % 2)
	if column == 0:
		return 0
	if column == column_count - 1:
		return 3
	return 1 + (column % 2)


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
	sprite.scale = scale * SOURCE_SCALE
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	parent.add_child(sprite)
