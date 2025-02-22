extends CharacterBody3D
class_name Player

const PROJECTILE = preload("res://entities/projectile/projectile.tscn")
const PAPER_BALL_THROW = preload("res://entities/weapon/resources/paper_ball_throw.tres")
const RUBBER_BAND_GUN = preload("res://entities/weapon/resources/rubber_band_gun.tres")
const STAPLE_SHOTGUN = preload("res://entities/weapon/resources/staple_shotgun.tres")

@onready var player_hud: PlayerHud = $PlayerHud
@onready var attack_timer: Timer = $AttackTimer
@onready var camera: Camera3D = %Camera3D
@onready var projectile_spawn_point: Node3D = %ProjectileSpawnPoint
@onready var melee_ray_cast: RayCast3D = %MeleeRayCast
@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes
@onready var shaker_emitter: ShakerEmitter3D = $ShakerEmitter3D

@onready var melee_sprite_base_position := player_hud.melee_sprite.position

@export var speed := 5.0
@export var joy_look_sens := 0.05
@export var mouse_look_sens := 0.005
@export var lerp_speed := 10.0
@export var damage_shaker_preset: ShakerPreset3D

@export_category("Head bob")
@export var head_bob_speed := 14.0
@export var head_bob_intensity := 0.1
@export var player_hud_bob_intensity := 5.0

@export var health := 100.0
var can_attack := true
var jump = false

var melee_weapon := preload("res://entities/weapon/resources/melee.tres")
var weapons: Array[PlayerWeapon] = [
	PlayerWeapon.new(PAPER_BALL_THROW, true),
	PlayerWeapon.new(RUBBER_BAND_GUN, Buff.weapon_minigun),
	PlayerWeapon.new(STAPLE_SHOTGUN, Buff.weapon_staple),
]

var head_bob_vector := Vector2.ZERO
var head_bob_index := 0.0


func _ready() -> void:
	melee_ray_cast.target_position.y = -melee_weapon.melee_range
	_update_weapon(weapons[Game.current_weapon].resource)

	if Buff.player_flash:
		speed = 10.0

	if Buff.player_ogre:
		health = Buff.player_ogre_amount
		Game.hp_gui.value = health


func _request_weapon(index: int) -> void:
	if Game.current_weapon == index:
		print("Weapon already equipped")
		return

	var requested_weapon := weapons[index]
	if requested_weapon.owned:
		_update_weapon(requested_weapon.resource)
		Game.current_weapon = index
	else:
		print("You don't have that weapon")


func _update_weapon(resource: WeaponResource) -> void:
	printt("equipping weapon", resource)
	player_hud.update_weapon(resource)


func _get_current_weapon() -> WeaponResource:
	return weapons[Game.current_weapon].resource


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_look_sens)


func _process(_delta: float) -> void:
	if Input.is_action_pressed("attack") and can_attack:
		_ranged_attack()

	if Input.is_action_pressed("melee_attack") and can_attack:
		_melee_attack()

	if Input.is_action_just_pressed("weapon_paper_throw"):
		_request_weapon(0)
	if Input.is_action_just_pressed("weapon_rubber_band"):
		_request_weapon(1)
	if Input.is_action_just_pressed("weapon_shotgun"):
		_request_weapon(2)

	if Input.is_action_just_pressed("jump"):
		jump = true


func _ranged_attack() -> void:
	can_attack = false
	var current_weapon_resource := _get_current_weapon()
	attack_timer.start(current_weapon_resource.attack_timeout)
	player_hud.shoot_attack()

	AudioPlayer.play_sfx_array(current_weapon_resource.attack_sounds)

	for i in range(current_weapon_resource.projectile_count):
		Game.spawn_projectile(
			self, projectile_spawn_point, current_weapon_resource.projectile_resource
		)

	if is_instance_valid(current_weapon_resource.attack_shaker_preset):
		(
			Shaker
			. shake_emit_3d(
				global_position,
				current_weapon_resource.attack_shaker_preset,
				1.0,
				current_weapon_resource.attack_shaker_duration,
			)
		)


func _melee_attack() -> void:
	can_attack = false
	attack_timer.start(melee_weapon.attack_timeout)
	player_hud.melee_attack()

	melee_ray_cast.force_raycast_update()
	if melee_ray_cast.is_colliding():
		var hit = melee_ray_cast.get_collider()

		if hit.is_in_group("damageable"):
			var damage = melee_weapon.melee_damage
			if Buff.player_damage:
				damage = damage * 2
			hit.take_damage(damage, true)
			AudioPlayer.play_sfx_array(AudioPlayer.punch_sfx_arr)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	_head_bob(input_dir, delta)

	var look_vector := -Input.get_axis("look_left", "look_right")
	if look_vector:
		rotate_y(look_vector * joy_look_sens)

	if jump and velocity.y == 0:
		velocity.y = 4
		jump = false

	move_and_slide()


func take_damage(damage: int, from_player: bool) -> void:
	if !from_player:
		printt("took damage", damage)
		Game.player_hud.erase_damage_transparency = 1
		AudioPlayer.play_sfx_array(AudioPlayer.player_damaged_sfx_arr)

		health -= damage

		Game.hp_gui.value = health

		if health <= 0:
			Game.die()
		else:
			(
				Shaker
				. shake_emit_3d(
					global_position,
					damage_shaker_preset,
					1.0,
					0.5,
				)
			)


func _on_attack_timer_timeout() -> void:
	can_attack = true


func _on_regen_timer_timeout() -> void:
	if Buff.player_regen:
		if Game.hp_gui.value < Game.hp_gui.max_value:
			var player = Game.get_player()
			player.health += 1
			Game.hp_gui.value = player.health


func _head_bob(input_dir: Vector2, delta: float) -> void:
	head_bob_index = fmod(head_bob_index + (head_bob_speed * delta), 360.0)

	if not input_dir.is_equal_approx(Vector2.ZERO) and is_on_floor():
		head_bob_vector.y = sin(head_bob_index)
		head_bob_vector.x = sin(head_bob_index / 2.0) + 0.5

		eyes.position.y = lerpf(
			eyes.position.y, head_bob_vector.y * head_bob_intensity / 2.0, delta * lerp_speed
		)
		eyes.position.x = lerpf(
			eyes.position.x, head_bob_vector.x * head_bob_intensity, delta * lerp_speed
		)

		var weapon_sprite_base_position = _get_current_weapon().sprite_position
		var weapon_sprite = player_hud.weapon_sprite
		weapon_sprite.position.x = lerpf(
			weapon_sprite.position.x,
			weapon_sprite_base_position.x + (head_bob_vector.x * player_hud_bob_intensity),
			delta * lerp_speed
		)
		weapon_sprite.position.y = lerpf(
			weapon_sprite.position.y,
			weapon_sprite_base_position.y + (head_bob_vector.y * player_hud_bob_intensity),
			delta * lerp_speed
		)
	else:
		eyes.position = lerp(eyes.position, Vector3.ZERO, delta * lerp_speed)
