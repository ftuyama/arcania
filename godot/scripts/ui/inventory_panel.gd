extends Control
## Relic inventory panel with equip/unequip.


@onready var relic_list: ItemList = $Panel/Margin/VBox/ContentRow/RelicList
@onready var detail_label: Label = $Panel/Margin/VBox/ContentRow/DetailPanel/Margin/VBox/DetailLabel
@onready var equip_label: Label = $Panel/Margin/VBox/ContentRow/DetailPanel/Margin/VBox/EquipLabel
@onready var currency_label: Label = $Panel/Margin/VBox/CurrencyLabel


func _ready() -> void:
	visible = false
	HudStyle.apply_hud_font($Panel/Margin/VBox/Title, 16, &"semibold")
	HudStyle.apply_hud_font($Panel/Margin/VBox/Subtitle, 11)
	HudStyle.apply_hud_font($Panel/Margin/VBox/ContentRow/DetailPanel/Margin/VBox/DetailHeading, 12, &"semibold")
	HudStyle.apply_hud_font(equip_label, 11)
	HudStyle.apply_ui_font(relic_list, 11)
	HudStyle.apply_hud_font(detail_label, 12)
	HudStyle.apply_hud_font(currency_label, 11)
	relic_list.item_selected.connect(_on_item_selected)
	relic_list.item_activated.connect(_on_relic_activated)
	_style_panel()


func refresh() -> void:
	relic_list.clear()
	for relic_id in InventorySystem.get_owned_relics():
		var relic := InventorySystem.get_relic(relic_id)
		if relic == null:
			continue
		var equipped := "  EQUIPPED" if InventorySystem.is_equipped(relic_id) else ""
		relic_list.add_item("%s%s" % [relic.display_name, equipped], relic.icon)
		relic_list.set_item_metadata(relic_list.item_count - 1, relic_id)
	equip_label.text = "Equipped: %d / %d" % [InventorySystem.get_equipped_relics().size(), InventorySystem.MAX_RELIC_SLOTS]
	currency_label.text = "Silk: %d  Residue: %d  Dust: %d" % [
		InventorySystem.get_currency("weave_silk"),
		InventorySystem.get_currency("ley_residue"),
		InventorySystem.get_currency("shard_dust"),
	]
	if relic_list.item_count > 0:
		relic_list.select(0)
		_on_item_selected(0)


func _on_item_selected(index: int) -> void:
	var relic_id: StringName = relic_list.get_item_metadata(index)
	var relic := InventorySystem.get_relic(relic_id)
	if relic == null:
		return
	var tier_names := ["I", "II", "III", "IV"]
	detail_label.text = "%s\n\nTIER %s\n%s" % [relic.display_name, tier_names[relic.tier], relic.description]


func _on_relic_activated(index: int) -> void:
	var relic_id: StringName = relic_list.get_item_metadata(index)
	if InventorySystem.is_equipped(relic_id):
		InventorySystem.unequip_relic(relic_id)
	else:
		InventorySystem.equip_relic(relic_id)
	refresh()


func _style_panel() -> void:
	var panel := HudStyle.make_panel_style(true)
	panel.bg_color = Color("201f2c")
	$Panel.add_theme_stylebox_override(&"panel", panel)
	var detail := HudStyle.make_panel_style()
	detail.bg_color = Color("151521")
	$Panel/Margin/VBox/ContentRow/DetailPanel.add_theme_stylebox_override(&"panel", detail)
	var list_style := HudStyle.make_panel_style()
	list_style.bg_color = Color("161620")
	relic_list.add_theme_stylebox_override(&"panel", list_style)
	$Panel/Margin/VBox/Title.add_theme_color_override(&"font_color", HudStyle.COLOR_XP)
	$Panel/Margin/VBox/Subtitle.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT_DIM)
	$Panel/Margin/VBox/ContentRow/DetailPanel/Margin/VBox/DetailHeading.add_theme_color_override(&"font_color", HudStyle.COLOR_MANA)
	equip_label.add_theme_color_override(&"font_color", HudStyle.COLOR_XP)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.double_click:
		var index := relic_list.get_selected_items()
		if index.is_empty():
			return
		_on_relic_activated(index[0])
