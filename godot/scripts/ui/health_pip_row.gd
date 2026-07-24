extends HBoxContainer
## Diamond HP gem pips — one pip per 10 max HP (GDD §9.1).


const HP_PER_PIP := 10
const PIP_SIZE := Vector2(12, 14)

var _pips: Array[TextureRect] = []


func _ready() -> void:
	add_theme_constant_override(&"separation", 2)


func update_health(current_hp: int, max_hp: int) -> void:
	var pip_count := maxi(ceili(float(maxi(max_hp, 1)) / float(HP_PER_PIP)), 1)
	_ensure_pip_count(pip_count)
	var ratio := float(current_hp) / float(maxi(max_hp, 1))
	var low_tint := Color.WHITE.lerp(HudStyle.COLOR_HP_LOW, 1.0 - clampf(ratio * 2.0, 0.0, 1.0))
	var filled := ceili(float(maxi(current_hp, 0)) / float(HP_PER_PIP))
	filled = mini(filled, pip_count)
	if current_hp > 0 and filled == 0:
		filled = 1
	var filled_tex := HudStyle.get_hud_texture(&"hp_pip_filled")
	var empty_tex := HudStyle.get_hud_texture(&"hp_pip_empty")
	for i in _pips.size():
		var pip := _pips[i]
		if i < filled:
			pip.texture = filled_tex
			pip.modulate = low_tint
		else:
			pip.texture = empty_tex
			pip.modulate = Color.WHITE


func _ensure_pip_count(count: int) -> void:
	var empty_tex := HudStyle.get_hud_texture(&"hp_pip_empty")
	while _pips.size() < count:
		var pip := TextureRect.new()
		pip.custom_minimum_size = PIP_SIZE
		pip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		pip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		pip.texture = empty_tex
		add_child(pip)
		_pips.append(pip)
	while _pips.size() > count:
		var pip := _pips.pop_back() as TextureRect
		pip.queue_free()


func flash_damage() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", HudStyle.COLOR_HP_LOW, 0.06)
	tween.tween_property(self, "modulate", Color.WHITE, 0.14)
