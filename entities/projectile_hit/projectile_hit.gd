extends Node3D

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D


func _on_animated_sprite_3d_animation_finished() -> void:
	queue_free()
