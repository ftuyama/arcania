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
	if not is_floor and size.y <= 24.0:
		var cap := Sprite2D.new()
		cap.texture = _tileset
		cap.region_enabled = true
		cap.region_rect = Rect2(platform_tile_index * TILE_SIZE, 0, TILE_SIZE, TILE_SIZE)
		cap.centered = false
		cap.scale = Vector2(size.x / float(TILE_SIZE), 1.0)
		cap.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		parent.add_child(cap)
		return

	var cols := int(ceil(size.x / float(TILE_SIZE)))
	var rows := int(ceil(size.y / float(TILE_SIZE)))
	var region_x := tile_index * TILE_SIZE

	for row in rows:
		for col in cols:
			var sprite := Sprite2D.new()
			sprite.texture = _tileset
			sprite.region_enabled = true
			sprite.region_rect = Rect2(region_x, 0, TILE_SIZE, TILE_SIZE)
			sprite.centered = false
			sprite.position = Vector2(col * TILE_SIZE, row * TILE_SIZE)
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			parent.add_child(sprite)
