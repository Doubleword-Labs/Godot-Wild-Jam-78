@tool
extends Node3D

@onready var sign_label_3d: Label3D = %SignLabel3D
@onready var ambient_source: Node3D = $"Ambient-Source"

@export var sign_text := "Shop":
	set(value):
		sign_text = value
		if is_instance_valid(sign_label_3d):
			sign_label_3d.text = value


func _ready() -> void:
	if is_instance_valid(sign_label_3d):
		sign_label_3d.text = sign_text

	if is_instance_valid(ambient_source) and is_instance_valid(ambient_source.audio_player_node):
		ambient_source.audio_player_node.bus = "SFX"
		ambient_source.player_node = Game.get_player()
