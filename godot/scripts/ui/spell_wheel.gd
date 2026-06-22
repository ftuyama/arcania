extends Control
## 8-slot spell wheel for loadout management.


@onready var slot_grid: GridContainer = $Panel/Margin/VBox/SlotGrid
@onready var acquired_list: ItemList = $Panel/Margin/VBox/AcquiredList
@onready var hint_label: Label = $Panel/Margin/VBox/HintLabel


var _selected_wheel_slot: int = -1


func _ready() -> void:
	visible = false
	acquired_list.item_selected.connect(_on_acquired_selected)


func refresh() -> void:
	for child in slot_grid.get_children():
		child.queue_free()
	slot_grid.columns = 4
	for i in SpellManager.WHEEL_SIZE:
		var btn := Button.new()
		var spell_id := SpellManager.get_wheel_slot(i)
		if spell_id.is_empty():
			btn.text = "[%d] —" % (i + 1)
		else:
			var spell := SpellManager.get_spell(spell_id)
			btn.text = "[%d] %s" % [i + 1, spell.display_name if spell else String(spell_id)]
		btn.pressed.connect(_on_wheel_slot_pressed.bind(i))
		slot_grid.add_child(btn)
	acquired_list.clear()
	for spell_id in SpellManager.get_acquired_spells():
		var spell := SpellManager.get_spell(spell_id)
		if spell:
			acquired_list.add_item(spell.display_name)
			acquired_list.set_item_metadata(acquired_list.item_count - 1, spell_id)
	hint_label.text = "Select wheel slot, then pick a spell. Quick slots 1-4 use wheel loadout."


func _on_wheel_slot_pressed(index: int) -> void:
	_selected_wheel_slot = index


func _on_acquired_selected(index: int) -> void:
	if _selected_wheel_slot < 0:
		return
	var spell_id: StringName = acquired_list.get_item_metadata(index)
	SpellManager.set_wheel_slot(_selected_wheel_slot, spell_id)
	if _selected_wheel_slot < SpellManager.QUICK_SLOT_COUNT:
		SpellManager.set_quick_slot(_selected_wheel_slot, spell_id)
	refresh()
