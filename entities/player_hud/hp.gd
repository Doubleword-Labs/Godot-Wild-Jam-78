extends ProgressBar
class_name Gui_HP

@onready var hp_gui = $"."

func _ready() -> void:
	hp_gui.max_value = 100
	hp_gui.value = Game.get_player().health
	Game.hp_gui = hp_gui
