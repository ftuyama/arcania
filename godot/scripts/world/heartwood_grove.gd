extends Room
## Starts the Matron encounter on entry and seals both ground exits until victory.


const BOSS_ID := &"mb_01_thornweft_matron"

@onready var _boss: BaseBoss = $Entities/ThornweftMatron
@onready var _west_blocker: StaticBody2D = $EncounterBlockers/West
@onready var _east_blocker: StaticBody2D = $EncounterBlockers/East


func _ready() -> void:
	super._ready()
	if GameManager.is_boss_defeated(BOSS_ID):
		_set_exits_locked(false)
		return
	_set_exits_locked(true)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	call_deferred(&"_start_battle")


func _exit_tree() -> void:
	if EventBus.boss_defeated.is_connected(_on_boss_defeated):
		EventBus.boss_defeated.disconnect(_on_boss_defeated)


func _start_battle() -> void:
	if is_instance_valid(_boss):
		_boss.start_fight()


func _on_boss_defeated(boss_id: StringName) -> void:
	if boss_id == BOSS_ID:
		_set_exits_locked(false)


func _set_exits_locked(locked: bool) -> void:
	_west_blocker.set_deferred(&"collision_layer", 1 if locked else 0)
	_east_blocker.set_deferred(&"collision_layer", 1 if locked else 0)
