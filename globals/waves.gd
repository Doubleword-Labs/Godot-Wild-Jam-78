extends Node

var current_wave = 1
var spawners = []
var spawnlist = []

func prune_spawnlist() -> void:
	var temp = []
	
	for item in spawnlist:
		if (item != null):
			temp.append(item)
				
	spawnlist = temp
