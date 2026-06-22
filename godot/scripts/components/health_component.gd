class_name HealthComponent
extends Node
## Health and poise management component.


signal damaged(amount: int, source: Node)
signal died
signal healed(amount: int)
signal poise_broken

@export var max_hp: int = 80
var current_hp: int = 80
@export var poise: float = 10.0
var current_poise: float = 10.0
var is_invulnerable: bool = false
var is_staggered: bool = false

var _owner_body: CharacterBody2D


func _ready() -> void:
	current_hp = max_hp
	current_poise = poise
	_owner_body = get_parent() as CharacterBody2D


func take_damage(amount: int, source: Node = null, knockback: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable or amount <= 0:
		return
	current_hp = maxi(current_hp - amount, 0)
	damaged.emit(amount, source)
	if _owner_body and knockback != Vector2.ZERO:
		_owner_body.velocity = knockback
	if current_hp <= 0:
		died.emit()


func apply_poise_damage(amount: float) -> void:
	if amount <= 0.0 or poise <= 0.0 or is_staggered:
		return
	current_poise = maxf(current_poise - amount, 0.0)
	if current_poise <= 0.0:
		current_poise = poise
		is_staggered = true
		poise_broken.emit()
		get_tree().create_timer(0.45).timeout.connect(func() -> void:
			is_staggered = false
		, CONNECT_ONE_SHOT)


func heal(amount: int) -> void:
	if amount <= 0:
		return
	current_hp = mini(current_hp + amount, max_hp)
	healed.emit(amount)
