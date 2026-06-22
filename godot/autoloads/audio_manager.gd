extends Node
## Music crossfade, ambient loops, and pooled SFX playback.

const CROSSFADE_SEC := 1.5
const MAX_SFX_PLAYERS := 24

const GAME_OVER_MUSIC := "res://assets/audio/music/mus_game_over.wav"
const GAME_OVER_STINGER := "res://assets/audio/sfx/ui/sfx_game_over.wav"

var _music_player: AudioStreamPlayer
var _music_fade_player: AudioStreamPlayer
var _ambience_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer2D] = []
var _sfx_pool_index: int = 0
var _ui_player: AudioStreamPlayer
var _current_region: StringName = &""
var _current_music_path: String = ""
var _current_ambience_path: String = ""
var _music_should_loop: bool = true
var _music_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player = _make_bus_player(&"Music")
	_music_fade_player = _make_bus_player(&"Music")
	_ambience_player = _make_bus_player(&"Ambience")
	_ui_player = _make_bus_player(&"UI")

	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer2D.new()
		player.bus = &"SFX"
		player.max_polyphony = 1
		add_child(player)
		_sfx_players.append(player)

	EventBus.room_entered.connect(_on_room_entered)
	EventBus.boss_phase_changed.connect(_on_boss_phase_changed)
	EventBus.game_over_started.connect(_on_game_over_started)
	_music_player.finished.connect(_on_music_finished)
	call_deferred(&"_apply_saved_settings")


func _apply_saved_settings() -> void:
	apply_settings(GameManager.get_settings_snapshot())


func _exit_tree() -> void:
	EventBus.room_entered.disconnect(_on_room_entered)
	EventBus.boss_phase_changed.disconnect(_on_boss_phase_changed)
	EventBus.game_over_started.disconnect(_on_game_over_started)
	if _music_player.finished.is_connected(_on_music_finished):
		_music_player.finished.disconnect(_on_music_finished)


## Call when leaving the title screen so the first gameplay room always starts region audio.
func enter_gameplay() -> void:
	_current_region = &""


func play_region(region_id: StringName) -> void:
	var audio: Dictionary = RegionBackdrop.get_region_audio(region_id)
	if audio.is_empty():
		return

	var music_path: String = audio.get("music", "")
	var ambience_path: String = audio.get("ambience", "")
	var region_changed := region_id != _current_region
	_current_region = region_id

	if not music_path.is_empty():
		if region_changed or music_path != _current_music_path or not _music_player.playing:
			play_music(music_path)
		else:
			_ensure_music_audible()

	if not ambience_path.is_empty():
		if region_changed or ambience_path != _current_ambience_path or not _ambience_player.playing:
			play_ambience(ambience_path)


func play_music(stream_path: String, should_loop: bool = true) -> void:
	var stream := load(stream_path) as AudioStream
	if stream == null:
		push_error("AudioManager: missing music %s" % stream_path)
		return
	_music_should_loop = should_loop
	_crossfade_music(stream, stream_path)


func play_ambience(stream_path: String) -> void:
	var stream := load(stream_path) as AudioStream
	if stream == null:
		push_error("AudioManager: missing ambience %s" % stream_path)
		return
	if stream_path == _current_ambience_path and _ambience_player.playing:
		return
	_current_ambience_path = stream_path
	_ambience_player.stream = stream
	_ambience_player.play()


func play_sfx(stream_path: String, position: Vector2 = Vector2.ZERO) -> void:
	var stream := load(stream_path) as AudioStream
	if stream == null:
		push_error("AudioManager: missing sfx %s" % stream_path)
		return
	play_sfx_stream(stream, position)


func play_sfx_stream(stream: AudioStream, position: Vector2 = Vector2.ZERO) -> void:
	if stream == null:
		return
	var player := _sfx_players[_sfx_pool_index]
	_sfx_pool_index = (_sfx_pool_index + 1) % MAX_SFX_PLAYERS
	player.stream = stream
	player.global_position = position
	player.play()


func play_ui(stream_path: String) -> void:
	var stream := load(stream_path) as AudioStream
	if stream == null:
		return
	_ui_player.stream = stream
	_ui_player.play()


func play_footstep(surface: StringName, position: Vector2, variant: int = -1) -> void:
	var index := variant if variant > 0 else randi_range(1, 4)
	var path := "res://assets/audio/sfx/footsteps/sfx_footstep_%s_%d.wav" % [surface, index]
	play_sfx(path, position)


func play_stinger(stream_path: String) -> void:
	play_music(stream_path, false)


func play_game_over() -> void:
	_ambience_player.stop()
	_current_ambience_path = ""
	play_ui(GAME_OVER_STINGER)
	play_music(GAME_OVER_MUSIC)


func restore_region_music(region_id: StringName = &"") -> void:
	var target := region_id if not region_id.is_empty() else _current_region
	if target.is_empty():
		return
	play_region(target)


func _on_room_entered(_room_id: StringName, region_id: StringName) -> void:
	play_region(region_id)


func _on_boss_phase_changed(boss_id: StringName, phase: int) -> void:
	var path := ""
	match boss_id:
		&"mb_01_thornweft_matron":
			path = "res://assets/audio/music/mus_02_whisperwood.wav"
		&"boss_01_root_warden":
			path = "res://assets/audio/music/mus_02_whisperwood.wav"
	if path.is_empty():
		return
	if phase >= 1:
		play_music(path, true)
		_music_player.pitch_scale = 1.0 + float(phase) * 0.04
	else:
		_music_player.pitch_scale = 1.0


func apply_settings(settings: Dictionary) -> void:
	var master := float(settings.get("master_volume", 1.0))
	var music := float(settings.get("music_volume", 1.0))
	var sfx := float(settings.get("sfx_volume", 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Master"), linear_to_db(master))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"Music"), linear_to_db(music) - 4.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(&"SFX"), linear_to_db(sfx))


func _on_game_over_started() -> void:
	play_game_over()


func _on_music_finished() -> void:
	if _music_should_loop and not _current_music_path.is_empty():
		_music_player.play()


func _ensure_music_audible() -> void:
	_music_player.volume_db = 0.0
	if not _music_player.playing:
		_music_player.play()


func _crossfade_music(new_stream: AudioStream, stream_path: String) -> void:
	if (
		stream_path == _current_music_path
		and _music_player.playing
		and _music_player.volume_db > -6.0
	):
		return

	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()

	var crossfade := (
		_music_player.playing
		and _music_player.stream != null
		and stream_path != _current_music_path
	)

	if crossfade:
		_music_fade_player.stream = _music_player.stream
		_music_fade_player.volume_db = _music_player.volume_db
		_music_fade_player.play(_music_player.get_playback_position())

	_music_player.stream = new_stream
	_current_music_path = stream_path

	if crossfade:
		_music_player.volume_db = -40.0
	else:
		_music_player.volume_db = 0.0
	_music_player.play()

	if not crossfade:
		_music_fade_player.stop()
		return

	_music_tween = create_tween()
	_music_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_music_tween.set_parallel(true)
	_music_tween.tween_property(_music_player, "volume_db", 0.0, CROSSFADE_SEC)
	_music_tween.tween_property(_music_fade_player, "volume_db", -40.0, CROSSFADE_SEC)
	_music_tween.chain().tween_callback(_music_fade_player.stop)


func _make_bus_player(bus_name: StringName) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus_name
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	return player
