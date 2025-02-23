@tool
extends Node3D
class_name Spawner

const ENEMY = preload("res://entities/enemy/enemy.tscn")

const SPAWN_POINT_SPACING := 2.0

signal enemy_spawned(spawner: Spawner, enemy: Enemy)

@onready var timer: Timer = $Timer

## What kind of enemies to spawn and their accompanying spawn rates.
@export var enemies: Array[SpawnerResource] = []
## Set a limit on the number of enemies that can be spawned in total by this spawner.
## Zero means there is no limit.
@export_range(0, 99999) var spawn_limit: int = 0
## How many enemies to spawn at once.
@export_range(0, 99999) var spawn_amount: int = 1:
	set(value):
		spawn_amount = value
		if Engine.is_editor_hint():
			update_spawn_positions()

## How long (in seconds) to wait before spawning the next enemy round.
@export var spawn_timeout: float = 5.0
## Whether to spawn enemies immediately when the spawner is created.
@export var spawn_on_start: bool = true

var spawn_count := 0


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	spawnlevel(Waves.current_wave)
	Game.stationery_gui.text = "Stationery: " + str(len(Waves.spawnlist))

	if enemies.size() == 0:
		push_error("No enemies defined in spawner", self)
		queue_free()
		return

	update_spawn_positions()

	if spawn_on_start:
		timer.start(0.1)
	else:
		timer.start(spawn_timeout)


func spawn_enemies() -> void:
	if has_reached_spawn_limit():
		printt(self, "Spawn limit reached")
		queue_free()
		return

	var spawn_positions: Array[Vector3] = []
	for marker in get_node("SpawnMarkers").get_children():
		spawn_positions.append(marker.global_position)

	var spawn_target = get_spawn_target()
	for i in range(spawn_amount):
		spawn_enemy(spawn_positions[i], spawn_target)

	timer.start(spawn_timeout)


func has_reached_spawn_limit() -> bool:
	if spawn_limit == 0:
		return false

	return spawn_count >= spawn_limit


func spawn_enemy(global_spawn_position: Vector3, parent: Node3D) -> void:
	if not has_reached_spawn_limit():
		var enemy_resource := get_random_enemy()
		var enemy := ENEMY.instantiate()
		enemy.resource = enemy_resource
		enemy.top_level = true

		parent.add_child(enemy)
		Waves.spawnlist.append(enemy)
		Game.stationery_gui.text = "Stationery: " + str(len(Waves.spawnlist))
		enemy.global_position = global_spawn_position

		enemy_spawned.emit(self, enemy)

		spawn_count += 1


func _on_timer_timeout() -> void:
	spawn_enemies()


func get_random_enemy() -> EnemyResource:
	var total := 0.0
	for enemy in enemies:
		total += enemy.spawn_rate

	var r := randf_range(0, total)
	var current := 0.0
	for enemy in enemies:
		current += enemy.spawn_rate
		if r < current:
			return enemy.resource

	push_error("No enemy resource found")
	return enemies[0].resource


func update_spawn_positions() -> void:
	var spawn_area_bounds := get_spawn_area_bounds()

	var markers_root = get_node_or_null("SpawnMarkers")
	if not is_instance_valid(markers_root):
		markers_root = Node3D.new()
		markers_root.name = "SpawnMarkers"
		add_child(markers_root)

	markers_root.owner = self
	markers_root.position = Vector3.ZERO

	for child in markers_root.get_children():
		child.queue_free()

	var count := 0
	var rect := Rect2()
	for x in spawn_area_bounds.x:
		for y in spawn_area_bounds.y:
			count += 1
			var marker := Marker3D.new()
			marker.name = "Marker%d" % [count]
			markers_root.add_child(marker)
			marker.position = Vector3(x * SPAWN_POINT_SPACING, 0, y * SPAWN_POINT_SPACING)
			marker.owner = self
			rect = rect.expand(Vector2(x * SPAWN_POINT_SPACING, y * SPAWN_POINT_SPACING))

	var center := rect.get_center()
	markers_root.position -= Vector3(center.x, 0, center.y)


func get_spawn_area_bounds() -> Vector2i:
	if spawn_amount == 1:
		return Vector2i(1, 1)

	var num_points := spawn_amount if spawn_amount % 2 == 0 else spawn_amount + 1
	var sr := sqrt(num_points)
	var rows: int = floor(sr)
	var columns: int = ceil(sr)

	while rows * columns < num_points:
		if rows > columns:
			columns += 1
		else:
			rows += 1

	return Vector2i(rows, columns)


func get_spawn_target() -> Node3D:
	var level_node := get_tree().get_first_node_in_group("level")

	if not is_instance_valid(level_node.get_node_or_null("Enemies")):
		var spawn_target := Node3D.new()
		spawn_target.name = "Enemies"
		level_node.add_child(spawn_target)

	return level_node.get_node("Enemies")


func spawnlevel(level: int) -> void:
	spawn_limit = Waves.get_spawn_limit()
	spawn_amount = Waves.get_spawn_amount()
	spawn_timeout = 5
