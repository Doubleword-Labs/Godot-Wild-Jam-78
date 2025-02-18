extends Node

var current_wave = 1
var spawners = []
var spawnlist = []

func prune_spawnlist() -> void:
	var temp = []
	
	for item in spawnlist:
		if is_instance_valid(item) and not item.is_queued_for_deletion():
			temp.append(item)
				
	spawnlist = temp
