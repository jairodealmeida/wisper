extends Node

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
var players = []

const PORT = 7000
const HOST = "localhost"

func _ready():
	pass

func _process(delta):
	pass

func _on_host_button_button_down():
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	_start_game()ddd

func _on_join_button_button_down():
	peer.create_client(HOST, PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	_start_game()

func _on_start_game_button_button_down():
	StartGame.rpc()

@rpc("any_peer", "call_local")
func StartGame():
	_start_game()

func _start_game():
	var scene = load("res://scenes/game.tscn").instantiate()
	get_tree().root.add_child(scene)
	_add_player(scene, multiplayer.get_unique_id())

func _on_peer_connected(id):
	print("Peer connected: ", id)
	# Adiciona o player para o novo peer conectado
	_add_player(get_tree().current_scene, id)

func _add_player(scene, id):
	# Instancia o player
	var player = player_scene.instantiate()
	player.name = str(id)

	# Configura a autoridade do player
	if id == multiplayer.get_unique_id():
		player.set_multiplayer_authority(id)

	# Adiciona o player à cena específica de jogo
	scene.add_child(player)
	players.append(player)
