extends Area2D
## Grants a spell on player contact.


@export var spell_id: StringName = &""
@export var pickup_id: StringName = &""
@export var celebrate_unlock: bool = false
@export var glow_color: Color = Color(0.6, 0.85, 0.55, 0.5)

var _collected: bool = false
var _base_glow_scale: Vector2 = Vector2.ONE

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
	_start_idle_pulse()
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
	if _glow:
		_glow.modulate = glow_color
		_base_glow_scale = _glow.scale


func _start_idle_pulse() -> void:
	if _glow == null:
		return
	var tween := create_tween().set_loops()
	tween.tween_property(_glow, "modulate:a", glow_color.a * 0.45, 0.9).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_glow, "modulate:a", glow_color.a, 0.9).set_trans(Tween.TRANS_SINE)
	var scale_tween := create_tween().set_loops()
	scale_tween.tween_property(_glow, "scale", _base_glow_scale * 1.12, 0.9).set_trans(Tween.TRANS_SINE)
	scale_tween.tween_property(_glow, "scale", _base_glow_scale, 0.9).set_trans(Tween.TRANS_SINE)


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group(&"player"):
		return
	if spell_id.is_empty():
		return
	if GameManager.is_pickup_collected(pickup_id):
		queue_free()
		return
	_collected = true
	var pickup_pos := global_position
	SpellManager.acquire_spell(spell_id)
	GameManager.mark_pickup_collected(pickup_id)
	if celebrate_unlock and body is Player:
		SpellUnlockFanfare.play(spell_id, pickup_pos, body as Player)
	visible = false
	queue_free()
