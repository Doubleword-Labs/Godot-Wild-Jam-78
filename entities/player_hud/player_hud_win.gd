extends CanvasLayer

var title_path = "res://menus/title.tscn"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$ColorRect2/Label.text = "Wave " + str(Waves.current_wave) + "!"


func _on_wave_again_pressed() -> void:
	Game.reload()
	if (Waves.current_wave - 1) % 4 == 3:
		Waves.shop_time = true

	Waves.current_wave += 1

	if Waves.shop_time:
		Waves.set_shop()
	else:
		Waves.set_level()


func _on_title_pressed() -> void:
	Waves.current_wave = 1
	get_tree().change_scene_to_file(title_path)
