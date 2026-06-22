extends Control
## Relic inventory panel with equip/unequip.


@onready var relic_list: ItemList = $Panel/Margin/VBox/RelicList
@onready var detail_label: Label = $Panel/Margin/VBox/DetailLabel
@onready var currency_label: Label = $Panel/Margin/VBox/CurrencyLabel


func _ready() -> void:
	visible = false
	relic_list.item_selected.connect(_on_item_selected)


func refresh() -> void:
	relic_list.clear()
	for relic_id in InventorySystem.get_owned_relics():
		var relic := InventorySystem.get_relic(relic_id)
		if relic == null:
			continue
		var equipped := " [E]" if InventorySystem.is_equipped(relic_id) else ""
		relic_list.add_item("%s%s" % [relic.display_name, equipped])
		relic_list.set_item_metadata(relic_list.item_count - 1, relic_id)
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
	detail_label.text = "%s\n%s" % [relic.display_name, relic.description]


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.double_click:
		var index := relic_list.get_selected_items()
		if index.is_empty():
			return
		var relic_id: StringName = relic_list.get_item_metadata(index[0])
		if InventorySystem.is_equipped(relic_id):
			InventorySystem.unequip_relic(relic_id)
		else:
			InventorySystem.equip_relic(relic_id)
		refresh()
