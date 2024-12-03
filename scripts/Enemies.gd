# res://scripts/enemies.gd
extends Node
@export var troll_scene: PackedScene
@export var neutral_scene: PackedScene
@export var aliance_scene: PackedScene

@export var max_trolls: int = 50
@export var max_neutrals: int = 50
@export var max_aliance: int = 50
@export var spawn_speller: int = 10

@export var spawn_interval: float = 10.0

@onready var troll_spawn_points = $TrollSpawnPoints.get_children()
@onready var neutral_spawn_points = $NeutralSpawnPoints.get_children()
@onready var aliance_spawn_points = $AlianceSpawnPoints.get_children()

@onready var enemies = $"."

var current_trolls = 0
var current_neutrals = 0
var current_aliance = 0

func _ready():
	var troll_timer = Timer.new()
	troll_timer.wait_time = spawn_interval
	troll_timer.connect("timeout", _on_troll_timer_timeout)
	enemies.add_child(troll_timer)
	troll_timer.start()

	var neutral_timer = Timer.new()
	neutral_timer.wait_time = spawn_interval
	neutral_timer.connect("timeout", _on_neutral_timer_timeout)
	enemies.add_child(neutral_timer)
	neutral_timer.start()

	var aliance_timer = Timer.new()
	aliance_timer.wait_time = spawn_interval
	aliance_timer.connect("timeout", _on_aliance_timer_timeout)
	enemies.add_child(aliance_timer)
	aliance_timer.start()

	_spawn_initial_characters()

func _spawn_initial_characters():
	for i in range(min(max_trolls, troll_spawn_points.size())):
		_spawn_troll(troll_spawn_points[i].global_position)

	for i in range(min(max_neutrals, neutral_spawn_points.size())):
		_spawn_neutral(neutral_spawn_points[i].global_position)

	for i in range(min(max_aliance, aliance_spawn_points.size())):
		_spawn_aliance(aliance_spawn_points[i].global_position)

func _spawn_troll(position):
	if current_trolls >= max_trolls:
		return
	if troll_scene:	
		for i in spawn_speller:
			var troll_instance = troll_scene.instantiate()
			troll_instance.team = "team02"
			var random_offset = Vector2(
				randf_range(-10, 10), 
				randf_range(-10, 10)  
			)
			troll_instance.position = position + random_offset
			enemies.add_child(troll_instance)
			troll_instance.add_to_group("enemies")
			troll_instance.add_to_group("damageable")
			troll_instance.visible = true  # Certifique-se de que o NPC está visível
			current_trolls += 1

func _spawn_neutral(position):
	if current_neutrals >= max_neutrals:
		return
	if neutral_scene:	
		for i in spawn_speller:
			var neutral_instance = neutral_scene.instantiate()
			neutral_instance.team = "neutral"
			var random_offset = Vector2(
				randf_range(-10, 10), 
				randf_range(-10, 10)  
			)
			neutral_instance.position = position + random_offset
			enemies.add_child(neutral_instance)
			neutral_instance.add_to_group("neutrals")
			neutral_instance.add_to_group("damageable")
			neutral_instance.visible = true  # Certifique-se de que o NPC está visível
			current_neutrals += 1

func _spawn_aliance(position):
	if current_aliance >= max_aliance:
		return
	if aliance_scene:
		for i in spawn_speller:
			var aliance_instance = aliance_scene.instantiate()
			aliance_instance.team = "team01"
			var random_offset = Vector2(
				randf_range(-10, 10), 
				randf_range(-10, 10)  
			)
			aliance_instance.position = position + random_offset
			enemies.add_child(aliance_instance)
			aliance_instance.add_to_group("aliance")
			aliance_instance.add_to_group("damageable")
			aliance_instance.visible = true  # Certifique-se de que o NPC está visível
			current_aliance += 1

			

func _on_troll_timer_timeout():
	if current_trolls < max_trolls:
		_spawn_troll(get_next_spawn_point(troll_spawn_points))

func _on_neutral_timer_timeout():
	if current_neutrals < max_neutrals:
		_spawn_neutral(get_next_spawn_point(neutral_spawn_points))

func _on_aliance_timer_timeout():
	if current_aliance < max_aliance:
		_spawn_aliance(get_next_spawn_point(aliance_spawn_points))

func get_next_spawn_point(spawn_points):
	if spawn_points.size() == 0:
		return Vector2.ZERO
	return spawn_points[randi() % spawn_points.size()].global_position
