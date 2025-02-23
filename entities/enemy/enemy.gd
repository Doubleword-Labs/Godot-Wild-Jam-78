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
const RANGED_ATTACK_SOUND = preload("res://assets/sfx/enemies/shared/ranged_attack.ogg")

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
@onready var roam_timer: Timer = $RoamTimer
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var state_label_debug: Label3D = $StateLabelDebug
@onready var damage_labels: Node3D = $DamageLabels
@onready var damage_label: Label3D = $DamageLabels/DamageLabel

@onready var state_chart: StateChart = $StateChart
@onready var idle_state: AtomicState = %IdleState
@onready var chase_state: AtomicState = %ChaseState
@onready var attack_state: AtomicState = %AttackState
@onready var death_state: AtomicState = %DeathState

var can_attack := false
var health: float
var received_damage := false
var audio_player: AudioStreamPlayer3D

var is_chasing := false
var is_attacking := false


func _ready() -> void:
	if is_instance_valid(state_label_debug):
		state_label_debug.visible = OS.is_debug_build()

	damage_label.hide()
	update_from_resource()


func _enter_tree() -> void:
	if is_instance_valid(state_label_debug):
		state_label_debug.visible = OS.is_debug_build()


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
	state_label_debug.text = "Idle"
	sight_ray_cast.enabled = true
	sprite.animation = resource.default_animation
	sprite.stop()


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
	is_chasing = true
	state_label_debug.text = "Chase"
	sight_ray_cast.enabled = false
	attack_ray_cast.enabled = true
	sprite.play(resource.default_animation)


func _on_chase_state_state_physics_processing(delta: float) -> void:
	if attack_ray_cast.is_colliding() and can_attack:
		var collider := attack_ray_cast.get_collider()

		if collider is Player:
			state_chart.send_event(EnemyStateEvent.ATTACK)
			velocity = Vector3.ZERO
			move_and_slide()
			return

	var current_position := global_transform.origin
	var next_position := nav_agent.get_next_path_position()
	var new_velocity = current_position.direction_to(next_position).normalized() * speed * delta

	nav_agent.velocity = new_velocity

	if global_position != next_position:
		look_at(next_position)


func _on_attack_state_state_exited() -> void:
	is_attacking = false


func _on_attack_timer_timeout() -> void:
	can_attack = true


func _on_attack_state_state_entered() -> void:
	is_attacking = true

	state_label_debug.text = "Attack"

	can_attack = false
	var attack_timeout := randf_range(resource.attack_timeout * 0.5, resource.attack_timeout * 2.0)
	sprite.play(resource.attack_animation)

	await sprite.animation_finished

	attack_timer.start(attack_timeout)
	state_chart.send_event(EnemyStateEvent.CHASE)


func take_damage(damage: int, from_player: bool) -> void:
	if from_player:
		if Buff.player_damage:
			damage = damage * 2

		health -= damage

		if Buff.player_vampire:
			var vamp_damage = damage / 50.0
			Game.get_player().health += vamp_damage
			Game.hp_gui.value = Game.get_player().health
			if Game.hp_gui.value > Game.hp_gui.max_value:
				Game.hp_gui.value = Game.hp_gui.max_value

		if health <= 0:
			state_chart.send_event(EnemyStateEvent.DEATH)
		else:
			received_damage = true

			# pain chance
			var pain_chance_roll = randf()
			if pain_chance_roll <= resource.pain_chance:
				state_chart.send_event(EnemyStateEvent.PAIN)

		_show_damage_label(damage)


func _show_damage_label(damage: int) -> void:
	var label: Label3D = damage_label.duplicate()
	label.text = str(damage)
	label.show()
	damage_labels.add_child(label)
	label.position = Vector3(randf_range(-0.5, 0.5), 0, 0)

	var target_position := Vector3(randf_range(-0.5, 0.5), randf_range(0, 0.5), 0)
	var target_modulate = label.modulate * Color(1, 1, 1, 0)
	var target_outline_modulate = label.outline_modulate * Color(1, 1, 1, 0)

	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(label, "position", target_position, 1.0)
	tween.tween_property(label, "modulate", target_modulate, 1.0)
	tween.tween_property(label, "outline_modulate", target_outline_modulate, 1.0)

	await tween.finished

	label.queue_free()


func play_sound(sound: AudioStream, override: bool = false) -> bool:
	if not is_instance_valid(sound):
		return false

	if is_instance_valid(audio_player) and audio_player.playing:
		if override:
			audio_player.stop()
		else:
			return false

	audio_player = AudioPlayer.play_sfx_3d(sound)
	if is_instance_valid(audio_player):
		audio_player.global_position = global_position
		return true

	return false


func get_current_audio_stream() -> AudioStream:
	if is_instance_valid(audio_player):
		return audio_player.stream

	return null


func _on_pain_state_state_entered() -> void:
	state_label_debug.text = "Pain"
	play_sound(resource.pain_sound, get_current_audio_stream() != resource.pain_sound)
	sprite.play(resource.pain_animation)


func _on_death_state_state_entered() -> void:
	state_label_debug.text = "Death"
	collision_shape.disabled = true
	play_sound(resource.death_sound, true)
	sprite.play(resource.death_animation)
	await sprite.animation_finished
	queue_free()
	Waves.prune_spawnlist()
	if Game.stationery_gui != null:
		Game.stationery_gui.text = "Stationery: " + str(len(Waves.spawnlist))
	if len(Waves.spawnlist) == 0:
		Game.win()


func _on_animated_sprite_3d_animation_finished() -> void:
	if sprite.animation == resource.pain_animation:
		state_chart.send_event(EnemyStateEvent.ACTIVE)


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, 0.25)
	move_and_slide()


func _get_projectile_resource() -> ProjectileResource:
	if is_instance_valid(resource.projectile_resource):
		return resource.projectile_resource
	else:
		return FIREBALL_PROJECTILE


func _on_animated_sprite_3d_frame_changed() -> void:
	if is_instance_valid(sprite):
		if is_attacking and sprite.frame == resource.attack_frame:
			play_sound(resource.attack_sound, true)

			match resource.attack_type:
				EnemyResource.AttackType.Ranged:
					_ranged_attack()
				EnemyResource.AttackType.Melee:
					_melee_attack()

		if is_chasing and sprite.frame == resource.chase_animation_frame:
			play_sound(resource.chase_sound, true)


func _ranged_attack() -> void:
	var player := Game.get_player()
	if not is_instance_valid(player):
		return

	var player_vel := player.velocity
	var player_pos := player.global_position
	var enemy_pos := global_position
	var proj_speed := _get_projectile_resource().speed

	var to_player := player_pos - enemy_pos
	var relative_vel := player_vel
	var speed_sq := proj_speed * proj_speed

	var a := relative_vel.length_squared() - speed_sq
	var b := 2 * to_player.dot(relative_vel)
	var c := to_player.length_squared()

	var t := _calculate_intercept_time(a, b, c)
	var predicted_pos := (
		player_pos + player_vel * t
		if t > 0
		else _fallback_prediction(to_player, player_pos, player_vel, proj_speed)
	)

	var attack_dir := enemy_pos.direction_to(predicted_pos)
	Game.spawn_projectile(self, attack_dir, projectile_spawn_point, _get_projectile_resource())

	play_sound(
		(
			RANGED_ATTACK_SOUND
			if resource.ranged_attack_sound == null
			else resource.ranged_attack_sound
		)
	)


func _calculate_intercept_time(a: float, b: float, c: float) -> float:
	if is_zero_approx(a):  # More robust floating point check
		return -c / b if !is_zero_approx(b) else -1.0

	var disc := b * b - 4 * a * c
	if disc < 0:
		return -1.0

	var sqrt_disc := sqrt(disc)
	var t1 := (-b + sqrt_disc) / (2 * a)
	var t2 := (-b - sqrt_disc) / (2 * a)

	# Handle edge cases with move_toward
	return _select_positive_time(t1, t2)


func _select_positive_time(t1: float, t2: float) -> float:
	var candidates := []
	if t1 > 0:
		candidates.append(t1)
	if t2 > 0:
		candidates.append(t2)

	if candidates.is_empty():
		return -1.0
	elif candidates.size() == 1:
		return candidates[0]

	# Prefer smallest positive time using minf
	return minf(candidates[0], candidates[1])


func _fallback_prediction(
	to_player: Vector3, player_pos: Vector3, player_vel: Vector3, proj_speed: float
) -> Vector3:
	var time_est := clampf(to_player.length() / proj_speed, 0.0, 5.0)  # Add sane limits
	return player_pos + player_vel * time_est


func _melee_attack() -> void:
	var player := Game.get_player()
	if not is_instance_valid(player):
		return

	var distance_to_player := player.global_position.distance_to(global_position)
	if distance_to_player <= resource.attack_range:
		player.take_damage(resource.melee_damage, false)


func _on_idle_state_state_exited() -> void:
	play_sound(resource.awake_sound)
	_start_roam_timer()


func _on_roam_timer_timeout() -> void:
	play_sound(resource.roam_sound)
	_start_roam_timer()


func _start_roam_timer() -> void:
	var timeout := randf_range(2.0, 10.0)
	roam_timer.start(timeout)


func _on_chase_state_state_exited() -> void:
	is_chasing = false
