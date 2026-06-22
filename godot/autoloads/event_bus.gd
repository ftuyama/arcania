extends Node
## Global signal hub for cross-system communication.
## See docs/08-technical-architecture.md §16.

# Player
signal player_spawned(player: Node2D)
signal player_damaged(amount: int, source: Node)
signal player_died
signal player_healed(amount: int)

# Combat
signal enemy_defeated(enemy_id: StringName, position: Vector2)
signal boss_fight_started(boss_id: StringName)
signal boss_phase_changed(boss_id: StringName, phase: int)
signal boss_defeated(boss_id: StringName)

# Spells
signal spell_cast(spell_id: StringName, caster: Node2D)
signal spell_acquired(spell_id: StringName)
signal spell_upgraded(spell_id: StringName, tier: int)

# World
signal room_entered(room_id: StringName, region_id: StringName)
signal region_entered(region_id: StringName)
signal ability_gate_cleared(gate_id: StringName)
signal anchor_activated(anchor_id: StringName)
signal interactable_triggered(interactable_id: StringName)

# Inventory / Quest
signal relic_acquired(relic_id: StringName)
signal quest_started(quest_id: StringName)
signal quest_updated(quest_id: StringName, objective_id: StringName)
signal quest_completed(quest_id: StringName)

# Save / Game
signal save_requested(slot_id: String)
signal game_loaded(slot_id: String)
signal game_paused
signal game_resumed
signal game_over_started
signal game_over_ended
signal ui_toast(message: String)
