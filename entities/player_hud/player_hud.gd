extends CanvasLayer

const MELEE_WEAPON_RESOURCE = preload("res://entities/weapon/resources/melee.tres")

@onready var weapon_sprite: AnimatedSprite2D = $Hand/WeaponSprite
@onready var melee_sprite: AnimatedSprite2D = $Hand/MeleeSprite

var weapon_resource: WeaponResource


func _ready() -> void:
	Game.paused_gui_node = $Pause
	Game.lose_gui_node = $PauseLose
	Game.win_gui_node = $PauseWin
	Game.shop_player_buff_node = $ShopPlayerBuff
	Game.shop_weapon_buff_node = $ShopWeaponBuff
	
	Game.hp_gui = $HealthBar
	Game.hp_gui.max_value = 100
	Game.hp_gui.value = Game.get_player().health
	Game.stationery_gui = $Stationery
	Game.wave_gui = $Wave

	_update_melee_weapon()
	weapon_sprite.show()
	melee_sprite.hide()
	
	$AnimatedSprite2D.play()


func melee_attack() -> void:
	weapon_sprite.hide()
	melee_sprite.show()

	melee_sprite.play(MELEE_WEAPON_RESOURCE.attack_animation)
	await melee_sprite.animation_finished

	weapon_sprite.show()
	melee_sprite.hide()


func shoot_attack() -> void:
	weapon_sprite.play(weapon_resource.attack_animation)
	await weapon_sprite.animation_finished
	weapon_sprite.play(weapon_resource.idle_animation)


func update_weapon(resource: WeaponResource):
	if not is_instance_valid(resource):
		return

	self.weapon_resource = resource

	if is_instance_valid(weapon_sprite):
		weapon_sprite.sprite_frames = resource.sprite_frames
		weapon_sprite.position = resource.sprite_position
		weapon_sprite.scale = resource.sprite_scale
		weapon_sprite.play(resource.idle_animation)


func _update_melee_weapon():
	if not is_instance_valid(MELEE_WEAPON_RESOURCE):
		return

	var resource := MELEE_WEAPON_RESOURCE

	if is_instance_valid(melee_sprite):
		melee_sprite.sprite_frames = resource.sprite_frames
		melee_sprite.position = resource.sprite_position
		melee_sprite.scale = resource.sprite_scale
		melee_sprite.play(resource.idle_animation)
