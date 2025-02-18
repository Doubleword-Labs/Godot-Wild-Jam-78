extends CanvasLayer

var title_path = "res://menus/title.tscn"


func _ready() -> void:	
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_wave_again_pressed() -> void:
	Game.reload()
	get_tree().reload_current_scene()
	#get_tree().change_scene_to_file(Game.current_level)


func _on_title_pressed() -> void:
	Game.reload()
	get_tree().change_scene_to_file(title_path)
