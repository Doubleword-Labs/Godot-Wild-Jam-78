extends Level

@onready var player: Player = $Player


func _ready() -> void:
	super()

	for weapon in player.weapons:
		weapon.owned = true
