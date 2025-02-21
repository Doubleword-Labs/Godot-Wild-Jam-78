@tool
extends StaticBody3D
class_name Projectile

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var life_timer: Timer = $LifeTimer

@export_tool_button("Update from resource") var update_from_resource_action = update_from_resource

@export var resource: ProjectileResource:
	set(value):
		resource = value
		update_from_resource()

var spawned_by: Node3D
var velocity: Vector3 = Vector3.ZERO


func _ready() -> void:
	update_from_resource()

	if Engine.is_editor_hint():
		return

	if spawned_by is Player:
		AudioPlayer.play_sfx_array(resource.spawn_sounds)
	else:
		var audio_player := AudioPlayer.play_sfx_3d_array(resource.spawn_sounds)
		if is_instance_valid(audio_player):
			audio_player.global_position = global_position

	life_timer.start(resource.max_lifetime)

	if not is_zero_approx(resource.spread):
		var spread := resource.spread
		printt("spread", spread)

		var yaw := randfn(0.0, spread)
		var pitch := randfn(0.0, spread)

		var yaw_rotation := Quaternion(global_transform.basis.y, deg_to_rad(yaw))
		var pitch_rotation := Quaternion(global_transform.basis.x, deg_to_rad(pitch))
		var combined_rotation := yaw_rotation * pitch_rotation

		velocity = velocity * combined_rotation


func _enter_tree() -> void:
	update_from_resource()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	var collision := move_and_collide(velocity * delta * resource.speed)
	if collision:
		var collider := collision.get_collider()
		if is_instance_valid(collider):
			queue_free()

			if collider.is_in_group("damageable"):
				collider.take_damage(resource.impact_damage, spawned_by is Player)

				var audio_player := AudioPlayer.play_sfx_3d_array(resource.impact_sounds)
				if is_instance_valid(audio_player):
					audio_player.global_position = global_position


func _on_life_timer_timeout() -> void:
	queue_free()


func update_from_resource() -> void:
	if not is_instance_valid(resource):
		return

	if is_instance_valid(collision_shape):
		collision_shape.shape = resource.collision_shape

	var existing := get_node_or_null("ProjectileVisual")
	if is_instance_valid(existing):
		existing.free()

	var visual := resource.scene.instantiate()
	visual.name = "ProjectileVisual"
	add_child(visual)
