extends Area2D
## Interactable NPC that triggers dialogue.


@export var npc_id: StringName = &""
@export var display_name: String = "Stranger"
@export var dialogue_lines: PackedStringArray = PackedStringArray()
@export var one_shot: bool = true
@export var quest_to_start: StringName = &""
@export var sprite_frames: SpriteFrames

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _fallback_visual: ColorRect = $FallbackVisual
@onready var _prompt: Label = $Prompt


func _ready() -> void:
	add_to_group(&"npcs")
	collision_layer = 512
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_apply_visual()
	if one_shot and npc_id and GameManager.has_world_flag(StringName("talked_%s" % npc_id)):
		_prompt.visible = false
		return


func _apply_visual() -> void:
	if sprite_frames and _sprite:
		_sprite.sprite_frames = sprite_frames
		_sprite.play(&"idle")
		if _fallback_visual:
			_fallback_visual.visible = false
		return
	if _fallback_visual:
		_fallback_visual.visible = true
		_fallback_visual.color = Color(0.55, 0.48, 0.62, 1.0)
	if _sprite:
		_sprite.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _prompt.visible:
		return
	if not event.is_action_pressed(&"interact"):
		return
	if not _player_in_range():
		return
	_start_dialogue()
	get_viewport().set_input_as_handled()


func _player_in_range() -> bool:
	for body in get_overlapping_bodies():
		if body.is_in_group(&"player"):
			return true
	return false


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_prompt.visible = false


func _start_dialogue() -> void:
	var ui := get_tree().get_first_node_in_group(&"ui_layer")
	if ui == null:
		ui = get_tree().root.find_child("UILayer", true, false)
	if ui == null:
		return
	var dialogue: Control = ui.get_node_or_null("DialogueBox")
	if dialogue == null or not dialogue.has_method(&"start_dialogue"):
		return
	var lines: Array[String] = []
	for line in dialogue_lines:
		lines.append(String(line))
	dialogue.start_dialogue(display_name, lines)
	if not dialogue.dialogue_finished.is_connected(_on_dialogue_finished):
		dialogue.dialogue_finished.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)


func _on_dialogue_finished() -> void:
	if one_shot and npc_id:
		GameManager.set_world_flag(StringName("talked_%s" % npc_id))
		_prompt.visible = false
	if quest_to_start and not QuestManager.is_quest_complete(quest_to_start):
		QuestManager.start_quest(quest_to_start)
