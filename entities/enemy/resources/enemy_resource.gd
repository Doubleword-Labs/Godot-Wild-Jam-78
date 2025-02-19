extends Resource
class_name EnemyResource

@export_group("Stats")
@export var attack_range := 5.0
@export var attack_timeout := 2.0
@export var sight_range := 15.0
@export var speed := 100.0
@export var health := 10.0

@export_group("Animations")
@export var sprite_frames: SpriteFrames
@export var sprite_offset := Vector2.ZERO
@export var default_animation := "default"
@export var attack_animation := "attack"
@export var attack_frame := 0
@export var pain_animation := "pain"
@export var death_animation := "death"

@export_group("Collisions")
@export var collision_shape: Shape3D
