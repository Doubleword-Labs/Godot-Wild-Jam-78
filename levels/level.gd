extends Node3D
class_name Level

@onready var world_environment: WorldEnvironment = $WorldEnvironment

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED	
	Game.wave_gui.text = "Wave: "+str(Waves.current_wave)


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
