extends Node
class_name BuffCard

var internal_name: String = "internal"


func _on_purchase_pressed() -> void:
	print(internal_name)
	
	if internal_name == "ogre":
		Buff.player_ogre = true
				
	if internal_name == "flash":
		Buff.player_flash = true
		
	if internal_name == "vampire":
		Buff.player_vampire = true
		
	if internal_name == "regen":
		Buff.player_regen = true
		
	if internal_name == "damage":
		Buff.player_damage = true
		
	if internal_name == "minigun":
		Buff.weapon_minigun = true
		Game.current_weapon = 1
		
	if internal_name == "stapler":
		Buff.weapon_staple = true
		Game.current_weapon = 2

	Waves.exit_shop()
