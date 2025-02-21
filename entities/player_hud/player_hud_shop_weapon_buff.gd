extends CanvasLayer

@onready var gui_minigun: Button = $ButtonMinigun
@onready var gui_stapler: Button = $ButtonStapler

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	if Buff.weapon_minigun:
		gui_minigun.disabled = true
	if Buff.weapon_staple:
		gui_stapler.disabled = true


func _on_button_minigun_pressed() -> void:	
	Buff.weapon_minigun = true
	Waves.exit_shop()


func _on_button_stapler_pressed() -> void:
	Buff.weapon_staple = true
	Waves.exit_shop()
