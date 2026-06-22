class_name BaseEnemy
extends CharacterBody2D
## Shared enemy body with data-driven stats.


@export var data: EnemyData
@export var patrol_left: float = -64.0
@export var patrol_right: float = 64.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: StateMachine = $StateMachine
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var detection_area: Area2D = $DetectionArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var telegraph: ColorRect = $Telegraph

var player: Player
var facing_direction: int = -1
var home_position: Vector2
var _current_anim: StringName = &""


func _ready() -> void:
	add_to_group(&"enemies")
	home_position = global_position
	if data:
		health_component.max_hp = data.max_hp
		health_component.current_hp = data.max_hp
		health_component.poise = data.poise
		hurtbox_component.set_damage_multipliers(data.damage_multipliers)
	health_component.damaged.connect(_on_damaged)
	health_component.died.connect(_on_died)
	health_component.poise_broken.connect(_on_poise_broken)
	play_animation(&"idle")
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group(&"player") as Player


func get_player() -> Player:
	if player == null:
		player = get_tree().get_first_node_in_group(&"player") as Player
	return player


func get_data() -> EnemyData:
	return data


func face_player() -> void:
	var target := get_player()
	if target == null:
		return
	facing_direction = 1 if target.global_position.x >= global_position.x else -1
	update_facing()


func update_facing() -> void:
	animated_sprite.flip_h = facing_direction < 0


func play_animation(anim_name: StringName) -> void:
	if _current_anim == anim_name:
		return
	if not animated_sprite.sprite_frames or not animated_sprite.sprite_frames.has_animation(anim_name):
		return
	_current_anim = anim_name
	animated_sprite.play(anim_name)


func show_telegraph(duration: float) -> void:
	telegraph.visible = true
	telegraph.modulate = Color(0.32, 0.72, 0.53, 0.85)
	await get_tree().create_timer(duration).timeout
	telegraph.visible = false


func finalize_custom_defeat() -> void:
	if data == null:
		queue_free()
		return
	EventBus.enemy_defeated.emit(data.id, global_position)
	var target := get_player()
	if target:
		target.add_essence(data.essence_reward)
	queue_free()


func _on_damaged(_amount: int, _source: Node) -> void:
	if health_component.current_hp > 0:
		var current := state_machine.current_state
		if current and current.name != &"Hit" and current.name != &"Dead":
			state_machine.transition_to(&"Hit", {})


func _on_poise_broken() -> void:
	if health_component.current_hp <= 0:
		return
	velocity = Vector2.ZERO
	telegraph.visible = true
	telegraph.modulate = Color(0.29, 0.8, 0.95, 0.85)
	get_tree().create_timer(0.45).timeout.connect(func() -> void:
		if is_instance_valid(telegraph):
			telegraph.visible = false
	, CONNECT_ONE_SHOT)


func _on_died() -> void:
	state_machine.transition_to(&"Dead", {})
