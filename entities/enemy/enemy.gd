@tool
extends CharacterBody3D
class_name Enemy

const EnemyStateEvent = {
	AWAKEN = "awaken",
	ACTIVE = "active",
	CHASE = "chase",
	ATTACK = "attack",
	PAIN = "pain",
	DEATH = "death",
}

const FIREBALL_PROJECTILE = preload("res://entities/projectile/resources/fireball.tres")

@export_tool_button("Update from resource") var update_from_resource_button := update_from_resource

@export var resource: EnemyResource:
	set(value):
		resource = value
		if Engine.is_editor_hint():
			update_from_resource()

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
var received_damage := false


func _ready() -> void:
	update_from_resource()


func update_from_resource() -> void:
	if not is_instance_valid(resource):
		return

	speed = resource.speed
	attack_range = resource.attack_range
	health = resource.health

	if is_instance_valid(sprite):
		sprite.sprite_frames = resource.sprite_frames
		sprite.animation = resource.default_animation
		sprite.offset = resource.sprite_offset
		if not Engine.is_editor_hint():
			sprite.speed_scale = randf_range(0.85, 1.25)
			sprite.play(resource.default_animation)

	if is_instance_valid(nav_agent):
		nav_agent.path_desired_distance = resource.attack_range

	if is_instance_valid(attack_ray_cast):
		attack_ray_cast.target_position.z = resource.attack_range

	if is_instance_valid(sight_ray_cast):
		sight_ray_cast.target_position.z = resource.sight_range


func update_target_position(target_position: Vector3) -> void:
	nav_agent.target_position = target_position


func _on_idle_state_state_entered() -> void:
	sight_ray_cast.enabled = true
	sprite.play(resource.default_animation)


func _on_idle_state_state_physics_processing(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var player := Game.get_player()
	if is_instance_valid(player):
		sight_ray_cast.look_at(player.global_position, Vector3.UP, true)

	if sight_ray_cast.is_colliding():
		var collider := sight_ray_cast.get_collider()
		if collider is Player:
			state_chart.send_event(EnemyStateEvent.AWAKEN)

	if received_damage:
		state_chart.send_event(EnemyStateEvent.AWAKEN)


func _on_chase_state_state_entered() -> void:
	sight_ray_cast.enabled = false
	attack_ray_cast.enabled = true
	sprite.play(resource.default_animation)


func _on_chase_state_state_physics_processing(delta: float) -> void:
	var current_position := global_transform.origin
	var next_position := nav_agent.get_next_path_position()
	var new_velocity := (next_position - current_position).normalized() * speed * delta

	nav_agent.velocity = new_velocity

	if global_position != next_position:
		look_at(next_position)

	if attack_ray_cast.is_colliding() and can_attack:
		var collider := attack_ray_cast.get_collider()

		if collider is Player:
			state_chart.send_event(EnemyStateEvent.ATTACK)


func _on_attack_state_state_exited() -> void:
	pass  # Replace with function body.


func _on_attack_timer_timeout() -> void:
	can_attack = true


func _on_attack_state_state_entered() -> void:
	can_attack = false
	var attack_timeout := randf_range(resource.attack_timeout * 0.5, resource.attack_timeout * 2.0)
	attack_timer.start(attack_timeout)
	sprite.play(resource.attack_animation)

	await sprite.animation_finished

	state_chart.send_event(EnemyStateEvent.CHASE)


func take_damage(damage: int, from_player: bool) -> void:
	if from_player:
		print(damage)
		if Buff.player_damage:
			damage = damage * 2
		print(damage)
		health -= damage
		
		if Buff.player_vampire:
			Game.get_player().health += damage
			Game.hp_gui.value = Game.get_player().health
			
		if health <= 0:
			state_chart.send_event(EnemyStateEvent.DEATH)
		else:
			received_damage = true
			state_chart.send_event(EnemyStateEvent.PAIN)


func _on_pain_state_state_entered() -> void:
	var audio_player := AudioPlayer.play_sfx_3d_array(AudioPlayer.pain_enemy_arr)
	if is_instance_valid(audio_player):
		audio_player.global_position = global_position

	sprite.play(resource.pain_animation)


func _on_death_state_state_entered() -> void:
	var audio_player := AudioPlayer.play_sfx_3d_array(AudioPlayer.died_enemy_arr)
	if is_instance_valid(audio_player):
		audio_player.global_position = global_position

	sprite.play(resource.death_animation)
	await sprite.animation_finished
	queue_free()
	Waves.prune_spawnlist()
	Game.stationery_gui.text = "Stationery: " + str(len(Waves.spawnlist))
	if len(Waves.spawnlist) == 0:
		Game.win()


func _on_animated_sprite_3d_animation_finished() -> void:
	if sprite.animation == resource.pain_animation:
		state_chart.send_event(EnemyStateEvent.ACTIVE)


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()


func _on_animated_sprite_3d_frame_changed() -> void:
	if is_instance_valid(sprite) and sprite.animation == resource.attack_animation:
		if sprite.frame == resource.attack_frame:
			Game.spawn_projectile(self, projectile_spawn_point, FIREBALL_PROJECTILE)
