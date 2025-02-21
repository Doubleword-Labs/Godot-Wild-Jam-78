extends Node

var player_ogre := false
var player_flash := false
var player_vampire := false
var player_regen := false
var player_damage := false

func is_player_buffs_all_bought():
	return (player_ogre and 
		player_flash and	
		player_vampire and
		player_regen and
		player_damage)

func is_shop_bought():
	return is_player_buffs_all_bought()
