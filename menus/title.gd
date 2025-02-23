extends Node2D

var game_path := "res://levels/arena03/arena_03.tscn"
var settings_path := "res://menus/settings.tscn"
var credits_path := "res://menus/credits.tscn"
var quit_path := "res://menus/quit.tscn"


func _ready() -> void:
	_load_audio_preferences()
	AudioPlayer.play_music()


func _load_audio_preferences():	
	AudioPlayer.update_volume(0, Prefs.master_volume)
	AudioPlayer.update_volume(1, Prefs.music_volume)
	AudioPlayer.update_volume(2, Prefs.sfx_volume)

func _on_play_pressed() -> void:
	Buff.reset_buffs()
	Game.current_weapon = 0
	Waves.current_wave = 1
	Waves.set_level()


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file(settings_path)


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file(credits_path)


func _on_quit_pressed() -> void:
	if (
		OS.get_name() == "Web"
		or OS.has_feature("JavaScript")
		or OS.has_feature("web_android")
		or OS.has_feature("web_ios")
	):
		get_tree().change_scene_to_file(quit_path)
	else:
		get_tree().quit()
