extends Node2D

var title_path := "res://menus/title.tscn"

func _on_return_pressed() -> void:	
	get_tree().change_scene_to_file(title_path)
