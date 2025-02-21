extends CanvasLayer

@onready var gui_ogre: Button = $ButtonOgre
@onready var gui_flash: Button = $ButtonFlash
@onready var gui_vampire: Button = $ButtonVampire
@onready var gui_regen: Button = $ButtonRegen
@onready var gui_damage: Button = $ButtonDamage

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
		
	if (Buff.player_ogre and 
	Buff.player_flash and	
	Buff.player_vampire and
	Buff.player_regen and
	Buff.player_damage):
		print('all shop purchased')


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
	print(Buff.player_damage)
	weapon_buff_modal()


func weapon_buff_modal():
	print('weapon buff modal')
	Game.pause(false)
	Waves.set_shop()
	pass
