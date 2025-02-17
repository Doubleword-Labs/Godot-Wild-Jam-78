extends Node

const game_music: AudioStream = preload("res://assets/music/jungle-story-168459.mp3")

var music_player: AudioStreamPlayer
var default_volumes = [1, 0.4, 0.6]


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
	sfx_player.play()
	
	await sfx_player.finished
