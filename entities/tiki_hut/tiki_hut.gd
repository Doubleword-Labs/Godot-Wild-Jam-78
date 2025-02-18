@tool
extends Node3D

@onready var sign_label_3d: Label3D = %SignLabel3D

@export var sign_text := "Shop":
	set(value):
		sign_text = value
		if is_instance_valid(sign_label_3d):
			sign_label_3d.text = value


func _ready() -> void:
	if is_instance_valid(sign_label_3d):
		sign_label_3d.text = sign_text
