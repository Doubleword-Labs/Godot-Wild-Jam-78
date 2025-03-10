extends Resource
class_name ProjectileResource

@export_group("Stats")
@export var speed: float = 10
@export var impact_damage: float = 10
@export var area_damage: float = 0
@export var area_radius: float = 0
@export var spread: float = 0

@export_group("Audio")
@export var spawn_sounds: Array[AudioStream] = []
@export var impact_sounds: Array[AudioStream] = []

@export_group("Collisions")
@export var collision_shape: Shape3D

@export_group("Visuals")
@export var scene: PackedScene
@export var show_projectile_hit: bool = true
@export var projectile_hit_scale: float = 1.0

@export_group("Misc")
@export var max_lifetime: float = 10
