extends Node

var player_ogre := false
var player_flash := false
var player_vampire := false
var player_regen := false
var player_damage := false

var weapon_staple := false:
	set(value):
		weapon_staple = value
		if value:
			enable_player_weapon(2)

var weapon_minigun := false:
	set(value):
		weapon_minigun = value
		if value:
			enable_player_weapon(1)

var player_ogre_amount := 150


func reset_buffs():
	player_ogre = false
	player_flash = false
	player_vampire = false
	player_regen = false
	player_damage = false
	weapon_minigun = false
	weapon_staple = false

func is_player_buffs_all_bought():
	return player_ogre and player_flash and player_vampire and player_regen and player_damage


func is_weapon_buffs_all_bought():
	return weapon_staple and weapon_minigun


func is_shop_bought():
	return is_player_buffs_all_bought() and is_weapon_buffs_all_bought()


func enable_player_weapon(index: int) -> void:
	var player := Game.get_player()
	if is_instance_valid(player):
		player.weapons[index].owned = true
