extends StaticBody3D
class_name Projectile

var spawned_by: Node3D
var velocity: Vector3 = Vector3.ZERO
var resource: Resource


func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider := collision.get_collider()
		if is_instance_valid(collider):
			queue_free()

			if collider.is_in_group("damageable"):
				collider.take_damage(10)


func _on_life_timer_timeout() -> void:
	queue_free()
