extends Control
## Hollow Knight-style centered region title — fade in, hold, fade out.


const COLOR_TITLE := Color(0.929, 0.878, 0.784, 1.0)
const COLOR_SUBTITLE := Color(0.749, 0.718, 0.647, 0.9)
const COLOR_LINE := Color(0.929, 0.878, 0.784, 0.45)

const FADE_IN_SEC := 0.55
const HOLD_SEC := 1.4
const FADE_OUT_SEC := 0.55
const DRIFT_PX := -14.0

@onready var title_label: Label = $Center/VBox/TitleRow/TitleLabel
@onready var subtitle_label: Label = $Center/VBox/SubtitleLabel
@onready var left_line: ColorRect = $Center/VBox/TitleRow/LeftLine
@onready var right_line: ColorRect = $Center/VBox/TitleRow/RightLine

var _tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	modulate.a = 0.0
	visible = false
	subtitle_label.visible = false


func show_title(title: String, subtitle: String = "") -> void:
	if title.is_empty():
		return
	if _tween and _tween.is_valid():
		_tween.kill()

	title_label.text = title
	if subtitle.is_empty():
		subtitle_label.visible = false
	else:
		subtitle_label.text = subtitle
		subtitle_label.visible = true

	visible = true
	modulate.a = 0.0
	position.y = 0.0

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, FADE_IN_SEC)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(
		self, "position:y", DRIFT_PX, FADE_IN_SEC + HOLD_SEC + FADE_OUT_SEC
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.set_parallel(false)
	_tween.tween_interval(HOLD_SEC)
	_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT_SEC)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_callback(_finish)


func _finish() -> void:
	visible = false
	position.y = 0.0
