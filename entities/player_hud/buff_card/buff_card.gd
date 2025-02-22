extends Node
class_name BuffCard

@export var buffs:Array[BuffResource] = []

var internal_name: String = "internal"

func render_buff(resource: BuffResource):
	internal_name = resource.internal_name
	$Label.text = resource.headline
	$TextureRect.texture = resource.texture
	$Button.text = resource.text


func _on_purchase_pressed() -> void:
	print(internal_name)
