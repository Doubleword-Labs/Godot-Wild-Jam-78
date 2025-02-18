extends Node

enum WaveOperator {
	EQUAL, NOT_EQUAL, GREATER_THAN, LESS_THAN, GREATER_THAN_OR_EQUAL, LESS_THAN_OR_EQUAL, MOD
}

@export_range(0, 99999) var wave: int = 0
@export var operator := WaveOperator.EQUAL


func _ready() -> void:
	Waves.wave_started.connect(_on_wave_started)
	update_process_mode()


func update_process_mode(new_wave: int = Waves.current_wave) -> void:
	if should_process(new_wave):
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED


func _on_wave_started(new_wave: int) -> void:
	update_process_mode(new_wave)


func should_process(new_wave: int) -> bool:
	match operator:
		WaveOperator.EQUAL:
			return new_wave == wave
		WaveOperator.NOT_EQUAL:
			return new_wave != wave
		WaveOperator.GREATER_THAN:
			return new_wave > wave
		WaveOperator.LESS_THAN:
			return new_wave < wave
		WaveOperator.GREATER_THAN_OR_EQUAL:
			return new_wave >= wave
		WaveOperator.LESS_THAN_OR_EQUAL:
			return new_wave <= wave
		WaveOperator.MOD:
			return new_wave % wave == 0

	return false
