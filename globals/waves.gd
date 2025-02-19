extends Node

signal wave_started(wave_number: int)

var current_wave = 0:
	set(value):
		current_wave = value
		wave_started.emit.call_deferred(current_wave)

var spawners = []
var spawnlist = []
var levels = [
	"res://levels/arena03/arena_03.tscn",
	"res://levels/arena02/arena_02.tscn",
	"res://levels/arena04/arena_04.tscn"
]

func set_level():
	Game.current_level = levels[(current_wave - 1) % len(levels)]


func prune_spawnlist() -> void:
	var temp = []

	for item in spawnlist:
		if is_instance_valid(item) and not item.is_queued_for_deletion():
			temp.append(item)

	spawnlist = temp
