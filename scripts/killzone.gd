extends Area2D

@onready var timer = $Timer
@export var is_npc = false

func _on_body_entered(body):
	
	if not MultiplayerManager.multiplayer_mode_enabled:
		print("You died!")
		if is_npc:
			body.apply_damage(10)
		else:
			body._on_death_animation_finished()
	else:
		_multiplayer_dead(body)
	timer.start()	


func _multiplayer_dead(body):
	if multiplayer.is_server() && body.alive:
		Engine.time_scale = 0.5
		body.mark_dead()

# TODO tem um lance estranho tem que fazer sim o slow motion, mas só 
# em uma hora que houver um golpe muito impactante na cena, e o time tiver gankando
# não esquecer que o slow é setado na linha 8
# REGRA junto > 2 X 2 envolvidos 
# Tenha especial evolvido
#func _on_timer_timeout():
#	Engine.time_scale = 1.0;
	#if !is_npc:
	#	get_tree().reload_current_scene()

#func _on_death_animation_finished():
#	animated_sprite.stop()
#	animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("death") - 1
	# Iniciar o Timer de respawn
#	respawn_timer.start(RESPAWN_TIME)
