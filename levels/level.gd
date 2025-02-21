extends Node3D
class_name Level

@onready var world_environment: WorldEnvironment = $WorldEnvironment

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Waves.shop_time:
		Game.wave_gui.text = "Shop Time!"
		Game.stationery_gui.text = ""
	else:
		Game.wave_gui.text = "Wave: "+str(Waves.current_wave)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_lava_area_body_entered(body: Node3D) -> void:
	Game.die()


func _on_shop_door_body_entered(body: Node3D) -> void:
	print("Shop Opened!")
	Game.hud_modal(Game.shop_player_buff_node)


func _on_exit_door_body_entered(body: Node3D) -> void:
	Waves.shop_time = false
	Waves.set_level()
