extends StaticBody3D
class_name Projectile

const projectile_spawed_sfx_arr = [
	preload("res://assets/sfx/projectile_spawned/paper crunch 1.wav"),
	preload("res://assets/sfx/projectile_spawned/paper crunch 2.wav"),
	preload("res://assets/sfx/projectile_spawned/paper crunch 3.wav"),
	preload("res://assets/sfx/projectile_spawned/paper crunch 4.wav"),
	preload("res://assets/sfx/projectile_spawned/plastic crunch 15.wav"),
	preload("res://assets/sfx/projectile_spawned/plastic crunch 16.wav"),
	preload("res://assets/sfx/projectile_spawned/plastic crunch 21.wav")
]
var spawned_by: Node3D
var velocity: Vector3 = Vector3.ZERO
var resource: Resource
var from_player: bool = true

func _ready() -> void:
	if (spawned_by is Player):
		AudioPlayer.play_sfx_array(projectile_spawed_sfx_arr)

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var collider := collision.get_collider()
		if is_instance_valid(collider):
			queue_free()

			if collider.is_in_group("damageable"):
				collider.take_damage(10, from_player)


func _on_life_timer_timeout() -> void:
	queue_free()
