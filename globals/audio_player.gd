extends Node

const game_music: AudioStream = preload("res://assets/music/jungle-story-168459.mp3")
const lose_sfx_arr := [
	preload("res://assets/sfx/lose/voice - oh no 5.wav"),
	preload("res://assets/sfx/lose/voice - oh god 1.wav"),
	preload("res://assets/sfx/lose/voice - oh no 3.wav")]
const win_sfx_arr := [
	preload("res://assets/sfx/win/kazoo 2.wav"),
	preload("res://assets/sfx/win/voice - wow 2.wav"),
	preload("res://assets/sfx/win/voice - wow 3.wav"),
	preload("res://assets/sfx/win/voice - hmeh meh meh meh.wav"),
	preload("res://assets/sfx/win/voice - wow 1.wav")
]
const died_enemy_arr = [
	preload("res://assets/sfx/died_enemy/bowl smashed apart 1.wav"),
	preload("res://assets/sfx/died_enemy/bowl smashed apart on wood 3.wav"),
	preload("res://assets/sfx/died_enemy/bowl smashed apart on wood 16.wav"),
	preload("res://assets/sfx/died_enemy/bowl smashed apart on wood 17.wav"),
	preload("res://assets/sfx/died_enemy/bowl smashed apart on wood 18.wav"),
	preload("res://assets/sfx/died_enemy/bowl smashed apart on wood 19.wav")
]
const pain_enemy_arr = [
	preload("res://assets/sfx/pain_enemy/plastic crunch 6.wav"),
	preload("res://assets/sfx/pain_enemy/plastic crunch 11.wav"),
	preload("res://assets/sfx/pain_enemy/plastic crunch 12.wav"),
	preload("res://assets/sfx/pain_enemy/plastic crunch 13.wav"),
	preload("res://assets/sfx/pain_enemy/plastic crunch 14.wav"),
	preload("res://assets/sfx/pain_enemy/plastic crunch 21.wav")
]
const player_damaged_sfx_arr = [
	preload("res://assets/sfx/player_damaged/voice - ahh.wav"),
	preload("res://assets/sfx/player_damaged/voice - bah.wav"),
	preload("res://assets/sfx/player_damaged/voice - blaah.wav"),
	preload("res://assets/sfx/player_damaged/voice - raaaaaa.wav"),
	preload("res://assets/sfx/player_damaged/voice - oohh.wav")
	]
const punch_sfx_arr = [
	preload("res://assets/sfx/punch/punch clothes 1.wav"),
	preload("res://assets/sfx/punch/punch clothes 8.wav"),
	preload("res://assets/sfx/punch/punch clothes 9.wav"),
	preload("res://assets/sfx/punch/punch flesh 8.wav"),
	preload("res://assets/sfx/punch/punch flesh 9.wav"),
	preload("res://assets/sfx/punch/punch flesh 10.wav")
]
const projectile_spawed_sfx_arr = [
	preload("res://assets/sfx/projectile_spawned/paper crunch 1.wav"),
	preload("res://assets/sfx/projectile_spawned/paper crunch 2.wav"),
	preload("res://assets/sfx/projectile_spawned/paper crunch 3.wav"),
	preload("res://assets/sfx/projectile_spawned/paper crunch 4.wav"),
	preload("res://assets/sfx/projectile_spawned/plastic crunch 15.wav"),
	preload("res://assets/sfx/projectile_spawned/plastic crunch 16.wav"),
	preload("res://assets/sfx/projectile_spawned/plastic crunch 21.wav")
]
	
var music_player: AudioStreamPlayer
var default_volumes = [1, 0.4, 0.6]

var sfx_player_list = []

var squelch_sfx = false

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
	if squelch_sfx:
		return
	
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
