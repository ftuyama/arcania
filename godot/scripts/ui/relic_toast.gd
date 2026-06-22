extends Control
## Toast notification for relic pickups.


@onready var label: Label = $Panel/Label


func _ready() -> void:
	visible = false
	modulate.a = 0.0


func show_relic(relic_id: StringName) -> void:
	var relic := InventorySystem.get_relic(relic_id)
	if relic == null:
		return
	label.text = "Relic Acquired: %s" % relic.display_name
	visible = true
	modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(2.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func() -> void: visible = false)
