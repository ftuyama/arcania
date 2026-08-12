class_name HudStyle
extends RefCounted
## Shared HUD StyleBox / font / texture helpers (art bible §10 color tokens).


const COLOR_BG := Color(0.102, 0.102, 0.18, 0.96) # #1A1A2E @ 96%
const COLOR_BORDER := Color(0.173, 0.173, 0.204, 1.0) # #2C2C34
const COLOR_BORDER_GOLD := Color(0.549, 0.384, 0.141, 0.9) # #8C6224
const COLOR_TEXT := Color(0.91, 0.91, 0.91, 1.0) # #E8E8E8
const COLOR_TEXT_DIM := Color(0.72, 0.76, 0.84, 1.0)
const COLOR_MANA := Color(0.0, 1.0, 1.0, 1.0) # #00FFFF
const COLOR_HP := Color(1.0, 0.867, 0.824, 1.0) # #FFDDD2
const COLOR_HP_LOW := Color(0.898, 0.22, 0.231, 1.0) # #E5383B
const COLOR_EMBER := Color(1.0, 0.42, 0.208, 1.0) # #FF6B35
const COLOR_PIP_EMPTY := Color(0.173, 0.173, 0.204, 1.0)

const FONT_REGULAR_PATH := "res://assets/fonts/Cinzel-Regular.ttf"
const FONT_SEMIBOLD_PATH := "res://assets/fonts/Cinzel-SemiBold.ttf"
const MIN_READABLE_FONT_SIZE := 11
const TEXT_SHADOW_COLOR := Color(0.0, 0.0, 0.0, 0.9)
const TEXT_SHADOW_OFFSET := 1

const HUD_DIR := "res://assets/sprites/ui/hud/"

## Logical key → filename under HUD_DIR.
const HUD_TEXTURE_PATHS: Dictionary = {
	&"portrait_frame": "ui_hud_portrait_frame.png",
	&"hp_pip_filled": "ui_hud_hp_pip_filled.png",
	&"hp_pip_empty": "ui_hud_hp_pip_empty.png",
	&"mana_bar_bg": "ui_hud_mana_bar_bg.png",
	&"mana_bar_fill": "ui_hud_mana_bar_fill.png",
	&"overcast_edge": "ui_hud_overcast_edge.png",
	&"minimap_frame": "ui_hud_minimap_frame.png",
	&"player_marker": "ui_hud_player_marker.png",
	&"spell_slot": "ui_hud_spell_slot_ornate.png",
	&"spell_slot_active": "ui_hud_spell_slot_ornate.png",
	&"shard_icon": "ui_hud_shard_icon.png",
	&"skull_icon": "ui_hud_skull_icon.png",
	&"currency_endcap": "ui_hud_currency_endcap.png",
	&"compass_icon": "ui_hud_compass_icon.png",
}

static var _font_regular: FontFile
static var _font_semibold: FontFile
static var _texture_cache: Dictionary = {}


static func get_font(weight: StringName = &"regular") -> FontFile:
	if weight == &"semibold":
		if _font_semibold == null:
			_font_semibold = load(FONT_SEMIBOLD_PATH) as FontFile
		return _font_semibold
	if _font_regular == null:
		_font_regular = load(FONT_REGULAR_PATH) as FontFile
	return _font_regular


static func apply_hud_font(label: Label, size: int, weight: StringName = &"semibold") -> void:
	apply_ui_font(label, size, weight)


static func apply_ui_font(control: Control, size: int, weight: StringName = &"semibold") -> void:
	var font := get_font(weight)
	if font:
		control.add_theme_font_override(&"font", font)
	control.add_theme_font_size_override(&"font_size", maxi(size, MIN_READABLE_FONT_SIZE))
	control.add_theme_color_override(&"font_shadow_color", TEXT_SHADOW_COLOR)
	control.add_theme_constant_override(&"shadow_offset_x", TEXT_SHADOW_OFFSET)
	control.add_theme_constant_override(&"shadow_offset_y", TEXT_SHADOW_OFFSET)


static func get_hud_texture(key: StringName) -> Texture2D:
	if _texture_cache.has(key):
		return _texture_cache[key] as Texture2D
	if not HUD_TEXTURE_PATHS.has(key):
		push_error("HudStyle: unknown texture key '%s'" % String(key))
		return null
	var path: String = HUD_DIR + str(HUD_TEXTURE_PATHS[key])
	if not ResourceLoader.exists(path):
		push_warning("HudStyle: missing HUD texture %s" % path)
		_texture_cache[key] = null
		return null
	var tex := load(path) as Texture2D
	_texture_cache[key] = tex
	return tex


static func make_nine_patch_style(texture: Texture2D, margins: Rect2i) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = float(margins.position.x)
	style.texture_margin_top = float(margins.position.y)
	style.texture_margin_right = float(margins.size.x)
	style.texture_margin_bottom = float(margins.size.y)
	return style


static func make_panel_style(gold_border: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.border_color = COLOR_BORDER_GOLD if gold_border else COLOR_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 4
	style.content_margin_top = 4
	style.content_margin_right = 4
	style.content_margin_bottom = 4
	return style


static func make_bar_bg() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_BG
	style.border_color = COLOR_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 2
	style.content_margin_top = 2
	style.content_margin_right = 2
	style.content_margin_bottom = 2
	return style


static func make_fill_style(fill_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.set_corner_radius_all(1)
	return style


static func make_pip_style(filled: bool, fill_color: Color = COLOR_HP) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color if filled else COLOR_PIP_EMPTY
	style.border_color = COLOR_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(1)
	return style


static func make_slot_style(active: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.9)
	style.border_color = COLOR_BORDER_GOLD if active else COLOR_BORDER
	style.set_border_width_all(1 if not active else 2)
	style.set_corner_radius_all(2)
	style.content_margin_left = 3
	style.content_margin_top = 3
	style.content_margin_right = 3
	style.content_margin_bottom = 3
	return style
