extends CharacterBody3D

@export var speed := 100.0

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D


func _ready() -> void:
	animated_sprite_3d.play("default")


func update_target_position(target_position: Vector3) -> void:
	nav_agent.target_position = target_position


func _physics_process(delta: float) -> void:
	var current_position := global_transform.origin
	var next_position := nav_agent.get_next_path_position()
	var new_velocity := (next_position - current_position).normalized() * speed * delta

	velocity = velocity.move_toward(new_velocity, 0.25)

	move_and_slide()
