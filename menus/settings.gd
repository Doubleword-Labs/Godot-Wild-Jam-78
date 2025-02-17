extends Node2D

var title_path := "res://menus/title.tscn"

@onready var master_volume = $SoundSettings/Master/MasterVolume
@onready var music_volume = $SoundSettings/Music/MusicVolume
@onready var sfx_volume = $SoundSettings/SFX/SFXVolume


func _ready() -> void:
	master_volume.value = AudioPlayer.default_volumes[0]
	music_volume.value = AudioPlayer.default_volumes[1]
	sfx_volume.value = AudioPlayer.default_volumes[2]

func _on_return_pressed() -> void:	
	get_tree().change_scene_to_file(title_path)


func _on_master_volume_value_changed(value: float) -> void:
	AudioPlayer.update_volume(0, value)


func _on_music_volume_value_changed(value: float) -> void:
	AudioPlayer.update_volume(1, value)


func _on_sfx_volume_value_changed(value: float) -> void:
	AudioPlayer.update_volume(2, value)
