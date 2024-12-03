extends Node

var score = 0
@onready var coin_display = $"../UIManager/CoinDisplay"
#@onready var multiplayer = $Multiplayer
@onready var multiplayer_hud = $"../MultiplayerHUD"

func _ready():
	coin_display.text = str(Global.coins)
	#Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		MultiplayerManager.become_host()

func add_point():
	Global.coins += 1
	coin_display.text = str(Global.coins)

func become_host():
	print("Become host pressed")
	multiplayer_hud.hide()
	MultiplayerManager.become_host()
	
func join_as_player_2():
	print("Join as player 2")
	multiplayer_hud.hide()
	MultiplayerManager.join_as_player_2()


func _on_host_game_pressed():
	become_host()


func _on_join_as_player_2_pressed():
	join_as_player_2()
