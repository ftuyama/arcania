extends Area2D
## Grants a spell on player contact.


@export var spell_id: StringName = &""
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
	if spell_id.is_empty():
		return
	var spell := SpellManager.get_spell(spell_id)
	if spell == null:
		return
	if spell.icon:
		_sprite.texture = spell.icon


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group(&"player"):
		return
	if spell_id.is_empty():
		return
	if GameManager.is_pickup_collected(pickup_id):
		queue_free()
		return
	_collected = true
	SpellManager.acquire_spell(spell_id)
	GameManager.mark_pickup_collected(pickup_id)
	EventBus.spell_acquired.emit(spell_id)
	queue_free()
