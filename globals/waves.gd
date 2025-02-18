extends Node

signal wave_started(wave_number: int)

var current_wave = 0:
	set(value):
		current_wave = value
		wave_started.emit.call_deferred(current_wave)

var spawners = []
var spawnlist = []


func prune_spawnlist() -> void:
	var temp = []

	for item in spawnlist:
		if is_instance_valid(item) and not item.is_queued_for_deletion():
			temp.append(item)

	spawnlist = temp
