# res://scripts/player.gd
extends "res://scripts/character.gd"

class_name Player


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const RESPAWN_TIME = 5.0  # Tempo de respawn em segundos
@export var respawn_position = Vector2(0,0);

@export var damage = 500

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var saber_collision = $SaberLevel1/CollisionPolygon2D
@onready var saber_collision2 = $SaberLevel1/Area2D/CollisionPolygon2D
@onready var respawn_timer = $RespawnTimer  # Referência ao Timer de respawn
@onready var nick_name = $NickName
#@onready var synchronizer = $MultiplayerSynchronizer
#@export var synchronizer: MultiplayerSynchronizer
signal facing_direction_changed(facing_right: bool)

func _ready():
	 # Configura o MultiplayerSynchronizer (supondo que ele seja um filho do Player)
	#synchronizer = $MultiplayerSynchronizer
	# Configura o MultiplayerSynchronizer para sincronizar a posição e rotação
	#var synchronizer = MultiplayerSynchronizer.new()
	#add_child(synchronizer)
	
	# Registra as propriedades para sincronização
	#synchronizer.synchronize("position")
	#synchronizer.synchronize("rotation")
	
	init(200,200)

	add_to_group("enemies")
	add_to_group("damageable")
	nick_name.text = "%s" % [team]
	# Conectar o sinal timeout do respawn_timer ao método _on_respawn_timer_timeout
	respawn_timer.connect("timeout", _on_respawn_timer_timeout)
	drop_coins = Global.coins
	
#func _enter_tree():
	#const seed = random.getrandbits(32)
	#print(multiplayer.get_unique_id())
	##set_multiplayer_authority(nick_name.to_int())	
	#if multiplayer.is_server():
	#	set_multiplayer_authority(multiplayer.get_unique_id())
	
func _physics_process(delta):
	
	if is_dead:
		return

	#if is_multiplayer_authority():
	if is_multiplayer_authority():
		handle_movement(delta)
		update_animation()

func handle_movement(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	emit_signal("facing_direction_changed", !animated_sprite.flip_h)

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func update_animation():
	if is_hit:
		animated_sprite.play("hit")
	elif is_on_floor():
		if velocity.x == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

func _on_death_animation_finished():
	animated_sprite.stop()
	animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("death") - 1
	# Iniciar o Timer de respawn
	#queue_free()
	respawn_timer.start(RESPAWN_TIME)

func _on_respawn_timer_timeout():
	# Resetar as propriedades do jogador para respawn
	is_dead = false
	velocity = Vector2.ZERO
	position = respawn_position #Vector2(200, 200)  # Defina a posição de respawn desejada
	animated_sprite.play("idle")  # Voltar a animação para "idle"
	init(max_health,max_health)
	respawn_timer.stop()
