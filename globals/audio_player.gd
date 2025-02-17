extends AudioStreamPlayer

const game_music: AudioStream = preload("res://assets/music/jungle-story-168459.mp3")

var music_player: AudioStreamPlayer
var volume_music:= 0.0
var volume_sfx:= 0.0

func play_music():
	if music_player != null:
		return
		
	music_player = AudioStreamPlayer.new()
	music_player.stream = game_music
	music_player.autoplay = true
	add_child(music_player)
	music_player.play()	
	
func play_sfx(sfx: AudioStream):
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = sfx
	sfx_player.volume_db = volume_sfx
	add_child(sfx_player)
	sfx_player.play()
	
	await sfx_player.finished
