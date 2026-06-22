class_name BaseBoss
extends CharacterBody2D
## Shared boss body — phase manager, telegraphed attacks, defeat rewards.


@export var data: BossData

@onready var health_component: HealthComponent = $HealthComponent
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var phase_manager: BossPhaseManager = $BossPhaseManager
@onready var sprite: ColorRect = $Sprite
@onready var telegraph: ColorRect = $Telegraph
@onready var arena_boundary: StaticBody2D = $ArenaBoundary

var player: Player
var _fight_active: bool = false
var _attack_timer: float = 2.0
var _defeated: bool = false


func _ready() -> void:
	add_to_group(&"bosses")
	if data and GameManager.has_world_flag(data.world_flag):
		queue_free()
		return
	if data:
		health_component.max_hp = data.max_hp
		health_component.current_hp = data.max_hp
		health_component.poise = data.poise
		phase_manager.phase_thresholds = data.phase_thresholds.duplicate()
	phase_manager.setup(health_component, data.id if data else &"")
	phase_manager.phase_changed.connect(_on_phase_changed)
	phase_manager.boss_defeated.connect(_on_boss_defeated)
	health_component.damaged.connect(_on_damaged)
	if arena_boundary:
		arena_boundary.set_deferred(&"collision_layer", 0)
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group(&"player") as Player


func _physics_process(delta: float) -> void:
	if not _fight_active or _defeated:
		return
	_attack_timer -= delta
	if _attack_timer <= 0.0:
		_attack_timer = _get_attack_interval()
		_perform_attack()


func start_fight() -> void:
	if _fight_active:
		return
	_fight_active = true
	if arena_boundary:
		arena_boundary.collision_layer = 1
	EventBus.boss_fight_started.emit(data.id if data else &"")


func _on_damaged(_amount: int, _source: Node) -> void:
	if not _fight_active and health_component.current_hp < health_component.max_hp:
		start_fight()
	face_player()


func _on_phase_changed(phase: int) -> void:
	_on_phase_enter(phase)


func _on_boss_defeated() -> void:
	if _defeated:
		return
	_defeated = true
	_fight_active = false
	if arena_boundary:
		arena_boundary.collision_layer = 0
	if data:
		GameManager.set_world_flag(data.world_flag)
		if player and data.essence_reward > 0:
			player.add_essence(data.essence_reward)
		if not data.spell_unlock.is_empty():
			SpellManager.acquire_spell(data.spell_unlock)


func face_player() -> void:
	if player == null:
		return
	var dir := 1 if player.global_position.x >= global_position.x else -1
	sprite.scale.x = absf(sprite.scale.x) * float(dir)


func show_telegraph(duration: float, color: Color = Color(1.0, 0.42, 0.21, 0.85)) -> void:
	telegraph.visible = true
	telegraph.modulate = color
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(telegraph):
		telegraph.visible = false


func _get_attack_interval() -> float:
	return 2.5 - float(phase_manager.current_phase) * 0.4


func _perform_attack() -> void:
	pass


func _on_phase_enter(_phase: int) -> void:
	pass
