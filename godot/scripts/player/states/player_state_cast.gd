extends State
## Spell cast wind-up and release.


var _spell_id: StringName = &""
var _timer: float = 0.0
var _resolved: bool = false


func enter(payload: Dictionary) -> void:
	var player := _get_player()
	_spell_id = payload.get(&"spell_id", &"ember_sigil")
	_resolved = false

	if _spell_id == &"veil_step":
		if player.spell_caster.try_cast(_spell_id, player):
			var spell := SpellManager.get_spell(_spell_id)
			if spell:
				player.spell_caster.play_impact_sfx(spell, player.global_position)
			state_machine.transition_to(&"Dash", {"from_spell": true})
		else:
			state_machine.transition_to(&"Idle", {})
		return

	if _spell_id == &"arc_step":
		if player.spell_caster.try_cast(_spell_id, player):
			var aim := player.get_aim_direction()
			player.spell_caster.blink_player(player, aim, 96.0)
			var spell := SpellManager.get_spell(_spell_id)
			if spell:
				player.spell_caster.play_impact_sfx(spell, player.global_position)
			state_machine.transition_to(&"Idle", {})
		else:
			state_machine.transition_to(&"Idle", {})
		return

	if not player.spell_caster.try_cast(_spell_id, player):
		state_machine.transition_to(&"Idle", {})
		return

	var spell := SpellManager.get_spell(_spell_id)
	_timer = spell.cast_time if spell else 0.15
	player.velocity.x = 0.0
	player.play_animation(&"cast", true)


func physics_update(delta: float) -> void:
	var player := _get_player()
	_timer -= delta
	player.apply_gravity(delta)
	player.move_and_slide()

	if not _resolved and _timer <= 0.0:
		_resolved = true
		player.spell_caster.resolve_cast(_spell_id, player)

	if _resolved and _timer <= -0.05:
		if player.is_on_floor():
			state_machine.transition_to(&"Idle", {})
		else:
			state_machine.transition_to(&"Fall", {})


func _get_player() -> Player:
	return state_machine.get_parent() as Player
