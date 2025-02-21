extends StaticBody3D
class_name Projectile

var spawned_by: Node3D
var velocity: Vector3 = Vector3.ZERO
var resource: ProjectileResource


func _ready() -> void:
	if spawned_by is Player:
		AudioPlayer.play_sfx_array(AudioPlayer.projectile_spawed_sfx_arr)


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta * resource.speed)
	if collision:
		var collider := collision.get_collider()
		if is_instance_valid(collider):
			queue_free()

			if collider.is_in_group("damageable"):
				collider.take_damage(resource.impact_damage, spawned_by is Player)


func _on_life_timer_timeout() -> void:
	queue_free()
