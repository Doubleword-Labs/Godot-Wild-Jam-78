extends Node3D

var levels: Array[String] = []


func _ready() -> void:
	if not OS.is_debug_build() or OS.has_feature("loading"):
		levels.append_array(Waves.levels)
		levels.append(Waves.shop)

		var master_bus_index := AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(master_bus_index, true)

		for level in levels:
			var scene: Node3D = load(level).instantiate()
			add_child(scene)
			await get_tree().create_timer(1.0).timeout
			scene.queue_free()

		await get_tree().create_timer(1.0).timeout
		AudioServer.set_bus_mute(master_bus_index, false)

	get_tree().change_scene_to_file("res://menus/title.tscn")
