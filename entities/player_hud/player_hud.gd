extends CanvasLayer

@onready var weapon_sprite: AnimatedSprite2D = $Hand/AnimatedSprite2D


func melee_attack() -> void:
	weapon_sprite.play("melee")
	await weapon_sprite.animation_finished
	weapon_sprite.play("idle")
