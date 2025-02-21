@tool
extends Node

@onready var sprite: AnimatedSprite2D = $Sprite

@export var resource: WeaponResource:
	set(value):
		resource = value
		_update_from_resource()


func _ready() -> void:
	_update_from_resource()


func _update_from_resource() -> void:
	if not is_instance_valid(resource):
		return

	if is_instance_valid(sprite):
		sprite.sprite_frames = resource.sprite_frames
		sprite.position = resource.sprite_position
		sprite.scale = resource.sprite_scale
		sprite.play(resource.idle_animation)
