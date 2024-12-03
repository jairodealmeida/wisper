extends CanvasLayer

func _ready():
	print("ready")
	#GameManager.gained_coins.connect(update_coin_display) 

func update_coin_display(gained_coins):
	print("update_coin_display",gained_coins)
	#$CoinDisplay.text = str(GameManager.score)
