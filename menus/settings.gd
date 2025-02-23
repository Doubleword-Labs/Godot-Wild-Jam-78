extends Node2D

var title_path := "res://menus/title.tscn"

@onready var master_volume = $SoundSettings/Master/MasterVolume
@onready var music_volume = $SoundSettings/Music/MusicVolume
@onready var sfx_volume = $SoundSettings/SFX/SFXVolume
@onready var mouse_sensitivity = $MouseSensitivityLabel/MouseSensitivity
@onready var head_bob = $HeadBobLabel/HeadBob

var sfx_ready = false

func _ready() -> void:
	master_volume.value = AudioPlayer.default_volumes[0]
	music_volume.value = AudioPlayer.default_volumes[1]
	sfx_volume.value = AudioPlayer.default_volumes[2]
	mouse_sensitivity.value = Prefs.mouse_sensitivity	
	head_bob.value = Prefs.head_bob
	sfx_ready = true

func _on_return_pressed() -> void:	
	get_tree().change_scene_to_file(title_path)


func _on_master_volume_value_changed(value: float) -> void:
	AudioPlayer.update_volume(0, value)


func _on_music_volume_value_changed(value: float) -> void:
	AudioPlayer.update_volume(1, value)


func _on_sfx_volume_value_changed(value: float) -> void:
	AudioPlayer.update_volume(2, value)
	if sfx_ready:
		AudioPlayer.play_sfx_array(AudioPlayer.player_damaged_sfx_arr)


func _on_mouse_sensitivity_value_changed(value: float) -> void:
	Prefs.mouse_sensitivity = value
	print(value)


func _on_head_bob_value_changed(value: float) -> void:
	Prefs.head_bob = value
	print(value)
