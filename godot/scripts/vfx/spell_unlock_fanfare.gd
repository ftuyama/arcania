class_name SpellUnlockFanfare
extends RefCounted
## One-shot VFX, SFX, and camera feedback for major spell unlocks.


const VEIL_STEP_VFX := preload("res://assets/sprites/vfx/spells/vfx_veil_step.tres")


static func play(spell_id: StringName, world_pos: Vector2, player: Player) -> void:
	var spell := SpellManager.get_spell(spell_id)
	if spell == null:
		return
	_spawn_vfx(spell_id, world_pos, player)
	_play_audio(spell, world_pos)
	_nudge_camera(player)
	var message := "%s acquired" % spell.display_name
	if spell_id == &"veil_step":
		message = "Veil Step acquired — Shift to dash through danger"
	EventBus.ui_toast.emit(message)


static func _spawn_vfx(spell_id: StringName, world_pos: Vector2, player: Player) -> void:
	var parent := player.get_parent()
	if parent == null:
		return
	var vfx := AnimatedSprite2D.new()
	vfx.sprite_frames = VEIL_STEP_VFX if spell_id == &"veil_step" else null
	if vfx.sprite_frames == null:
		return
	vfx.global_position = world_pos
	vfx.z_index = 50
	parent.add_child(vfx)
	vfx.play(&"effect")
	vfx.animation_finished.connect(vfx.queue_free, CONNECT_ONE_SHOT)


static func _play_audio(spell: SpellData, world_pos: Vector2) -> void:
	if spell.cast_sfx:
		AudioManager.play_sfx_stream(spell.cast_sfx, world_pos)
	if spell.impact_sfx:
		AudioManager.play_sfx_stream(spell.impact_sfx, world_pos)
	AudioManager.play_ui("res://assets/audio/sfx/spells/sfx_veil_step_impact.wav")


static func _nudge_camera(player: Player) -> void:
	if player.camera == null:
		return
	var cam := player.camera
	var base_offset := cam.offset
	var tween := player.create_tween()
	tween.tween_property(cam, "offset", base_offset + Vector2(4, -3), 0.04)
	tween.tween_property(cam, "offset", base_offset + Vector2(-3, 2), 0.04)
	tween.tween_property(cam, "offset", base_offset, 0.06)
