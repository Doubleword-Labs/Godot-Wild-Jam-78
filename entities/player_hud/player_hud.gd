extends CanvasLayer

@onready var weapon_sprite: AnimatedSprite2D = $Hand/AnimatedSprite2D


func _ready() -> void:
	Game.paused_gui_node = $Pause
	Game.lose_gui_node = $PauseLose
	Game.win_gui_node = $PauseWin

	Game.hp_gui = $HealthBar
	Game.hp_gui.max_value = 100
	Game.hp_gui.value = Game.get_player().health
	
	Game.stationery_gui = $Stationery
	
	Game.wave_gui = $Wave

func melee_attack() -> void:
	weapon_sprite.play("melee")
	await weapon_sprite.animation_finished
	weapon_sprite.play("idle")


func shoot_attack() -> void:
	weapon_sprite.play("shoot")
	await weapon_sprite.animation_finished
	weapon_sprite.play("idle")
	
