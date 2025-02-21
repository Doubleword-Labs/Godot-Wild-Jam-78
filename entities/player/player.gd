extends CharacterBody3D
class_name Player

const PROJECTILE = preload("res://entities/projectile/projectile.tscn")
const PAPER_BALL_THROW = preload("res://entities/weapon/resources/paper_ball_throw.tres")
const RUBBER_BAND_GUN = preload("res://entities/weapon/resources/rubber_band_gun.tres")
const STAPLE_SHOTGUN = preload("res://entities/weapon/resources/staple_shotgun.tres")

@onready var player_hud: CanvasLayer = $PlayerHud
@onready var attack_timer: Timer = $AttackTimer
@onready var camera: Camera3D = $Camera3D
@onready var projectile_spawn_point: Node3D = $Camera3D/ProjectileSpawnPoint
@onready var melee_ray_cast: RayCast3D = $Camera3D/MeleeRayCast

@export var speed := 5.0
@export var joy_look_sens := 0.05
@export var mouse_look_sens := 0.005

@export var health := 100.0
var can_attack := true

var current_weapon := 0

var melee_weapon := preload("res://entities/weapon/resources/melee.tres")
var weapons: Array[PlayerWeapon] = [
	PlayerWeapon.new(PAPER_BALL_THROW, true),
	PlayerWeapon.new(RUBBER_BAND_GUN, false),
	PlayerWeapon.new(STAPLE_SHOTGUN, false),
]


func _ready() -> void:
	melee_ray_cast.target_position.y = -melee_weapon.attack_range
	_update_weapon(weapons[current_weapon].resource)
	if (Buff.player_ogre):
		health = 200
		Game.hp_gui.value = health


func _request_weapon(index: int) -> void:
	if current_weapon == index:
		print("Weapon already equipped")
		return

	var requested_weapon := weapons[index]
	if requested_weapon.owned:
		_update_weapon(requested_weapon.resource)
	else:
		print("You don't have that weapon")


func _update_weapon(resource: WeaponResource) -> void:
	printt("equipping weapon", resource)
	player_hud.update_weapon(resource)


func _get_current_weapon() -> WeaponResource:
	return weapons[current_weapon].resource


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


func _ranged_attack() -> void:
	can_attack = false
	var current_weapon_resource := _get_current_weapon()
	attack_timer.start(current_weapon_resource.attack_timeout)
	player_hud.shoot_attack()
	Game.spawn_projectile(self, projectile_spawn_point, current_weapon_resource.projectile_resource)


func _melee_attack() -> void:
	can_attack = false
	attack_timer.start(melee_weapon.attack_timeout)
	player_hud.melee_attack()

	melee_ray_cast.force_raycast_update()
	if melee_ray_cast.is_colliding():
		var hit = melee_ray_cast.get_collider()

		if hit.is_in_group("damageable"):
			hit.take_damage(melee_weapon.attack_damage, true)
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

	var look_vector := -Input.get_axis("look_left", "look_right")
	if look_vector:
		rotate_y(look_vector * joy_look_sens)

	move_and_slide()


func take_damage(damage: int, from_player: bool) -> void:
	if !from_player:
		printt("took damage", damage)
		AudioPlayer.play_sfx_array(AudioPlayer.player_damaged_sfx_arr)

		health -= damage

		Game.hp_gui.value = health

		if health <= 0:
			Game.die()


func _on_attack_timer_timeout() -> void:
	can_attack = true
