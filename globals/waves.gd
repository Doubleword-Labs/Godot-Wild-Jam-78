extends Node

signal wave_started(wave_number: int)

var current_wave = 0:
	set(value):
		current_wave = value
		wave_started.emit.call_deferred(current_wave)

var spawners = []
var spawnlist = []
var levels = [
	"res://levels/arena04/arena_04.tscn",
	"res://levels/arena02/arena_02.tscn",
	"res://levels/arena03/arena_03.tscn",
]
var shop = "res://levels/shop/shop.tscn"

func set_level():
	get_tree().change_scene_to_file(
		levels[(current_wave - 1) % len(levels)]
		)


func get_spawn_limit():
	var spawn_limit = round((current_wave+.5) / 3)
	printt('spawn limit', spawn_limit)
	return spawn_limit


func get_spawn_amount():
	var spawn_amount = round((current_wave+.5) / 3)
	printt('spawn_amount', spawn_amount)
	return spawn_amount
	


func prune_spawnlist() -> void:
	var temp = []

	for item in spawnlist:
		if is_instance_valid(item) and not item.is_queued_for_deletion():
			temp.append(item)

	spawnlist = temp
