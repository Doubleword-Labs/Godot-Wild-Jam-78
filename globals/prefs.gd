extends Node

const CONFIG_FILE_PATH = "user://settings.cfg"

const DEFAULT_MOUSE_SENSITIVITY = 0.005
const DEFAULT_HEAD_BOB = 14.0
const DEFAULT_MASTER_VOLUME = 1.0
const DEFAULT_MUSIC_VOLUME = 0.4
const DEFAULT_SFX_VOLUME = 0.6

var _instance: ConfigFile

var mouse_sensitivity: float:
	get:
		return _instance.get_value("game", "mouse_sensitivity", DEFAULT_MOUSE_SENSITIVITY)
	set(value):
		_instance.set_value("game", "mouse_sensitivity", value)

var head_bob: float:
	get:
		return _instance.get_value("game", "head_bob", DEFAULT_HEAD_BOB)
	set(value):
		_instance.set_value("game", "head_bob", value)

var master_volume: float:
	get:
		return _instance.get_value("sound", "master_volume", DEFAULT_MASTER_VOLUME)
	set(value):
		_instance.set_value("sound", "master_volume", clamp(value, 0, 1))

var music_volume: float:
	get:
		return _instance.get_value("sound", "music_volume", DEFAULT_MUSIC_VOLUME)
	set(value):
		_instance.set_value("sound", "music_volume", clamp(value, 0, 1))

var sfx_volume: float:
	get:
		return _instance.get_value("sound", "sfx_volume", DEFAULT_SFX_VOLUME)
	set(value):
		_instance.set_value("sound", "sfx_volume", clamp(value, 0, 1))


func _ready() -> void:
	_instance = _load_config()
	printt("data directory:", OS.get_data_dir())


func _load_config() -> ConfigFile:
	var config := ConfigFile.new()
	config.load(CONFIG_FILE_PATH)
	return config


func _save_config(config_file: ConfigFile) -> void:
	config_file.save(CONFIG_FILE_PATH)


func save():
	_save_config(_instance)
