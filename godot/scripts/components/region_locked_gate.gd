extends Area2D
## Blocks passage until a future region is implemented.


@export var required_region: StringName = &""
@export var message: String = "Path sealed — region not yet reachable."


func _ready() -> void:
	collision_layer = 128
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)


func _exit_tree() -> void:
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		EventBus.ui_toast.emit(message)
