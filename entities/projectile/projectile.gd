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
				AudioPlayer.play_sfx_array(resource.impact_sounds)


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
