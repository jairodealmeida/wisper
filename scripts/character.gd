# res://scripts/character.gd
extends CharacterBody2D

class_name Character

@export var current_health = 100
@export var max_health = 100
var is_dead = false
var is_hit = false

@onready var game_manager = %GameManager
@onready var animated_sprite = $AnimatedSprite2D
@onready var health_bar = $HealthBar


@export var coin_scene: PackedScene = preload("res://scenes/coin.tscn")
@export var drop_coins = 3
func drop_coins_on_death():
	randomize()
	var spread_range = 50  # Define o alcance do espalhamento no eixo X
	for i in range(drop_coins):
		var coin = coin_scene.instantiate()
		var offset_x = randf_range(-spread_range, spread_range)  # Gera um deslocamento aleatório no eixo X
		coin.position = global_position + Vector2(offset_x, 0)  # Aplica o deslocamento à posição da moeda
		coin.game_manager = game_manager
		get_parent().add_child(coin)

# Define uma enumeração para o time
@export var team: String = "team01" #setget set_team, get_team

var teams := ["team01", "team02"]

# Define um setter e getter para a propriedade `team`
func set_team(value: String) -> void:
	if value in teams:
		team = value
		# Atualize o grupo ao qual o nó pertence
		for t in teams:
			remove_from_group(t)
		add_to_group(team)

func get_team() -> String:
	return team
	
func _ready():
	set_team(team)
	
signal health_changed(current_health)
signal died()

func init(_current_health, _max_health):
	max_health = _max_health
	current_health = _current_health
	health_bar.max_value = max_health
	health_bar.value = current_health
	emit_signal("health_changed", current_health)
	
#func _enter_tree():
#	max_health = 100
#	current_health = 100

func apply_damage(value):
	if is_dead:
		return

	current_health -= value
	emit_signal("health_changed", current_health)
	health_bar.value = current_health

	if current_health <= 0:
		current_health = 0
		die()
	else:
		is_hit = true
		animated_sprite.play("hit")
		await _wait_and_reset_hit()

func _wait_and_reset_hit():
	await get_tree().create_timer(1).timeout
	is_hit = false
	animated_sprite.play("default")

func die():
	is_dead = true
	animated_sprite.play("death")
	emit_signal("died")
	animated_sprite.connect("animation_finished", _on_death_animation_finished)

func _on_death_animation_finished():
	animated_sprite.stop()
	# Implement specific death logic in the derived classes
