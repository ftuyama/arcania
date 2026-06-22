extends BaseBoss
## BOSS-01 Root Warden — 3-phase anchor/grapple boss.


func _ready() -> void:
	super._ready()
	sprite.color = Color(0.45, 0.38, 0.28, 1.0)


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
	await show_telegraph(0.5, Color(1.0, 0.84, 0.0, 0.9))
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
	await show_telegraph(0.35)
	var dir := 1.0 if player.global_position.x >= global_position.x else -1.0
	hitbox_component.damage = 22
	hitbox_component.damage_type = &"nature"
	hitbox_component.knockback_vector = Vector2(200.0 * dir, -100.0)
	hitbox_component.global_position = global_position + Vector2(64.0 * dir, -4.0)
	hitbox_component.enable_hitbox()
	await get_tree().create_timer(0.2).timeout
	hitbox_component.disable_hitbox()


func _lattice_merge_attack() -> void:
	await show_telegraph(0.4, Color(0.25, 0.57, 0.45, 0.9))
	modulate = Color(0.7, 0.9, 0.8, 0.85)
	await get_tree().create_timer(0.6).timeout
	modulate = Color.WHITE
	await _root_spear()


func _mass_pull() -> void:
	await show_telegraph(0.55, Color(1.0, 0.3, 0.2, 0.95))
	if player == null:
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


func _on_phase_enter(phase: int) -> void:
	match phase:
		1:
			sprite.color = Color(0.3, 0.5, 0.35, 1.0)
		2:
			sprite.color = Color(0.55, 0.2, 0.25, 1.0)
