extends CanvasLayer
## HP bar, mana bar, essence counter, and boss health bar.


const COLOR_HP_FILL := Color(1.0, 0.867, 0.824, 1.0)
const COLOR_HP_LOW := Color(0.898, 0.22, 0.231, 1.0)
const COLOR_MANA_FILL := Color(0.0, 1.0, 1.0, 1.0)
const COLOR_BAR_BG := Color(0.102, 0.102, 0.18, 0.85)
const COLOR_BAR_BORDER := Color(0.173, 0.173, 0.204, 1.0)
const COLOR_BAR_BORDER_GOLD := Color(0.55, 0.38, 0.14, 0.75)
const COLOR_BOSS_FILL := Color(0.898, 0.22, 0.231, 1.0)

const BAR_HEIGHT := 12
const BAR_FILL_INSET := 2
const BAR_CORNER := 2
const TWEEN_DURATION := 0.18

@onready var hp_bar: ProgressBar = $MarginContainer/VBox/HPRow/HPBar
@onready var mana_bar: ProgressBar = $MarginContainer/VBox/ManaRow/ManaBarWrap/ManaBar
@onready var overcast_bleed: ColorRect = $MarginContainer/VBox/ManaRow/ManaBarWrap/OvercastBleed
@onready var essence_label: Label = $MarginContainer/VBox/EssenceLabel
@onready var overcast_label: Label = $MarginContainer/VBox/OvercastLabel
@onready var quest_label: Label = $QuestTracker/QuestLabel
@onready var boss_bar: ProgressBar = $BossBarContainer/BossHealthBar
@onready var boss_name_label: Label = $BossBarContainer/BossNameLabel
@onready var region_title: Control = $RegionNameToast
@onready var spell_toast: Control = $SpellToast
@onready var spell_icon: TextureRect = $SpellToast/SpellIcon
@onready var spell_name_label: Label = $SpellToast/SpellNameLabel

var _player: Player
var _active_boss: BaseBoss = null
var _hp_tween: Tween
var _mana_tween: Tween
var _hp_fill_style: StyleBoxFlat
var _mana_fill_style: StyleBoxFlat
var _shard_row: HBoxContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	_style_hud_bars()
	_build_shard_row()
	EventBus.player_spawned.connect(_on_player_spawned)
	EventBus.region_entered.connect(_on_region_entered)
	EventBus.enemy_defeated.connect(_on_enemy_defeated)
	EventBus.boss_fight_started.connect(_on_boss_fight_started)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.game_paused.connect(_on_game_paused)
	EventBus.game_resumed.connect(_on_game_resumed)
	EventBus.ui_toast.connect(_on_ui_toast)
	EventBus.spell_acquired.connect(_on_spell_acquired)
	EventBus.quest_started.connect(_on_quest_changed)
	EventBus.quest_updated.connect(_on_quest_changed)
	EventBus.quest_completed.connect(_on_quest_changed)
	_player = get_tree().get_first_node_in_group(&"player") as Player
	if _player:
		_bind_player(_player)
	_hide_boss_bar()
	_update_quest_tracker()


func _exit_tree() -> void:
	if EventBus.player_spawned.is_connected(_on_player_spawned):
		EventBus.player_spawned.disconnect(_on_player_spawned)
	if EventBus.enemy_defeated.is_connected(_on_enemy_defeated):
		EventBus.enemy_defeated.disconnect(_on_enemy_defeated)
	if EventBus.boss_fight_started.is_connected(_on_boss_fight_started):
		EventBus.boss_fight_started.disconnect(_on_boss_fight_started)
	if EventBus.boss_defeated.is_connected(_on_boss_defeated):
		EventBus.boss_defeated.disconnect(_on_boss_defeated)
	if EventBus.game_paused.is_connected(_on_game_paused):
		EventBus.game_paused.disconnect(_on_game_paused)
	if EventBus.game_resumed.is_connected(_on_game_resumed):
		EventBus.game_resumed.disconnect(_on_game_resumed)
	if EventBus.ui_toast.is_connected(_on_ui_toast):
		EventBus.ui_toast.disconnect(_on_ui_toast)
	if EventBus.spell_acquired.is_connected(_on_spell_acquired):
		EventBus.spell_acquired.disconnect(_on_spell_acquired)
	if EventBus.quest_started.is_connected(_on_quest_changed):
		EventBus.quest_started.disconnect(_on_quest_changed)
	if EventBus.quest_updated.is_connected(_on_quest_changed):
		EventBus.quest_updated.disconnect(_on_quest_changed)
	if EventBus.quest_completed.is_connected(_on_quest_changed):
		EventBus.quest_completed.disconnect(_on_quest_changed)
	if EventBus.region_entered.is_connected(_on_region_entered):
		EventBus.region_entered.disconnect(_on_region_entered)


func _process(_delta: float) -> void:
	if _active_boss and is_instance_valid(_active_boss):
		var hp := _active_boss.health_component
		boss_bar.max_value = float(hp.max_hp)
		boss_bar.value = float(hp.current_hp)


func _style_hud_bars() -> void:
	_hp_fill_style = _make_fill_style(COLOR_HP_FILL)
	_mana_fill_style = _make_fill_style(COLOR_MANA_FILL)
	_apply_bar_theme(hp_bar, _hp_fill_style, COLOR_BAR_BORDER_GOLD)
	_apply_bar_theme(mana_bar, _mana_fill_style, COLOR_BAR_BORDER)
	_apply_bar_theme(boss_bar, _make_fill_style(COLOR_BOSS_FILL), COLOR_BAR_BORDER_GOLD)


func _make_bg_style() -> StyleBoxFlat:
	var bg := StyleBoxFlat.new()
	bg.bg_color = COLOR_BAR_BG
	bg.border_color = COLOR_BAR_BORDER
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(BAR_CORNER)
	bg.content_margin_left = BAR_FILL_INSET
	bg.content_margin_top = BAR_FILL_INSET
	bg.content_margin_right = BAR_FILL_INSET
	bg.content_margin_bottom = BAR_FILL_INSET
	return bg


func _make_fill_style(fill_color: Color) -> StyleBoxFlat:
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(1)
	return fill


func _apply_bar_theme(bar: ProgressBar, fill_style: StyleBoxFlat, border_color: Color) -> void:
	var bg := _make_bg_style()
	bg.border_color = border_color
	bar.add_theme_stylebox_override(&"background", bg)
	bar.add_theme_stylebox_override(&"fill", fill_style.duplicate())


func _on_player_spawned(player: Node2D) -> void:
	if player is Player:
		_bind_player(player)


func _on_enemy_defeated(_enemy_id: StringName, _position: Vector2) -> void:
	_update_essence()


func _bind_player(player: Player) -> void:
	_player = player
	player.health_component.damaged.connect(_on_hp_changed)
	player.health_component.healed.connect(_on_hp_changed)
	player.mana_component.mana_changed.connect(_on_mana_changed)
	player.mana_component.overcast_used.connect(_on_overcast_used)
	player.mana_component.focus_shards_changed.connect(_on_focus_shards_changed)
	_on_hp_changed(0, null)
	_on_mana_changed(player.mana_component.current_mana, float(player.mana_component.max_mana))
	_on_focus_shards_changed(player.mana_component.focus_shard_count, ManaComponent.MAX_SHARDS)
	_update_essence()


func _on_hp_changed(amount: int = 0, _source: Node = null) -> void:
	if _player == null:
		return
	var hp := _player.health_component
	hp_bar.max_value = float(hp.max_hp)
	_tween_bar(hp_bar, float(hp.current_hp), _hp_tween, &"_hp_tween")
	_update_hp_fill_color(hp.current_hp, hp.max_hp)
	if amount > 0:
		_flash_bar(hp_bar, COLOR_HP_LOW)


func _on_mana_changed(current: float, maximum: float) -> void:
	mana_bar.max_value = maximum
	_tween_bar(mana_bar, current, _mana_tween, &"_mana_tween")


func _tween_bar(bar: ProgressBar, target: float, tween_ref: Tween, tween_name: StringName) -> void:
	if tween_ref and tween_ref.is_valid():
		tween_ref.kill()
	var tween := create_tween()
	set(tween_name, tween)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(bar, "value", target, TWEEN_DURATION)


func _update_hp_fill_color(current_hp: int, max_hp: int) -> void:
	var ratio := float(current_hp) / float(maxi(max_hp, 1))
	var fill_color := COLOR_HP_FILL.lerp(COLOR_HP_LOW, 1.0 - clampf(ratio * 2.0, 0.0, 1.0))
	_hp_fill_style.bg_color = fill_color
	hp_bar.add_theme_stylebox_override(&"fill", _hp_fill_style)


func _flash_bar(bar: ProgressBar, flash_color: Color) -> void:
	var tween := create_tween()
	tween.tween_property(bar, "modulate", flash_color, 0.06)
	tween.tween_property(bar, "modulate", Color.WHITE, 0.14)


func _on_overcast_used(hp_cost: int) -> void:
	overcast_label.text = "Overcast -%d HP" % hp_cost
	overcast_label.visible = true
	overcast_bleed.visible = true
	_flash_bar(mana_bar, COLOR_HP_LOW)
	var tween := create_tween()
	tween.tween_property(overcast_bleed, "modulate:a", 1.0, 0.08)
	tween.tween_property(overcast_bleed, "modulate:a", 0.35, 0.4)
	get_tree().create_timer(1.0).timeout.connect(func() -> void:
		if is_instance_valid(overcast_label):
			overcast_label.visible = false
		if is_instance_valid(overcast_bleed):
			overcast_bleed.visible = false
			overcast_bleed.modulate.a = 1.0
	, CONNECT_ONE_SHOT)


func _update_essence() -> void:
	if _player:
		essence_label.text = "Essence: %d" % _player.essence_collected


func _on_boss_fight_started(boss_id: StringName) -> void:
	for boss in get_tree().get_nodes_in_group(&"bosses"):
		if boss is BaseBoss and boss.data and boss.data.id == boss_id:
			_active_boss = boss
			boss_name_label.text = boss.data.display_name
			boss_bar.max_value = float(boss.health_component.max_hp)
			boss_bar.value = float(boss.health_component.current_hp)
			$BossBarContainer.visible = true
			return


func _on_boss_defeated(_boss_id: StringName) -> void:
	_active_boss = null
	get_tree().create_timer(1.5).timeout.connect(_hide_boss_bar, CONNECT_ONE_SHOT)


func _hide_boss_bar() -> void:
	$BossBarContainer.visible = false


func _on_game_paused() -> void:
	$PauseOverlay.visible = true


func _on_game_resumed() -> void:
	$PauseOverlay.visible = false


func _on_ui_toast(message: String) -> void:
	$ToastLabel.text = message
	$ToastLabel.visible = true
	get_tree().create_timer(2.0).timeout.connect(func() -> void:
		if is_instance_valid(self):
			$ToastLabel.visible = false
	, CONNECT_ONE_SHOT)


func _on_spell_acquired(spell_id: StringName) -> void:
	var spell := SpellManager.get_spell(spell_id)
	if spell == null:
		return
	spell_name_label.text = spell.display_name
	if spell.icon:
		spell_icon.texture = spell.icon
	spell_toast.visible = true
	spell_toast.modulate = Color.WHITE
	var tween := create_tween()
	tween.tween_property(spell_toast, "modulate:a", 1.0, 0.12)
	get_tree().create_timer(2.5).timeout.connect(func() -> void:
		if not is_instance_valid(self):
			return
		var fade := create_tween()
		fade.tween_property(spell_toast, "modulate:a", 0.0, 0.25)
		fade.tween_callback(func() -> void:
			if is_instance_valid(spell_toast):
				spell_toast.visible = false
				spell_toast.modulate = Color.WHITE
		)
	, CONNECT_ONE_SHOT)


func _on_quest_changed(_a = null, _b = null) -> void:
	_update_quest_tracker()


func _update_quest_tracker() -> void:
	var active := QuestManager.get_active_quests()
	if active.is_empty():
		quest_label.text = ""
		return
	var quest := QuestManager.get_quest(active[0])
	if quest == null:
		return
	quest_label.text = "%s: %s" % [quest.title, QuestManager.get_active_objective_text(active[0])]


func _build_shard_row() -> void:
	var mana_row := $MarginContainer/VBox/ManaRow
	_shard_row = HBoxContainer.new()
	_shard_row.name = "ShardRow"
	_shard_row.add_theme_constant_override(&"separation", 2)
	mana_row.add_child(_shard_row)
	mana_row.move_child(_shard_row, 0)


func _on_focus_shards_changed(count: int, max_shards: int) -> void:
	if _shard_row == null:
		return
	for child in _shard_row.get_children():
		child.queue_free()
	for i in max_shards:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(8, 8)
		pip.color = Color(0.0, 0.85, 0.95, 0.95) if i < count else Color(0.15, 0.15, 0.2, 0.8)
		_shard_row.add_child(pip)


func _on_region_entered(region_id: StringName) -> void:
	if region_id == &"dev" or region_id.is_empty():
		return
	var region := MapManager.get_region(region_id)
	var title := region.display_name if region else _format_region_id(region_id)
	if title.is_empty():
		return
	if region_title.has_method(&"show_title"):
		region_title.show_title(title)


func _format_region_id(region_id: StringName) -> String:
	return String(region_id).replace("_", " ").capitalize()
