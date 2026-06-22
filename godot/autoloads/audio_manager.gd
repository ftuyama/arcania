extends Node
## Music crossfade, ambient loops, and pooled SFX playback.

const CROSSFADE_SEC := 1.5
const MAX_SFX_PLAYERS := 24

const REGION_MUSIC: Dictionary = {
	&"ashen_threshold": "res://assets/audio/music/mus_01_threshold.wav",
	&"dev": "res://assets/audio/music/mus_01_threshold.wav",
	&"whisperwood_hollow": "res://assets/audio/music/mus_02_whisperwood.wav",
}

const GAME_OVER_MUSIC := "res://assets/audio/music/mus_game_over.wav"

const REGION_AMBIENCE: Dictionary = {
	&"ashen_threshold": "res://assets/audio/ambient/amb_01_threshold.wav",
	&"dev": "res://assets/audio/ambient/amb_01_threshold.wav",
	&"whisperwood_hollow": "res://assets/audio/ambient/amb_02_whisperwood.wav",
}

var _music_player: AudioStreamPlayer
var _music_fade_player: AudioStreamPlayer
var _ambience_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer2D] = []
var _sfx_pool_index: int = 0
var _ui_player: AudioStreamPlayer
var _current_region: StringName = &""
var _current_music_path: String = ""
var _music_should_loop: bool = true
var _music_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_music_player = _make_bus_player("Music")
	_music_fade_player = _make_bus_player("Music")
	_ambience_player = _make_bus_player("Ambience")
	_ui_player = _make_bus_player("UI")

	for i in MAX_SFX_PLAYERS:
		var player := AudioStreamPlayer2D.new()
		player.bus = &"SFX"
		player.max_polyphony = 1
		add_child(player)
		_sfx_players.append(player)

	EventBus.region_entered.connect(_on_region_entered)
	EventBus.room_entered.connect(_on_room_entered)
	EventBus.boss_phase_changed.connect(_on_boss_phase_changed)
	_music_player.finished.connect(_on_music_finished)


func _exit_tree() -> void:
	EventBus.region_entered.disconnect(_on_region_entered)
	EventBus.room_entered.disconnect(_on_room_entered)
	EventBus.boss_phase_changed.disconnect(_on_boss_phase_changed)
	if _music_player.finished.is_connected(_on_music_finished):
		_music_player.finished.disconnect(_on_music_finished)


func play_music(stream_path: String, should_loop: bool = true) -> void:
	var stream := _load_looping_stream(stream_path, should_loop)
	if stream == null:
		push_error("AudioManager: missing music %s" % stream_path)
		return
	_music_should_loop = should_loop
	_crossfade_music(stream, stream_path)


func play_ambience(stream_path: String) -> void:
	var stream := _load_looping_stream(stream_path, true)
	if stream == null:
		push_error("AudioManager: missing ambience %s" % stream_path)
		return
	if _ambience_player.stream == stream and _ambience_player.playing:
		return
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


func restore_region_music(region_id: StringName = &"") -> void:
	var target := region_id if not region_id.is_empty() else _current_region
	if target.is_empty() or not REGION_MUSIC.has(target):
		return
	play_music(REGION_MUSIC[target])


func _on_region_entered(region_id: StringName) -> void:
	if region_id == _current_region:
		return
	_current_region = region_id
	if REGION_MUSIC.has(region_id):
		play_music(REGION_MUSIC[region_id])
	if REGION_AMBIENCE.has(region_id):
		play_ambience(REGION_AMBIENCE[region_id])


func _on_room_entered(_room_id: StringName, region_id: StringName) -> void:
	_on_region_entered(region_id)


func _on_boss_phase_changed(_boss_id: StringName, _phase: int) -> void:
	pass


func _on_music_finished() -> void:
	if _music_should_loop and not _current_music_path.is_empty():
		_music_player.play()


func _load_looping_stream(stream_path: String, should_loop: bool) -> AudioStream:
	var stream := load(stream_path) as AudioStream
	if stream == null:
		return null
	stream = stream.duplicate()
	if stream is AudioStreamOggVorbis:
		stream.loop = should_loop
	elif stream is AudioStreamWAV:
		stream.loop_mode = (
			AudioStreamWAV.LOOP_FORWARD if should_loop else AudioStreamWAV.LOOP_DISABLED
		)
	return stream


func _crossfade_music(new_stream: AudioStream, stream_path: String) -> void:
	var same_track := stream_path == _current_music_path and _music_player.playing
	if same_track and _music_player.volume_db > -6.0:
		return

	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()

	var was_playing := _music_player.playing and _music_player.stream != null
	if same_track:
		_music_player.volume_db = 0.0
		return

	if was_playing:
		_music_fade_player.stream = _music_player.stream
		_music_fade_player.volume_db = _music_player.volume_db
		_music_fade_player.play(_music_player.get_playback_position())

	_music_player.stream = new_stream
	_current_music_path = stream_path
	if was_playing:
		_music_player.volume_db = -40.0
	else:
		_music_player.volume_db = 0.0
	_music_player.play()

	if not was_playing:
		_music_fade_player.stop()
		return

	_music_tween = create_tween()
	_music_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_music_tween.set_parallel(true)
	_music_tween.tween_property(_music_player, "volume_db", 0.0, CROSSFADE_SEC)
	_music_tween.tween_property(_music_fade_player, "volume_db", -40.0, CROSSFADE_SEC)
	_music_tween.chain().tween_callback(_music_fade_player.stop)


func _make_bus_player(bus_name: String) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.bus = bus_name
	player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(player)
	return player
