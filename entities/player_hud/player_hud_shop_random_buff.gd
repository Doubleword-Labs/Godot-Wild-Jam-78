extends CanvasLayer

var BUFF_CARD = preload("res://entities/player_hud/buff_card/buff_card.tscn")

@onready var container: HBoxContainer = $HBoxContainer

@export var buffs:Array[BuffResource] = []

@onready var buffcard = $BuffCard
@onready var buffcard2 = $BuffCard2
@onready var buffcard3 = $BuffCard3

func _ready() -> void:
	render_buff(buffcard,buffs.pick_random())
	render_buff(buffcard2,buffs.pick_random())
	render_buff(buffcard3,buffs.pick_random())


func  render_buff(node: BuffCard, resource: BuffResource):
	node.internal_name = resource.internal_name
	node.get_node("Headline").text = resource.headline
	node.get_node("TextureRect").texture = resource.texture
	node.get_node("Subtitle").text = resource.text
	
