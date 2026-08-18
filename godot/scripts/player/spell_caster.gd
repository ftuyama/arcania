extends Node
## Resolves spell casting for the player.


const CAST_FAIL_SFX := "res://assets/audio/sfx/ui/ui_menu_select.wav"
const ROOTBIND_PLATFORM_TEXTURE := preload("res://assets/sprites/world/world_rootbind_platform.png")
const ARC_STEP_VFX := preload("res://assets/sprites/vfx/spells/vfx_arc_step.tres")
const ARC_STEP_COLOR := Color(0.0, 1.0, 1.0, 0.65)

@onready var projectile_pool: Node = $ProjectilePool
@onready var melee_hitbox: HitboxComponent = $"../MeleeHitbox"


func try_cast(spell_id: StringName, player: Player) -> bool:
	var spell := SpellManager.get_spell(spell_id)
	if spell == null:
		return false
	if not SpellManager.has_spell(spell_id):
		return false
	if SpellManager.is_on_cooldown(spell_id):
		return false
	var cost := SpellManager.get_effective_cost(spell_id)
	if not player.mana_component.can_afford(cost):
		play_cast_fail_sfx(player.global_position)
		return false
	if not player.mana_component.spend_mana(cost):
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
		&"ember_sigil", &"ember_bolt":
			var aim := player.get_aim_direction()
			_update_facing_from_aim(player, aim)
			projectile_pool.spawn(
				player.global_position + Vector2(0, -8),
				aim,
				spell,
				player
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


func play_cast_fail_sfx(position: Vector2) -> void:
	AudioManager.play_sfx(CAST_FAIL_SFX, position)


func play_impact_sfx(spell: SpellData, position: Vector2) -> void:
	if spell.impact_sfx:
		AudioManager.play_sfx_stream(spell.impact_sfx, position)


func blink_player(player: Player, direction: Vector2, distance: float) -> void:
	var mods := InventorySystem.get_aggregated_modifiers()
	var iframe_bonus := int(mods.get("veil_step_iframes_flat", 0))
	var iframe_duration := 0.14 + float(iframe_bonus) / 60.0
	var travel_direction := direction.normalized()
	var departure_position := player.global_position
	var arrival_position := departure_position + travel_direction * distance
	player.set_invulnerable(true)
	player.set_phasing(true)
	_spawn_arc_step_vfx(player, departure_position, travel_direction)
	_spawn_arc_step_afterimage(player)
	player.global_position = arrival_position
	player.velocity = travel_direction * Player.DASH_SPEED
	_spawn_arc_step_vfx(player, arrival_position, travel_direction)
	_animate_arc_step_arrival(player)
	player.get_tree().create_timer(iframe_duration).timeout.connect(func() -> void:
		if is_instance_valid(player):
			player.set_invulnerable(false)
			player.set_phasing(false)
	, CONNECT_ONE_SHOT)


func _spawn_arc_step_vfx(
	player: Player,
	world_position: Vector2,
	direction: Vector2
) -> void:
	var parent := player.get_parent()
	if parent == null:
		return
	var vfx := AnimatedSprite2D.new()
	vfx.sprite_frames = ARC_STEP_VFX
	parent.add_child(vfx)
	vfx.global_position = world_position + Vector2(0, -12)
	vfx.rotation = direction.angle()
	vfx.z_index = 50
	vfx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var glow_material := CanvasItemMaterial.new()
	glow_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	vfx.material = glow_material
	vfx.play(&"effect")
	vfx.animation_finished.connect(vfx.queue_free, CONNECT_ONE_SHOT)


func _spawn_arc_step_afterimage(player: Player) -> void:
	var parent := player.get_parent()
	var source := player.animated_sprite
	if parent == null or source.sprite_frames == null:
		return
	var texture := source.sprite_frames.get_frame_texture(source.animation, source.frame)
	if texture == null:
		return
	var afterimage := Sprite2D.new()
	afterimage.texture = texture
	afterimage.flip_h = source.flip_h
	afterimage.flip_v = source.flip_v
	afterimage.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	afterimage.modulate = ARC_STEP_COLOR
	afterimage.z_index = 49
	parent.add_child(afterimage)
	afterimage.global_transform = source.global_transform
	var tween := afterimage.create_tween()
	tween.set_parallel(true)
	tween.tween_property(afterimage, "modulate:a", 0.0, 0.14).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(
		afterimage,
		"scale",
		afterimage.scale * Vector2(1.15, 0.9),
		0.14
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_callback(afterimage.queue_free)


func _animate_arc_step_arrival(player: Player) -> void:
	var sprite := player.animated_sprite
	sprite.scale = Vector2(0.18, 1.08)
	sprite.modulate.a = 0.0
	var tween := sprite.create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


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
	var visual := Sprite2D.new()
	visual.texture = ROOTBIND_PLATFORM_TEXTURE
	visual.position = Vector2(32, 11)
	visual.scale = Vector2(64.0 / 1983.0, 56.0 / 1983.0)
	visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(visual)
	body.global_position = player.global_position + Vector2(-32, -88)
	player.get_parent().add_child(body)


func _update_facing_from_aim(player: Player, aim: Vector2) -> void:
	if absf(aim.x) <= 0.1:
		return
	player.facing_direction = 1 if aim.x > 0.0 else -1
	player.animated_sprite.flip_h = player.facing_direction < 0


func _notify_nearby_gates(player: Player, spell_id: StringName) -> void:
	for gate in player.get_tree().get_nodes_in_group(&"ability_gates"):
		if gate.has_method(&"on_hit_by_spell"):
			gate.on_hit_by_spell(spell_id, melee_hitbox)
