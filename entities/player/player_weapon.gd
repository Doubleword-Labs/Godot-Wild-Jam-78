extends Object
class_name PlayerWeapon

@export var resource: WeaponResource
@export var owned: bool = false


func _init(resource: WeaponResource, owned: bool = false) -> void:
	self.resource = resource
	self.owned = owned
