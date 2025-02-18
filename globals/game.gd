extends Node

const PROJECTILE := preload("res://entities/projectile/projectile.tscn")

var player: Player
var hp_gui: TextureProgressBar
var stationery_gui: Label
var paused_gui_node: Node
var lose_gui_node: Node
var win_gui_node: Node
var spawnables := []

var current_level := "res://levels/arena03/arena_03.tscn"

var paused := false
var can_pause := true

func _process(_delta: float) -> void:
	if paused_gui_node != null:
		if Input.is_action_just_released("pause") and can_pause:
			pause(!paused)				
			paused_gui_node.visible = paused


func pause(to_pause: bool) -> void:
	paused = to_pause
	get_tree().paused = to_pause
	
	if (to_pause):
		process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	else:
		process_mode = Node.PROCESS_MODE_PAUSABLE


func get_player() -> Player:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	return player


func _physics_process(_delta: float) -> void:
	if is_instance_valid(get_player()):
		get_tree().call_group("enemies", "update_target_position", player.global_transform.origin)


func _get_projectiles_parent() -> Node:
	return get_tree().root

func spawn_projectile(actor: Node3D, spawn_point: Node3D, resource: Resource = null) -> Projectile:
	var projectile := PROJECTILE.instantiate()
	projectile.resource = resource
	projectile.spawned_by = actor
	projectile.rotation = actor.rotation
	projectile.velocity = -actor.transform.basis.z * 10.0

	_get_projectiles_parent().add_child(projectile)
	projectile.global_position = spawn_point.global_position
	spawnables.append(projectile)
	return projectile


func free_spawnables() -> void:
	for spawn in spawnables:
		if spawn != null:
			spawn.queue_free()
	spawnables = []


func reload():
	free_spawnables()	
	pause(false)
	can_pause = true


func die():
	pause(true)
	AudioPlayer.free_sfx()
	AudioPlayer.play_sfx_array(AudioPlayer.lose_sfx_arr)
	can_pause = false
	lose_gui_node.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func win():
	pause(true)
	AudioPlayer.free_sfx()
	AudioPlayer.play_sfx_array(AudioPlayer.win_sfx_arr)
	can_pause = false
	win_gui_node.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
