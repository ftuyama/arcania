extends Area2D
## Grants a relic on player contact.


@export var relic_id: StringName = &""
@export var pickup_id: StringName = &""

var _collected: bool = false

@onready var _sprite: Sprite2D = $Sprite
@onready var _glow: Sprite2D = $Glow


func _ready() -> void:
	collision_layer = 128
	collision_mask = 2
	monitoring = true
	body_entered.connect(_on_body_entered)
	if pickup_id.is_empty():
		pickup_id = StringName(name)
	_apply_visual()
	if GameManager.is_pickup_collected(pickup_id):
		queue_free()


func _apply_visual() -> void:
	if relic_id.is_empty():
		return
	var relic := InventorySystem.get_relic(relic_id)
	if relic == null:
		return
	if relic.icon:
		_sprite.texture = relic.icon
	elif _sprite:
		_sprite.modulate = relic.icon_color


func _exit_tree() -> void:
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group(&"player"):
		return
	if relic_id.is_empty():
		return
	if GameManager.is_pickup_collected(pickup_id):
		queue_free()
		return
	_collected = true
	InventorySystem.acquire_relic(relic_id)
	GameManager.mark_pickup_collected(pickup_id)
	if String(pickup_id).contains("cache") or String(pickup_id).contains("secret"):
		MapManager.mark_secret_found(GameManager.current_region_id)
	EventBus.relic_acquired.emit(relic_id)
	queue_free()
