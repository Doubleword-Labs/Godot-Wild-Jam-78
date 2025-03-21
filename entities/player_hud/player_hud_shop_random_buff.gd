extends CanvasLayer

var BUFF_CARD = preload("res://entities/player_hud/buff_card/buff_card.tscn")

@onready var container: HBoxContainer = $HBoxContainer

@export var buffs:Array[BuffResource] = []

@onready var buffcard = $BuffCard
@onready var buffcard2 = $BuffCard2
@onready var buffcard3 = $BuffCard3

var weapons = []

var shown_weapon = false

func _ready() -> void:
	remove_buffs_already_activated()
	get_weapons()
	#hide extra cards if not enough buffs
	if len(buffs) == 2:
		buffcard3.visible = false

	if len(buffs) == 1:
		buffcard.visible = false
		buffcard3.visible = false

	#show 3 discrete random buffs
	var buff
	if len(buffs) >= 3:
		buff = buffs.pick_random()
		render_buff(buffcard3, buff)
		remove_buff(buff)

	if len(buffs) >= 2:	
		buff = buffs.pick_random()
		render_buff(buffcard, buff)
		remove_buff(buff)

	if len(buffs) >= 1:
		buff = buffs.pick_random()
		render_buff(buffcard2, buff)
	
	if (!shown_weapon and len(weapons) > 0 and len(buffs) >= 4):
		render_buff(buffcard2, weapons.pick_random())


func get_weapons():
	var temp: Array[BuffResource] = []
	for b in buffs:
		if (
			(b.internal_name  == "minigun" and !Buff.weapon_minigun)
			or (b.internal_name  == "stapler" and !Buff.weapon_staple)
			):
			temp.append(b)
	weapons = temp

func is_buff_weapon(b: BuffResource) -> bool:
	return b.internal_name  == "minigun" or b.internal_name  == "stapler"
	

func remove_buffs_already_activated():
	var temp: Array[BuffResource] = []
	for b in buffs:
		if (
			(b.internal_name  == "ogre" and !Buff.player_ogre)
			or (b.internal_name  == "flash" and !Buff.player_flash)
			or (b.internal_name  == "vampire" and !Buff.player_vampire)
			or (b.internal_name  == "regen" and !Buff.player_regen)
			or (b.internal_name  == "damage" and !Buff.player_damage)
			or (b.internal_name  == "minigun" and !Buff.weapon_minigun)
			or (b.internal_name  == "stapler" and !Buff.weapon_staple)
			):
			temp.append(b)
	buffs = temp
	


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
	if is_buff_weapon(resource):
		shown_weapon = true
	
