extends CanvasLayer

@onready var gui_ogre: Button = $ButtonOgre
@onready var gui_flash: Button = $ButtonFlash
@onready var gui_vampire: Button = $ButtonVampire
@onready var gui_regen: Button = $ButtonRegen
@onready var gui_damage: Button = $ButtonDamage
@onready var root:CanvasLayer = $"."

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	if Buff.player_ogre:
		gui_ogre.disabled = true
	if Buff.player_flash:
		gui_flash.disabled = true
	if Buff.player_vampire:
		gui_vampire.disabled = true
	if Buff.player_regen:
		gui_regen.disabled = true
	if Buff.player_damage:
		gui_damage.disabled = true


func _on_button_ogre_pressed() -> void:
	Buff.player_ogre = true
	weapon_buff_modal()


func _on_button_flash_pressed() -> void:
	Buff.player_flash = true
	weapon_buff_modal()


func _on_button_vampire_pressed() -> void:
	Buff.player_vampire = true
	weapon_buff_modal()


func _on_button_regen_pressed() -> void:
	Buff.player_regen = true
	weapon_buff_modal()


func _on_button_damage_pressed() -> void:
	Buff.player_damage = true
	weapon_buff_modal()


func weapon_buff_modal():
	root.visible = false
	if (Buff.is_weapon_buffs_all_bought()):
		Waves.exit_shop()
	else:
		Game.shop_weapon_buff_node.visible = true
