class_name GateFailureFeedback
extends RefCounted
## UI hints when the player casts the wrong spell on an ability gate.


const COOLDOWN_SEC := 2.5

static var _last_emit_msec: int = -999999


static func try_emit(
	cast_spell_id: StringName,
	required_spell: StringName,
	gate_type: StringName = &"",
	custom_hint: String = ""
) -> void:
	if cast_spell_id.is_empty() or cast_spell_id == required_spell:
		return
	if not SpellManager.has_spell(cast_spell_id):
		return
	var now := Time.get_ticks_msec()
	if now - _last_emit_msec < int(COOLDOWN_SEC * 1000.0):
		return
	var message := custom_hint if not custom_hint.is_empty() else build_hint(required_spell, gate_type)
	if message.is_empty():
		return
	_last_emit_msec = now
	EventBus.ui_toast.emit(message)


static func build_hint(required_spell: StringName, gate_type: StringName = &"") -> String:
	if gate_type == &"ember_receptor":
		return "Ember receptor — ignite with Ember Sigil or Ember Bolt"
	match required_spell:
		&"ember_sigil":
			return "Requires Ember Sigil — channel fire into the obstacle"
		&"rootbind":
			return "Vines resist this — reshape them with Rootbind"
		&"arc_step":
			return "Phase barrier — slip through with Arc Step"
		&"veil_step":
			return "Barrier holds — Veil Step can dash past thin walls"
		_:
			var spell := SpellManager.get_spell(required_spell)
			if spell and not spell.display_name.is_empty():
				return "This barrier needs %s" % spell.display_name
			return "This spell won't open the way — try another"
