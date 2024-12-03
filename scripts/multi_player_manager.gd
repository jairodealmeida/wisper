extends Node
## TODO controller alterar para player
const SERVER_PORT = 8080
const SERVER_IP = "localhost"

var multiplayer_scene = preload("res://scenes/multi_player_play.tscn")

var _players_spawn_node
var host_mode_enabled = false
var multiplayer_mode_enabled = false
var respawn_point = Vector2(30, 20)
var is_server = false

func become_host():
	print("Starting host!")
	is_server = true
	_players_spawn_node = get_tree().get_current_scene().get_node("Players")
	
	multiplayer_mode_enabled = true
	host_mode_enabled = true
	
	var server_peer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	
	multiplayer.multiplayer_peer = server_peer
	
	multiplayer.peer_connected.connect(_add_player_to_game)
	multiplayer.peer_disconnected.connect(_del_player)
	
	_remove_single_player()
	
	if not OS.has_feature("dedicated_server"):
		_add_player_to_game(1)
	
"""func join_as_player_2():
	print("Player 2 joining")
	
	multiplayer_mode_enabled = true
	
	var client_peer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	#client_peer.get_packet_error()
	multiplayer.multiplayer_peer = client_peer
	
	_remove_single_player()
"""
func join_as_player_2():
	print("Player 2 tentando se conectar como cliente...")

	multiplayer_mode_enabled = true
	
	var client_peer = ENetMultiplayerPeer.new()
	var result = client_peer.create_client(SERVER_IP, SERVER_PORT)

	# Checando se a conexão foi estabelecida com sucesso
	if result == OK:
		print("Cliente tentando conectar ao servidor.")
		multiplayer.multiplayer_peer = client_peer
	else:
		print("Falha ao tentar conectar. Código de erro: %d" % result)
		print(get_error_message(result))  # Exibe mensagem de erro correspondente
		return  # Sai da função se a conexão falhou

	# Aguarda um frame para garantir que a conexão seja processada
	#await get_tree().process_frame

	# Verifica o status da conexão
	var connection_status = client_peer.get_connection_status()
	if connection_status != MultiplayerPeer.CONNECTION_CONNECTED:
		print("Erro na conexão! Status atual: %d" % connection_status)
		print(get_error_message(connection_status))  # Exibe mensagem para status de conexão

		# Para cliente, basta desativar o multiplayer_peer para desconectar
		#multiplayer.multiplayer_peer = null
		print("Cliente desconectado devido a erro.")
	else:
		print("Cliente conectado com sucesso ao servidor!")
		_remove_single_player()  # Remove o single player se a conexão foi bem-sucedida

# Função para traduzir o código de erro para uma mensagem
func get_error_message(error_code: int) -> String:
	match error_code:
		OK:
			return "Conexão bem-sucedida."
		ERR_CANT_CREATE:
			return "Não foi possível criar o cliente."
		#ERR_CONNECTION_REFUSED:
		#	return "Conexão recusada pelo servidor."
		ERR_CONNECTION_ERROR:
			return "Erro de conexão."
		ERR_ALREADY_IN_USE:
			return "A porta já está em uso."
		ERR_TIMEOUT:
			return "Tempo limite de conexão excedido."
		#ERR_SERVER_DISCONNECTED:
		#	return "Desconectado do servidor."
		MultiplayerPeer.CONNECTION_DISCONNECTED:
			return "Desconectado do servidor."
		MultiplayerPeer.CONNECTION_CONNECTING:
			return "Tentando conectar ao servidor..."
		MultiplayerPeer.CONNECTION_CONNECTED:
			return "Conectado com sucesso."
		_:
			return "Erro desconhecido com código: %d" % error_code
			
var players = []			
func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)
	if multiplayer_scene == null:
		print("multiplayer_scene não foi carregada corretamente!")
		return

	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	# Verificar se o servidor é a autoridade
	if is_server:
		player_to_add.set_multiplayer_authority(id)  # O servidor define autoridade para o jogador
	else:
		player_to_add.set_multiplayer_authority(multiplayer.get_unique_id())  # O cliente deve usar sua própria autoridade
	players.append(id)
	_players_spawn_node.add_child(player_to_add, true)
	
func _del_player(id: int):
	print("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
	
func _remove_single_player():
	print("Remove single player")
	var player_to_remove = get_tree().get_current_scene().get_node("Player")
	if player_to_remove:
		player_to_remove.queue_free()
	
	
	
	
	
	
	
	
	
	
	
