extends Node

@export var player_scene: PackedScene
var root: Node

func _ready():
	# Verifica se a root está configurada
	if root == null:
		root = get_tree().current_scene

func spawn_player(id = -1):
	# Se o ID não for fornecido, usamos o ID do peer local
	if id == -1:
		id = multiplayer.get_unique_id()

	var player = player_scene.instantiate()
	player.name = "Player" + str(id)

	# Define a autoridade do player
	player.set_multiplayer_authority(id)

	# Adiciona o player à cena root
	root.add_child(player)
