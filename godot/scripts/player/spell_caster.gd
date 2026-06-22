extends Node
## Resolves spell casting for the player.


@onready var projectile_pool: Node = $ProjectilePool
@onready var melee_hitbox: HitboxComponent = $"../MeleeHitbox"


func try_cast(spell_id: StringName, player: Player) -> bool:
	var spell := SpellManager.get_spell(spell_id)
	if spell == null:
		return false
	if not SpellManager.can_cast(spell_id, player.mana_component.current_mana):
		return false
	var cost := SpellManager.get_effective_cost(spell_id)
	if not player.mana_component.try_spend(cost, player.health_component):
		return false
	SpellManager.start_cooldown(spell_id)
	play_cast_sfx(spell, player.global_position)
	EventBus.spell_cast.emit(spell_id, player)
	return true


func resolve_cast(spell_id: StringName, player: Player) -> void:
	var spell := SpellManager.get_spell(spell_id)
	if spell == null:
		return
	var mods := InventorySystem.get_aggregated_modifiers()
	match spell_id:
		&"ember_sigil":
			_fire_sigil_hitbox(player, spell, mods)
			play_impact_sfx(spell, player.global_position + Vector2(28.0 * float(player.facing_direction), -8.0))
		&"ember_bolt":
			projectile_pool.spawn(
				player.global_position + Vector2(0, -8),
				player.get_aim_direction(),
				spell
			)
		&"veil_step":
			pass
		&"rootbind":
			_cast_rootbind(player, spell)
			play_impact_sfx(spell, player.global_position + Vector2(0, -96))
		&"arc_step":
			pass
		&"rune_anchor":
			_cast_rune_anchor(player, spell, mods)


func play_cast_sfx(spell: SpellData, position: Vector2) -> void:
	if spell.cast_sfx:
		AudioManager.play_sfx_stream(spell.cast_sfx, position)


func play_impact_sfx(spell: SpellData, position: Vector2) -> void:
	if spell.impact_sfx:
		AudioManager.play_sfx_stream(spell.impact_sfx, position)


func blink_player(player: Player, direction: Vector2, distance: float) -> void:
	var mods := InventorySystem.get_aggregated_modifiers()
	var iframe_bonus := int(mods.get("veil_step_iframes_flat", 0))
	var iframe_duration := 0.14 + float(iframe_bonus) / 60.0
	player.set_invulnerable(true)
	player.set_phasing(true)
	player.global_position += direction.normalized() * distance
	player.velocity = direction.normalized() * Player.DASH_SPEED
	player.get_tree().create_timer(iframe_duration).timeout.connect(func() -> void:
		if is_instance_valid(player):
			player.set_invulnerable(false)
			player.set_phasing(false)
	, CONNECT_ONE_SHOT)


func _cast_rootbind(player: Player, spell: SpellData) -> void:
	_spawn_vine_platform(player)
	_notify_nearby_gates(player, spell.id)
	for gate in player.get_tree().get_nodes_in_group(&"ability_gates"):
		if gate.has_method(&"on_hit_by_spell"):
			gate.on_hit_by_spell(spell.id, melee_hitbox)


func _cast_rune_anchor(player: Player, spell: SpellData, mods: Dictionary) -> void:
	var aim := player.get_aim_direction()
	var range_tiles := 8.0 + float(mods.get("rune_anchor_range_tiles", 0.0))
	var range_px := range_tiles * 64.0
	var space := player.get_world_2d().direct_space_state
	var from := player.global_position + Vector2(0, -16)
	var to := from + aim * range_px
	var query := PhysicsRayQueryParameters2D.create(from, to)
	query.collision_mask = 256
	query.collide_with_areas = true
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return
	var target := hit.collider as Node2D
	if target == null or not target.is_in_group(&"anchor_points"):
		return
	var anchor_pos := target.global_position
	play_impact_sfx(spell, anchor_pos)
	var tween := player.create_tween()
	tween.tween_property(player, "global_position", anchor_pos, 0.25).set_trans(Tween.TRANS_QUAD)
	_notify_nearby_gates(player, spell.id)


func _spawn_vine_platform(player: Player) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(64, 16)
	shape.shape = rect
	shape.position = Vector2(32, 8)
	body.add_child(shape)
	var visual := ColorRect.new()
	visual.size = Vector2(64, 16)
	visual.color = Color(0.32, 0.62, 0.28, 1)
	body.add_child(visual)
	body.global_position = player.global_position + Vector2(-32, -96)
	player.get_parent().add_child(body)


func _fire_sigil_hitbox(player: Player, spell: SpellData, mods: Dictionary) -> void:
	var damage := spell.base_damage
	if mods.has("burn_damage_mult"):
		damage = int(float(damage) * float(mods["burn_damage_mult"]))
	melee_hitbox.configure_melee(player.facing_direction, Vector2(12.0, -8.0))
	melee_hitbox.damage = damage
	melee_hitbox.damage_type = &"fire"
	melee_hitbox.knockback_vector = Vector2(100.0 * float(player.facing_direction), -40.0)
	melee_hitbox.enable_hitbox()
	player.get_tree().create_timer(0.12).timeout.connect(func() -> void:
		melee_hitbox.disable_hitbox()
	)
	_notify_nearby_gates(player, spell.id)


func _notify_nearby_gates(player: Player, spell_id: StringName) -> void:
	for gate in player.get_tree().get_nodes_in_group(&"ability_gates"):
		if gate.has_method(&"on_hit_by_spell"):
			gate.on_hit_by_spell(spell_id, melee_hitbox)
