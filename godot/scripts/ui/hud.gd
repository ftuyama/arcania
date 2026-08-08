extends CanvasLayer
## In-game HUD — corner clusters matching screenshot aesthetics + GDD §9.1 layout.


const COLOR_BOSS_FILL := Color(0.898, 0.22, 0.231, 1.0)

@onready var character_name: Label = $PlayerStatusCluster/InfoColumn/CharacterName
@onready var health_pips: HBoxContainer = $PlayerStatusCluster/InfoColumn/HealthPipRow
@onready var mana_segments: Control = $PlayerStatusCluster/InfoColumn/ManaSegmentBar
@onready var shard_count_label: Label = $PlayerStatusCluster/InfoColumn/ShardCounter/ShardCount
@onready var overcast_label: Label = $PlayerStatusCluster/InfoColumn/OvercastLabel
@onready var region_label: Label = $NavigationCluster/RegionRow/RegionLabel
@onready var minimap: Control = $NavigationCluster/MinimapWidget
@onready var quick_spell_bar: HBoxContainer = $SpellCluster/QuickSpellBar
@onready var spell_name_fade: Label = $SpellCluster/SpellNameFade
@onready var currency_bar: PanelContainer = $CurrencyBar
@onready var quest_label: Label = $QuestTracker/QuestLabel
@onready var boss_bar: ProgressBar = $BossBarContainer/BossHealthBar
@onready var boss_name_label: Label = $BossBarContainer/BossNameLabel
@onready var region_title: Control = $RegionNameToast
@onready var spell_toast: Control = $SpellToast
@onready var spell_icon: TextureRect = $SpellToast/SpellIcon
@onready var spell_name_label: Label = $SpellToast/SpellNameLabel
@onready var sigil_icon: TextureRect = $PlayerStatusCluster/SigilColumn/PortraitStack/SigilIcon

var _player: Player
var _active_boss: BaseBoss = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	_style_static_labels()
	_style_boss_bar()
	_load_sigil_icon()
	EventBus.player_spawned.connect(_on_player_spawned)
	EventBus.region_entered.connect(_on_region_entered)
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
	_refresh_region_label(GameManager.current_region_id)
	if currency_bar and currency_bar.has_method(&"refresh"):
		currency_bar.refresh()
	if minimap and minimap.has_method(&"refresh"):
		minimap.refresh()


func _exit_tree() -> void:
	_disconnect_if(EventBus.player_spawned, _on_player_spawned)
	_disconnect_if(EventBus.region_entered, _on_region_entered)
	_disconnect_if(EventBus.boss_fight_started, _on_boss_fight_started)
	_disconnect_if(EventBus.boss_defeated, _on_boss_defeated)
	_disconnect_if(EventBus.game_paused, _on_game_paused)
	_disconnect_if(EventBus.game_resumed, _on_game_resumed)
	_disconnect_if(EventBus.ui_toast, _on_ui_toast)
	_disconnect_if(EventBus.spell_acquired, _on_spell_acquired)
	_disconnect_if(EventBus.quest_started, _on_quest_changed)
	_disconnect_if(EventBus.quest_updated, _on_quest_changed)
	_disconnect_if(EventBus.quest_completed, _on_quest_changed)


func _process(_delta: float) -> void:
	if _active_boss and is_instance_valid(_active_boss):
		var hp := _active_boss.health_component
		boss_bar.max_value = float(hp.max_hp)
		boss_bar.value = float(hp.current_hp)


func _disconnect_if(sig: Signal, callable: Callable) -> void:
	if sig.is_connected(callable):
		sig.disconnect(callable)


func _style_static_labels() -> void:
	HudStyle.apply_hud_font(character_name, 12, &"semibold")
	character_name.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT)
	HudStyle.apply_hud_font(shard_count_label, 11)
	shard_count_label.add_theme_color_override(&"font_color", HudStyle.COLOR_EMBER)
	HudStyle.apply_hud_font(overcast_label, 10)
	overcast_label.add_theme_color_override(&"font_color", HudStyle.COLOR_HP_LOW)
	HudStyle.apply_hud_font(region_label, 11)
	region_label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT)
	HudStyle.apply_hud_font(quest_label, 10)
	quest_label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT_DIM)
	HudStyle.apply_hud_font(boss_name_label, 13, &"semibold")
	boss_name_label.add_theme_color_override(&"font_color", HudStyle.COLOR_TEXT)
	HudStyle.apply_hud_font(spell_name_label, 14)
	spell_name_label.add_theme_color_override(&"font_color", Color(0.78, 0.62, 0.95, 1))
	HudStyle.apply_hud_font(spell_name_fade, 12)
	spell_name_fade.add_theme_color_override(&"font_color", HudStyle.COLOR_EMBER)
	var toast: Label = $ToastLabel
	HudStyle.apply_hud_font(toast, 12)


func _style_boss_bar() -> void:
	var bg := HudStyle.make_bar_bg()
	bg.border_color = HudStyle.COLOR_BORDER_GOLD
	boss_bar.add_theme_stylebox_override(&"background", bg)
	boss_bar.add_theme_stylebox_override(&"fill", HudStyle.make_fill_style(COLOR_BOSS_FILL))


func _load_sigil_icon() -> void:
	var tex := load("res://assets/sprites/ui/icons/ui_spell_icon_ember_sigil.png") as Texture2D
	if tex and sigil_icon:
		sigil_icon.texture = tex


func _on_player_spawned(player: Node2D) -> void:
	if player is Player:
		_bind_player(player)


func _bind_player(player: Player) -> void:
	_player = player
	if not player.health_component.damaged.is_connected(_on_hp_changed):
		player.health_component.damaged.connect(_on_hp_changed)
	if not player.health_component.healed.is_connected(_on_hp_changed):
		player.health_component.healed.connect(_on_hp_changed)
	if not player.mana_component.mana_changed.is_connected(_on_mana_changed):
		player.mana_component.mana_changed.connect(_on_mana_changed)
	if not player.mana_component.overcast_used.is_connected(_on_overcast_used):
		player.mana_component.overcast_used.connect(_on_overcast_used)
	if not player.mana_component.focus_shards_changed.is_connected(_on_focus_shards_changed):
		player.mana_component.focus_shards_changed.connect(_on_focus_shards_changed)
	_on_hp_changed(0, null)
	_on_mana_changed(player.mana_component.current_mana, float(player.mana_component.max_mana))
	_on_focus_shards_changed(player.mana_component.focus_shard_count, ManaComponent.MAX_SHARDS)


func _on_hp_changed(amount: int = 0, _source: Node = null) -> void:
	if _player == null or health_pips == null:
		return
	var hp := _player.health_component
	if health_pips.has_method(&"update_health"):
		health_pips.update_health(hp.current_hp, hp.max_hp)
	if amount > 0 and health_pips.has_method(&"flash_damage"):
		health_pips.flash_damage()


func _on_mana_changed(current: float, maximum: float) -> void:
	if _player == null or mana_segments == null:
		return
	if mana_segments.has_method(&"update_mana"):
		mana_segments.update_mana(current, maximum, _player.mana_component.focus_shard_count)


func _on_focus_shards_changed(count: int, _max_shards: int) -> void:
	if shard_count_label:
		shard_count_label.text = str(count)
	if _player and mana_segments and mana_segments.has_method(&"update_mana"):
		mana_segments.update_mana(
			_player.mana_component.current_mana,
			float(_player.mana_component.max_mana),
			count
		)


func _on_overcast_used(hp_cost: int) -> void:
	overcast_label.text = "Overcast -%d HP" % hp_cost
	overcast_label.visible = true
	if mana_segments.has_method(&"set_overcast_visible"):
		mana_segments.set_overcast_visible(true)
	if mana_segments.has_method(&"flash_overcast"):
		mana_segments.flash_overcast()
	get_tree().create_timer(1.0).timeout.connect(func() -> void:
		if is_instance_valid(overcast_label):
			overcast_label.visible = false
		if is_instance_valid(mana_segments) and mana_segments.has_method(&"set_overcast_visible"):
			mana_segments.set_overcast_visible(false)
	, CONNECT_ONE_SHOT)


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
	if quick_spell_bar and quick_spell_bar.has_method(&"refresh"):
		quick_spell_bar.refresh()


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


func _on_region_entered(region_id: StringName) -> void:
	_refresh_region_label(region_id)
	if region_id == &"dev" or region_id.is_empty():
		return
	var region := MapManager.get_region(region_id)
	var title := region.display_name if region else _format_region_id(region_id)
	if title.is_empty():
		return
	if region_title.has_method(&"show_title"):
		region_title.show_title(title)


func _refresh_region_label(region_id: StringName) -> void:
	if region_label == null:
		return
	if region_id.is_empty() or region_id == &"dev":
		region_id = GameManager.current_region_id
	if region_id.is_empty():
		region_label.text = ""
		return
	var region := MapManager.get_region(region_id)
	region_label.text = region.display_name if region else _format_region_id(region_id)


func _format_region_id(region_id: StringName) -> String:
	return String(region_id).replace("_", " ").capitalize()
