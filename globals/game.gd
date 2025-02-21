extends Node

const PROJECTILE := preload("res://entities/projectile/projectile.tscn")

var player: Player

var hp_gui: TextureProgressBar

var stationery_gui: Label
var wave_gui: Label

var paused_gui_node: CanvasLayer
var lose_gui_node: CanvasLayer
var win_gui_node: CanvasLayer
var shop_player_buff_node: CanvasLayer
var shop_weapon_buff_node: CanvasLayer
var player_hud

var spawnables := []

var current_level := "res://levels/arena03/arena_03.tscn"

var paused := false
var can_pause := true

var current_weapon = 0

func _process(_delta: float) -> void:
	if paused_gui_node != null:
		if Input.is_action_just_released("pause") and can_pause:
			pause(!paused)
			paused_gui_node.visible = paused

	if Input.is_action_just_pressed("full_screen"):
		var current_mode := get_window().mode
		if current_mode == Window.MODE_FULLSCREEN:
			get_window().mode = Window.MODE_WINDOWED
		else:
			get_window().mode = Window.MODE_FULLSCREEN


func pause(to_pause: bool) -> void:
	AudioPlayer.free_sfx()

	if OS.get_name() == "Web":
		AudioPlayer.squelch_sfx = true
		await get_tree().create_timer(0.25).timeout

	paused = to_pause
	get_tree().paused = to_pause

	if to_pause:
		process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	else:
		process_mode = Node.PROCESS_MODE_PAUSABLE

	if OS.get_name() == "Web":
		AudioPlayer.squelch_sfx = false

	Game.can_pause = to_pause


func get_player() -> Player:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")

	return player


func _physics_process(_delta: float) -> void:
	if not is_inside_tree():
		return

	if is_instance_valid(get_player()):
		get_tree().call_group("enemies", "update_target_position", player.global_transform.origin)


func get_projectiles_parent() -> Node:
	return get_tree().root


func spawn_projectile(
	actor: Node3D, spawn_point: Node3D, resource: ProjectileResource
) -> Projectile:
	if not is_instance_valid(resource):
		push_error("Invalid projectile resource provided")

	var projectile := PROJECTILE.instantiate()
	projectile.resource = resource
	projectile.spawned_by = actor
	projectile.rotation = actor.rotation
	projectile.velocity = -actor.transform.basis.z

	get_projectiles_parent().add_child(projectile)
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


func hud_modal(modal: CanvasLayer):
	pause(true)
	can_pause = false
	modal.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func die():
	player_hud.erase_damage_transparency = 0
	pause(true)
	AudioPlayer.play_sfx_array(AudioPlayer.lose_sfx_arr)
	hud_modal(lose_gui_node)


func win():
	player_hud.erase_damage_transparency = 0
	pause(true)
	AudioPlayer.play_sfx_array(AudioPlayer.win_sfx_arr)
	hud_modal(win_gui_node)
