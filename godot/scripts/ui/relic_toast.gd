extends Control
## Toast notification for relic pickups — bottom-right, ~1s fade (GDD §9.1).


@onready var label: Label = $Panel/Label
@onready var panel: PanelContainer = $Panel


func _ready() -> void:
	visible = false
	modulate.a = 0.0
	if panel:
		panel.add_theme_stylebox_override(&"panel", HudStyle.make_panel_style())
	if label:
		HudStyle.apply_hud_font(label, 12)
		label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT)


func show_relic(relic_id: StringName) -> void:
	var relic := InventorySystem.get_relic(relic_id)
	if relic == null:
		return
	label.text = "Relic Acquired: %s" % relic.display_name
	visible = true
	modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	tween.tween_callback(func() -> void: visible = false)
