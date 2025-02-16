extends CharacterBody3D
class_name Player

const PROJECTILE = preload("res://entities/projectile/projectile.tscn")

@onready var player_hud: CanvasLayer = $PlayerHud
@onready var attack_timer: Timer = $AttackTimer
@onready var camera: Camera3D = $Camera3D
@onready var projectile_spawn_point: Node3D = $Camera3D/ProjectileSpawnPoint

@export var speed := 5.0
@export var joy_look_sens := 0.05
@export var mouse_look_sens := 0.005

var health := 100.0
var can_attack := true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_look_sens)

func _process(_delta: float) -> void:
	if Input.is_action_pressed("attack") and can_attack:
		_attack()

func _attack() -> void:
	can_attack = false
	attack_timer.start()
	Game.spawn_projectile(self, projectile_spawn_point)
	
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

		health -= damage
		if health <= 0:
			print("u r ded")


func _on_attack_timer_timeout() -> void:
	can_attack = true
