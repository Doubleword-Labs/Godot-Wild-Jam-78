extends Node

const PROJECTILE = preload("res://entities/projectile/projectile.tscn")

var player: Player
var hp_gui: Gui_HP
var paused_gui_node
var paused = false

func _process(_delta: float) -> void:
	if paused_gui_node != null:
		if Input.is_action_just_released("pause"):
			if (paused):
				paused = false
				get_tree().paused = false
				paused_gui_node.visible = false
				process_mode = Node.PROCESS_MODE_PAUSABLE
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				paused = true
				get_tree().paused = true
				paused_gui_node.visible = true
				process_mode = Node.PROCESS_MODE_WHEN_PAUSED


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

	return projectile
