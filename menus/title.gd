extends Node2D

var game_path := "res://levels/arena03/arena_03.tscn"
var settings_path := "res://menus/settings.tscn"
var credits_path := "res://menus/credits.tscn"

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(game_path)


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file(settings_path)


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file(credits_path)
	
	
func _on_quit_pressed() -> void:
	get_tree().quit()
