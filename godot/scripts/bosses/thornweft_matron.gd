extends BaseBoss
## MB-01 Thornweft Matron — 2-phase vine boss.


func _perform_attack() -> void:
	if player == null:
		return
	face_player()
	if phase_manager.current_phase == 0:
		await _vine_lash()
	else:
		if randf() > 0.5:
			await _canopy_rain()
		else:
			await _vine_lash()


func _vine_lash() -> void:
	await show_telegraph(0.25, Color(1.0, 0.7, 0.2, 0.9))
	hitbox_component.damage = 12
	hitbox_component.damage_type = &"nature"
	hitbox_component.knockback_vector = Vector2(
		140.0 * (1.0 if player.global_position.x >= global_position.x else -1.0),
		-60.0
	)
	var offset_x := 48.0 * (1.0 if player.global_position.x >= global_position.x else -1.0)
	hitbox_component.global_position = global_position + Vector2(offset_x, -8.0)
	hitbox_component.enable_hitbox()
	await get_tree().create_timer(0.18).timeout
	hitbox_component.disable_hitbox()


func _canopy_rain() -> void:
	await show_telegraph(0.35, Color(0.8, 0.15, 0.2, 0.85))
	if player == null:
		return
	var rain_pos := player.global_position
	hitbox_component.damage = 10
	hitbox_component.damage_type = &"nature"
	hitbox_component.knockback_vector = Vector2(0, -80)
	hitbox_component.global_position = rain_pos
	hitbox_component.enable_hitbox()
	await get_tree().create_timer(0.22).timeout
	hitbox_component.disable_hitbox()


func _on_phase_enter(phase: int) -> void:
	if phase == 1:
		sprite.color = Color(0.35, 0.55, 0.28, 1.0)
