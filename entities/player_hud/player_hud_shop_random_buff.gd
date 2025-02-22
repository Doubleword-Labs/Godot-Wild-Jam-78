extends CanvasLayer

var BUFF_CARD = preload("res://entities/player_hud/buff_card/buff_card.tscn")

@onready var container: HBoxContainer = $HBoxContainer

@export var buffs:Array[BuffResource] = []
var buffs2:Array[BuffResource]

@onready var buffcard = $BuffCard
@onready var buffcard2 = $BuffCard2
@onready var buffcard3 = $BuffCard3

func _ready() -> void:
	#show 3 discrete random buffs
	var buff = buffs.pick_random()
	render_buff(buffcard, buff)
	remove_buff(buff)
	
	buff = buffs.pick_random()
	render_buff(buffcard2, buff)
	remove_buff(buff)
	
	buff = buffs.pick_random()
	render_buff(buffcard3, buff)


func  remove_buff(buff: BuffResource):
	var temp: Array[BuffResource] = []
	for b in buffs:
		if buff.internal_name != b.internal_name:
			temp.append(b)
	buffs = temp
	

func  render_buff(node: BuffCard, resource: BuffResource):
	node.internal_name = resource.internal_name
	node.get_node("Headline").text = resource.headline
	node.get_node("TextureRect").texture = resource.texture
	node.get_node("Subtitle").text = resource.text
	
