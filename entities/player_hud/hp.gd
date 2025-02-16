extends ProgressBar
class_name Gui_HP

func _ready() -> void:
	$".".max_value = 100
	$".".value = Game.get_player().health
	Game.hp_gui = $"."
