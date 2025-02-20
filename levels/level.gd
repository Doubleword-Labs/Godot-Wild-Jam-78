extends Node3D
class_name Level

@onready var world_environment: WorldEnvironment = $WorldEnvironment

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Waves.shop_time:
		Game.wave_gui.text = "Shop Time!"
	else:
		Game.wave_gui.text = "Wave: "+str(Waves.current_wave)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_lava_area_body_entered(body: Node3D) -> void:
	Game.die()
