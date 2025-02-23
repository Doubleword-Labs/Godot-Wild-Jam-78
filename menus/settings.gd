extends CanvasLayer

var title_path := "res://menus/title.tscn"

@onready var master_volume = $Master/MasterVolume
@onready var music_volume = $Music/MusicVolume
@onready var sfx_volume = $SFX/SFXVolume
@onready var mouse_sensitivity = $MouseSensitivityLabel/MouseSensitivity
@onready var head_bob = $HeadBobLabel/HeadBob

var sfx_ready = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	master_volume.value = Prefs.master_volume
	music_volume.value = Prefs.music_volume
	sfx_volume.value = Prefs.sfx_volume
	mouse_sensitivity.value = Prefs.mouse_sensitivity
	head_bob.value = Prefs.head_bob
	sfx_ready = true


func _on_return_pressed() -> void:
	Waves.current_wave = 1
	get_tree().change_scene_to_file(title_path)


func _on_master_volume_value_changed(value: float) -> void:
	AudioPlayer.update_volume(0, value)
	Prefs.master_volume = value
	Prefs.save()


func _on_music_volume_value_changed(value: float) -> void:
	AudioPlayer.update_volume(1, value)
	Prefs.music_volume = value
	Prefs.save()


func _on_sfx_volume_value_changed(value: float) -> void:
	AudioPlayer.update_volume(2, value)
	Prefs.sfx_volume = value
	Prefs.save()
	if sfx_ready:
		AudioPlayer.play_sfx_array(AudioPlayer.player_damaged_sfx_arr)


func _on_mouse_sensitivity_value_changed(value: float) -> void:
	Prefs.mouse_sensitivity = value
	Prefs.save()
	var player = Game.get_player()
	if player != null:
		player.mouse_look_sens = value


func _on_head_bob_value_changed(value: float) -> void:
	Prefs.head_bob = value
	Prefs.save()
	var player = Game.get_player()
	if player != null:
		player.head_bob_speed = value
