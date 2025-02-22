extends Node3D
class_name Level

@onready var world_environment: WorldEnvironment = $WorldEnvironment

var shop_buy = "res://entities/player_hud/player_hud_shop_random_buff.tscn"

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Waves.shop_time:
		Game.wave_gui.text = "Shop Time!"
		Game.stationery_gui.text = ""
	else:
		Game.wave_gui.text = "Wave: " + str(Waves.current_wave)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_lava_area_body_entered(body: Node3D) -> void:
	Game.die()


func _on_shop_door_body_entered(body: Node3D) -> void:
	print("Shop Opened!")
	#Game.hud_modal(Game.shop_player_buff_node)	
	get_tree().change_scene_to_file(shop_buy)


func _on_exit_door_body_entered(body: Node3D) -> void:
	Waves.shop_time = false
	Waves.set_level()


func _input(event: InputEvent) -> void:
	# Fix for web export not capturing the mouse
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
