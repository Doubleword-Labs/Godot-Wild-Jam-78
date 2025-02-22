extends Resource
class_name WeaponResource

@export_group("Stats")
@export var melee_damage: float = 30.0
@export var melee_range: float = 100.0
@export var attack_timeout: float = 0.5

@export_group("Projectile")
@export var projectile_count: int = 1
@export var projectile_resource: ProjectileResource

@export_group("Animation")
@export var sprite_frames: SpriteFrames
@export var idle_animation := "default"
@export var attack_animation := "attack"
@export var sprite_position := Vector2.ZERO
@export var sprite_scale := Vector2.ONE
@export var attack_shaker_preset: ShakerPreset3D
@export var attack_shaker_duration: float = 0.1

@export_group("Audio")
@export var attack_sounds: Array[AudioStream] = []
