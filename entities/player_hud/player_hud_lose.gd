extends CanvasLayer

var title_path = "res://menus/title.tscn"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED


func _on_wave_again_pressed() -> void:
	Game.reload()
	get_tree().reload_current_scene()


func _on_title_pressed() -> void:
	Waves.current_wave = 1
	get_tree().change_scene_to_file(title_path)
