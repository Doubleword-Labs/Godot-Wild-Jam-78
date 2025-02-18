extends Node

const game_music: AudioStream = preload("res://assets/music/jungle-story-168459.mp3")

var music_player: AudioStreamPlayer
var default_volumes = [1, 0.4, 0.6]

var sfx_player_list = []

func _ready():
	update_volume(0, default_volumes[0])
	update_volume(1, default_volumes[1])
	update_volume(2, default_volumes[2])


func update_volume(id, value):
	if value == 0:
		AudioServer.set_bus_mute(id, true)
	else:
		AudioServer.set_bus_mute(id, false)
		AudioServer.set_bus_volume_db(id, linear_to_db(value))

func play_music():
	if music_player != null:
		return
		
	music_player = MusicPlayer
	music_player.stream = game_music
	#music_player.autoplay = true
	music_player.bus = "Music"
	music_player.play()	
	
func play_sfx(sfx: AudioStream):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = sfx
	sfx_player.bus = "SFX"
	add_child(sfx_player)
	sfx_player_list.append(sfx_player)
	sfx_player.play()
	
	await sfx_player.finished
	
func play_sfx_array(sfx_arr: Array) -> void:
	play_sfx(sfx_arr.pick_random())
	
func free_sfx():
	for sfx in sfx_player_list:
		if is_instance_valid(sfx) and not sfx.is_queued_for_deletion():
			sfx.queue_free()
	
	sfx_player_list = []
