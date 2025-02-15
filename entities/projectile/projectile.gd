extends StaticBody3D
class_name Projectile

var velocity: Vector3 = Vector3.ZERO


func _physics_process(_delta: float) -> void:
	var collision := move_and_collide(velocity)
	if collision:
		var collider := collision.get_collider()
		if is_instance_valid(collider):
			queue_free()

			if collider.is_in_group("damageable"):
				collider.take_damage(10)


func _on_life_timer_timeout() -> void:
	queue_free()
