extends Control
## Shard-aligned mana segments with textured metallic bar frame.


const MANA_PER_SHARD := 10
const SEGMENT_HEIGHT := 8
const SEGMENT_GAP := 2
const MIN_SEGMENT_WIDTH := 28
const BAR_INSET := Rect2(10, 4, 120, 8) # inset inside 140×16 bg sprite

var _shard_count: int = 3
var _current_mana: float = 30.0
var _max_mana: float = 30.0
var _overcast_visible: bool = false
var _bg_tex: Texture2D
var _fill_tex: Texture2D
var _overcast_tex: Texture2D


func _ready() -> void:
	custom_minimum_size = Vector2(140, 16)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg_tex = HudStyle.get_hud_texture(&"mana_bar_bg")
	_fill_tex = HudStyle.get_hud_texture(&"mana_bar_fill")
	_overcast_tex = HudStyle.get_hud_texture(&"overcast_edge")


func update_mana(current: float, maximum: float, shard_count: int = -1) -> void:
	_current_mana = current
	_max_mana = maximum
	if shard_count > 0:
		_shard_count = shard_count
	var width := _shard_count * MIN_SEGMENT_WIDTH + maxi(_shard_count - 1, 0) * SEGMENT_GAP + 20
	var min_size := Vector2(float(maxi(width, 140)), 16.0)
	if custom_minimum_size != min_size:
		custom_minimum_size = min_size
	queue_redraw()


func set_overcast_visible(visible_flag: bool) -> void:
	_overcast_visible = visible_flag
	queue_redraw()


func flash_overcast() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", HudStyle.COLOR_HP_LOW, 0.06)
	tween.tween_property(self, "modulate", Color.WHITE, 0.14)


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	if _bg_tex:
		# Stretch 9-slice manually: draw full bg scaled to size
		draw_texture_rect(_bg_tex, rect, false)
	else:
		draw_style_box(HudStyle.make_bar_bg(), rect)
	if _shard_count <= 0:
		return
	# Scale inset proportionally when bar is wider than 140
	var scale_x := size.x / 140.0
	var inset := Rect2(
		BAR_INSET.position.x * scale_x,
		BAR_INSET.position.y,
		(size.x - 20.0 * scale_x),
		float(SEGMENT_HEIGHT)
	)
	var total_gap := float((_shard_count - 1) * SEGMENT_GAP)
	var seg_w := (inset.size.x - total_gap) / float(_shard_count)
	for i in _shard_count:
		var x := inset.position.x + float(i) * (seg_w + float(SEGMENT_GAP))
		var seg_rect := Rect2(x, inset.position.y, seg_w, inset.size.y)
		draw_rect(seg_rect, Color(0.08, 0.08, 0.12, 0.95), true)
		var shard_start := float(i * MANA_PER_SHARD)
		var fill_in_shard := clampf(_current_mana - shard_start, 0.0, float(MANA_PER_SHARD))
		var fill_ratio := fill_in_shard / float(MANA_PER_SHARD)
		if fill_ratio > 0.0:
			var fill_rect := Rect2(seg_rect.position, Vector2(seg_rect.size.x * fill_ratio, seg_rect.size.y))
			if _fill_tex:
				draw_texture_rect(_fill_tex, fill_rect, false)
			else:
				draw_rect(fill_rect, HudStyle.COLOR_MANA, true)
		draw_rect(seg_rect, HudStyle.COLOR_BORDER, false, 1.0)
	if _overcast_visible:
		var bleed := Rect2(8.0 * scale_x, size.y - 4.0, size.x - 16.0 * scale_x, 4.0)
		if _overcast_tex:
			draw_texture_rect(_overcast_tex, bleed, false)
		else:
			draw_rect(bleed, Color(HudStyle.COLOR_HP_LOW.r, HudStyle.COLOR_HP_LOW.g, HudStyle.COLOR_HP_LOW.b, 0.85), true)
