@tool
extends Node3D

@export_tool_button("Randomize Texture") var randomize_texture_button = randomize_texture

var textures: Array[Texture2D] = [
	preload("res://assets/weapons/stapler_shotgun/projectiles/shot_stapler01.png"),
	preload("res://assets/weapons/stapler_shotgun/projectiles/shot_stapler02.png"),
	preload("res://assets/weapons/stapler_shotgun/projectiles/shot_stapler03.png"),
	preload("res://assets/weapons/stapler_shotgun/projectiles/shot_stapler04.png"),
]

@onready var sprite_3d: Sprite3D = $Sprite3D


func _ready() -> void:
	if is_instance_valid(sprite_3d):
		randomize_texture()


func randomize_texture() -> void:
	sprite_3d.texture = textures.pick_random()
