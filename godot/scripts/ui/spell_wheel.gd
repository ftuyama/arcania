extends Control
## 8-slot spell wheel for loadout management.


const WHEEL_RADIUS := 78.0
const SLOT_SIZE := Vector2(48, 28)

@onready var slot_grid: Control = $Panel/Margin/VBox/ContentRow/SlotGrid
@onready var acquired_list: ItemList = $Panel/Margin/VBox/ContentRow/SpellArchive/AcquiredList
@onready var hint_label: Label = $Panel/Margin/VBox/ContentRow/SpellArchive/HintLabel


var _selected_wheel_slot: int = -1


func _ready() -> void:
	visible = false
	HudStyle.apply_hud_font($Panel/Margin/VBox/Title, 16, &"semibold")
	HudStyle.apply_hud_font($Panel/Margin/VBox/ContentRow/SpellArchive/ArchiveLabel, 12, &"semibold")
	HudStyle.apply_hud_font($Panel/Margin/VBox/ContentRow/SlotGrid/CenterLabel, 13, &"semibold")
	HudStyle.apply_ui_font(acquired_list, 11)
	HudStyle.apply_hud_font(hint_label, 12)
	acquired_list.item_selected.connect(_on_acquired_selected)
	_style_panel()


func refresh() -> void:
	for child in slot_grid.get_children():
		child.queue_free()
	var center := slot_grid.size * 0.5
	if center == Vector2.ZERO:
		center = slot_grid.custom_minimum_size * 0.5
	for i in SpellManager.WHEEL_SIZE:
		var btn := Button.new()
		var spell_id := SpellManager.get_wheel_slot(i)
		btn.custom_minimum_size = SLOT_SIZE
		btn.size = SLOT_SIZE
		var angle := -PI * 0.5 + TAU * float(i) / float(SpellManager.WHEEL_SIZE)
		btn.position = center + Vector2(cos(angle), sin(angle)) * WHEEL_RADIUS - SLOT_SIZE * 0.5
		if spell_id.is_empty():
			btn.text = "%d  —" % (i + 1)
		else:
			var spell := SpellManager.get_spell(spell_id)
			btn.text = str(i + 1)
			if spell:
				btn.icon = spell.icon
				btn.tooltip_text = "%s\n%d mana" % [spell.description, spell.mana_cost]
		HudStyle.apply_ui_font(btn, 11)
		btn.add_theme_stylebox_override(&"normal", HudStyle.make_slot_style(i == _selected_wheel_slot))
		if i == _selected_wheel_slot:
			btn.add_theme_color_override(&"font_color", HudStyle.COLOR_EMBER)
		btn.pressed.connect(_on_wheel_slot_pressed.bind(i))
		UiSfx.wire_button(btn)
		slot_grid.add_child(btn)
	acquired_list.clear()
	for spell_id in SpellManager.get_acquired_spells():
		var spell := SpellManager.get_spell(spell_id)
		if spell:
			acquired_list.add_item(spell.display_name, spell.icon)
			acquired_list.set_item_metadata(acquired_list.item_count - 1, spell_id)
	hint_label.text = "Pick a wheel slot, then a spell."


func _on_wheel_slot_pressed(index: int) -> void:
	_selected_wheel_slot = index
	refresh()
	hint_label.text = "Slot %d selected." % (index + 1)


func _on_acquired_selected(index: int) -> void:
	if _selected_wheel_slot < 0:
		return
	var spell_id: StringName = acquired_list.get_item_metadata(index)
	SpellManager.set_wheel_slot(_selected_wheel_slot, spell_id)
	if _selected_wheel_slot < SpellManager.QUICK_SLOT_COUNT:
		SpellManager.set_quick_slot(_selected_wheel_slot, spell_id)
	refresh()


func _style_panel() -> void:
	var panel := HudStyle.make_panel_style(true)
	panel.bg_color = Color("171724")
	$Panel.add_theme_stylebox_override(&"panel", panel)
	var archive := HudStyle.make_panel_style()
	archive.bg_color = Color("10101a")
	acquired_list.add_theme_stylebox_override(&"panel", archive)
	$Panel/Margin/VBox/Title.add_theme_color_override(&"font_color", HudStyle.COLOR_XP)
	$Panel/Margin/VBox/ContentRow/SpellArchive/ArchiveLabel.add_theme_color_override(&"font_color", HudStyle.COLOR_MANA)
	$Panel/Margin/VBox/ContentRow/SlotGrid/CenterLabel.add_theme_color_override(&"font_color", HudStyle.COLOR_EMBER)
