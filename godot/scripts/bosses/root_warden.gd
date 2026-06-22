extends BaseBoss
## BOSS-01 Root Warden — 3-phase anchor/grapple boss with counterable mass-pull.


var _counter_window_active: bool = false
var _pull_cancelled: bool = false


func _ready() -> void:
	super._ready()
	EventBus.spell_cast.connect(_on_spell_cast)


func _exit_tree() -> void:
	if EventBus.spell_cast.is_connected(_on_spell_cast):
		EventBus.spell_cast.disconnect(_on_spell_cast)


func _perform_attack() -> void:
	if player == null:
		return
	face_player()
	match phase_manager.current_phase:
		0:
			if randf() > 0.4:
				await _anchor_pull()
			else:
				await _root_spear()
		1:
			await _lattice_merge_attack()
		_:
			await _mass_pull()


func _anchor_pull() -> void:
	await show_telegraph(0.5, Color(1.0, 0.84, 0.0, 0.9), 3)
	if player == null:
		return
	var pull_dir := (global_position - player.global_position).normalized()
	player.velocity = pull_dir * 280.0
	hitbox_component.damage = 14
	hitbox_component.damage_type = &"arcane"
	hitbox_component.knockback_vector = pull_dir * 120.0
	hitbox_component.global_position = player.global_position
	hitbox_component.enable_hitbox()
	await get_tree().create_timer(0.15).timeout
	hitbox_component.disable_hitbox()


func _root_spear() -> void:
	await show_telegraph(0.35, Color(1.0, 0.42, 0.21, 0.85), 2)
	play_animation(&"attack")
	var dir := 1.0 if player.global_position.x >= global_position.x else -1.0
	hitbox_component.damage = 22
	hitbox_component.damage_type = &"nature"
	hitbox_component.knockback_vector = Vector2(200.0 * dir, -100.0)
	hitbox_component.global_position = global_position + Vector2(64.0 * dir, -4.0)
	hitbox_component.enable_hitbox()
	await get_tree().create_timer(0.2).timeout
	hitbox_component.disable_hitbox()
	play_animation(&"idle")


func _lattice_merge_attack() -> void:
	await show_telegraph(0.4, Color(0.25, 0.57, 0.45, 0.9), 2)
	play_animation(&"phase2")
	modulate = Color(0.7, 0.9, 0.8, 0.85)
	await get_tree().create_timer(0.6).timeout
	modulate = Color.WHITE
	await _root_spear()


func _mass_pull() -> void:
	_pull_cancelled = false
	_counter_window_active = true
	await show_telegraph(0.55, Color(0.48, 0.17, 0.75, 0.95), 3)
	if player == null:
		_counter_window_active = false
		return
	# T4 safe window — counter with Rune Anchor or Veil Step dash.
	telegraph.visible = true
	telegraph.modulate = Color(0.28, 0.79, 0.89, 0.9)
	await get_tree().create_timer(0.35).timeout
	telegraph.visible = false
	_counter_window_active = false
	if _pull_cancelled or player == null:
		EventBus.ui_toast.emit("Pull countered!")
		modulate = Color(0.6, 0.9, 1.0, 1.0)
		await get_tree().create_timer(0.4).timeout
		modulate = Color.WHITE
		return
	var pull_dir := (global_position - player.global_position).normalized()
	player.velocity = pull_dir * 360.0
	hitbox_component.damage = 28
	hitbox_component.damage_type = &"arcane"
	hitbox_component.knockback_vector = pull_dir * 180.0
	hitbox_component.global_position = player.global_position
	hitbox_component.enable_hitbox()
	await get_tree().create_timer(0.25).timeout
	hitbox_component.disable_hitbox()


func _on_spell_cast(spell_id: StringName, caster: Node2D) -> void:
	if not _counter_window_active or caster != player:
		return
	if spell_id == &"rune_anchor" or spell_id == &"veil_step" or spell_id == &"arc_step":
		_pull_cancelled = true


func _on_phase_enter(phase: int) -> void:
	match phase:
		1:
			play_animation(&"phase2")
		2:
			play_animation(&"phase3")
