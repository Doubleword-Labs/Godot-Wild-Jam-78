@tool
extends CharacterBody3D

const EnemyStateEvent = {CHASE = "chase", ATTACK = "attack", DEATH = "death"}
const PROJECTILE = preload("res://entities/projectile/projectile.tscn")

@export var resource: EnemyResource:
	set(value):
		resource = value

var speed: float
var attack_range: float
var sight_range: float

@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var sight_ray_cast: RayCast3D = %SightRayCast
@onready var attack_ray_cast: RayCast3D = %AttackRayCast
@onready var projectile_spawn_point: Node3D = $ProjectileSpawnPoint
@onready var attack_timer: Timer = $AttackTimer

@onready var state_chart: StateChart = $StateChart
@onready var idle_state: AtomicState = %IdleState
@onready var chase_state: AtomicState = %ChaseState
@onready var attack_state: AtomicState = %AttackState
@onready var death_state: AtomicState = %DeathState

var can_attack := false
var health: float


func _ready() -> void:
	_update_from_resource()


func _update_from_resource() -> void:
	if not is_instance_valid(resource):
		return

	speed = resource.speed
	attack_range = resource.attack_range
	health = resource.health
	sprite.sprite_frames = resource.sprite_frames
	sprite.play(resource.default_animation)
	nav_agent.path_desired_distance = resource.attack_range
	attack_ray_cast.target_position.z = resource.attack_range
	sight_ray_cast.target_position.z = resource.sight_range


func update_target_position(target_position: Vector3) -> void:
	nav_agent.target_position = target_position


func _on_idle_state_state_entered() -> void:
	sight_ray_cast.enabled = true


func _on_idle_state_state_physics_processing(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var player := Game.get_player()
	if is_instance_valid(player):
		var direction := global_position.direction_to(player.global_position)
		sight_ray_cast.look_at(direction, Vector3.UP, true)

	if sight_ray_cast.is_colliding():
		var collider := sight_ray_cast.get_collider()
		if collider is Player:
			state_chart.send_event(EnemyStateEvent.CHASE)


func _on_chase_state_state_entered() -> void:
	sight_ray_cast.enabled = false
	attack_ray_cast.enabled = true


func _on_chase_state_state_physics_processing(delta: float) -> void:
	var current_position := global_transform.origin
	var next_position := nav_agent.get_next_path_position()
	var new_velocity := (next_position - current_position).normalized() * speed * delta

	velocity = velocity.move_toward(new_velocity, 0.25)

	move_and_slide()

	if global_position != next_position:
		look_at(next_position)

	if attack_ray_cast.is_colliding() and can_attack:
		var collider := attack_ray_cast.get_collider()

		if collider is Player:
			state_chart.send_event(EnemyStateEvent.ATTACK)


func _on_attack_state_state_physics_processing(_delta: float) -> void:
	Game.spawn_projectile(self, projectile_spawn_point)
	state_chart.send_event(EnemyStateEvent.CHASE)


func _on_attack_state_state_exited() -> void:
	pass  # Replace with function body.


func _on_attack_timer_timeout() -> void:
	can_attack = true


func _on_attack_state_state_entered() -> void:
	can_attack = false
	attack_timer.start()


func take_damage(damage: int) -> void:
	printt("took damage", damage)

	health -= damage
	if health <= 0:
		# TODO: death state
		queue_free()
