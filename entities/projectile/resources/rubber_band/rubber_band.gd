@tool
extends Node3D

@export_tool_button("Randomize Texture") var randomize_texture_button = randomize_texture

var textures: Array[Texture2D] = [
	preload("res://assets/weapons/rubber_band_gun/projectiles/shot_rubberband01.png"),
	preload("res://assets/weapons/rubber_band_gun/projectiles/shot_rubberband02.png"),
	preload("res://assets/weapons/rubber_band_gun/projectiles/shot_rubberband03.png"),
	preload("res://assets/weapons/rubber_band_gun/projectiles/shot_rubberband04.png"),
	preload("res://assets/weapons/rubber_band_gun/projectiles/shot_rubberband05.png"),
]

@onready var sprite_3d: Sprite3D = $Sprite3D


func _ready() -> void:
	if is_instance_valid(sprite_3d):
		randomize_texture()


func randomize_texture() -> void:
	sprite_3d.texture = textures.pick_random()
