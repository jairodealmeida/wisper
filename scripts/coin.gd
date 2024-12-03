extends Area2D


#@onready var game_manager = %GameManager
@onready var game_manager = $"../../GameManager"
@onready var animation_player = $AnimationPlayer


func _on_body_entered(_body):
	if game_manager:
		game_manager.add_point()
	animation_player.play("pickup")
	#queue_free()
