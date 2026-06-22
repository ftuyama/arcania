extends Node2D
## Tile-textured platforms with collision — replaces greybox ColorRects.


@export var platform_rects: Array[Rect2] = []
@export var tileset_path := "res://assets/sprites/tilesets/01_ashen_threshold/tileset.png"
@export var floor_tile_index := 0
@export var platform_tile_index := 2
@export var west_transition: bool = false
@export var east_transition: bool = false

const TILE_SIZE := 64
const DOOR_GAP := 64.0
## Platform tile art draws the walkable cap at y=16; collision uses rect top (y=0).
const PLATFORM_SURFACE_Y := 16
const PLATFORM_BODY_Y := 20
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
	var region_x := tile_index * TILE_SIZE

	for row in rows:
		for col in cols:
			_add_tile_sprite(
				parent,
				Rect2(region_x, 0, TILE_SIZE, TILE_SIZE),
				Vector2(col * TILE_SIZE, row * TILE_SIZE)
			)


func _add_platform_cap_strip(parent: Node2D, width: float, y_pos: float) -> void:
	_add_tile_sprite(
		parent,
		Rect2(
			platform_tile_index * TILE_SIZE,
			PLATFORM_SURFACE_Y,
			TILE_SIZE,
			PLATFORM_CAP_HEIGHT
		),
		Vector2(0.0, y_pos),
		Vector2(width / float(TILE_SIZE), 1.0)
	)


func _add_platform_body_strip(parent: Node2D, width: float, y_pos: float, height: float) -> void:
	var scale_y := height / float(PLATFORM_BODY_HEIGHT)
	_add_tile_sprite(
		parent,
		Rect2(
			platform_tile_index * TILE_SIZE,
			PLATFORM_BODY_Y,
			TILE_SIZE,
			PLATFORM_BODY_HEIGHT
		),
		Vector2(0.0, y_pos),
		Vector2(width / float(TILE_SIZE), scale_y)
	)


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
