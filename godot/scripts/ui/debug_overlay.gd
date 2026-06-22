extends CanvasLayer
## Debug overlay — toggle with F3.


@onready var label: Label = $Label


func _ready() -> void:
	visible = false
	layer = 100


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		visible = not visible


func _process(_delta: float) -> void:
	if not visible:
		return
	var fps := Engine.get_frames_per_second()
	var room := GameManager.current_room_id
	var region := GameManager.current_region_id
	label.text = "FPS: %d | Room: %s | Region: %s\nJ: melee | 1: Ember Sigil | 2: Ember Bolt | 3/Shift: Veil Step\nF3: toggle debug" % [fps, room, region]
