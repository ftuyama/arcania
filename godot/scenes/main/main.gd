extends Node
## Boot scene — loads the title screen.


const TITLE_SCENE := "res://scenes/ui/title_screen.tscn"


func _ready() -> void:
	get_tree().change_scene_to_file(TITLE_SCENE)
