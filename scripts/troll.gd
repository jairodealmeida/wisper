# res://scripts/troll.gd
extends "res://scripts/character.gd"

class_name Troll

const SPEED = 50.0
const JUMP_VELOCITY = -300.0
const DETECTION_RANGE = 20.0
const DIRECTION_CHANGE_DELAY = 0.5
const STUCK_TIME_THRESHOLD = 2.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var ray_cast = $RayCast2D
@onready var nick_name = $NickName
@onready var saber_level_1 = $SaberLevel1
@onready var collision_shape_2d = $CollisionShape2D
@onready var animated_sprite_2d = $AnimatedSprite2D

@onready var saber_collision = $SaberLevel1/CollisionPolygon2D
@onready var detection_area = $DetectionArea  # Certifique-se de ter uma DetectionArea configurada para detectar inimigos
signal facing_direction_changed(facing_right: bool)

var direction = 1
var can_change_direction = true
var time_since_last_change = 0.0
var last_position = Vector2()
var stuck_time = 0.0
var death_animation_finished = false

# Variável para definir direção inicial com base no time
var initial_direction = 1

func _draw():
	#var tower_global_position = global_position
	#var tower_global_position = detection_area.position
	var tower_global_position = to_local(global_position)
	#var tower_global_position = detection_area.get_global_transform().origin
	if detection_area!=null:
		var bodies = detection_area.get_overlapping_bodies()
		if bodies:
			for body in bodies:
				if body is Character and body.is_in_group("damageable"):
					#var body_global_position = body.position
					var body_global_position = body.to_local(global_position)
					# Inverter o eixo desejado, por exemplo, X e Y
					var inverted_body_position = Vector2(-body_global_position.x, -body_global_position.y)
					#if current_projectile:
					#	body_global_position = current_projectile.target.position
					if body.team != team :
						draw_line(tower_global_position, inverted_body_position, Color(1, 0, 0))
					else:
						draw_line(tower_global_position, inverted_body_position, Color(0, 0, 1))

func _ready():
	init(200,200)
	add_to_group("enemies")
	add_to_group("damageable")
	nick_name.text = "%s" % [team]
	_apply_team_color(animated_sprite_2d, team)
	
	# Define direção inicial com base no time
	if team == "team02":
		initial_direction = -1
	else:
		initial_direction = 1

	direction = initial_direction

func _apply_team_color(sprite, team):
	if sprite:
		if team == "team02":
			sprite.modulate = Color(0, 0, 1, 1)
		else:
			sprite.modulate = Color(1, 0, 0, 1)

func _physics_process(delta):
	if is_dead:
		velocity.x = 0
		if not is_on_floor():
			velocity.y += gravity * delta
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			if not death_animation_finished:
				animated_sprite.play("death")
		return
	
	process_gravity(delta)
	process_jump()
	process_obstacle_detection()
	process_direction_change(delta)
	process_stuck_detection(delta)
	process_enemy_detection()  # NOVO: Processa a detecção de inimigos
	update_character_position()
	update_animation()
	update_ray_cast()
	queue_redraw() 

func process_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func process_jump():
	if is_on_floor() and ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if is_colliders_characters(collider):  
			velocity.y = JUMP_VELOCITY
			#print("Colidiu com: ", collider);
			
func is_colliders_characters(collider):
	return not (collider is Projectile || collider is AiSaberLevel1)
		
func process_obstacle_detection():
	if ray_cast.is_colliding() and can_change_direction:
		change_direction()
	can_change_direction = false
	time_since_last_change = 0.0

func change_direction():
	# Mantém direção preferida, invertendo apenas se necessário
	if (team == "team01" and direction == -1) or (team == "team02" and direction == 1):
		direction = initial_direction  # Volta para a direção preferida
	else:
		direction = -direction  # Inverte se necessário

func process_direction_change(delta):
	if not can_change_direction:
		time_since_last_change += delta
	if time_since_last_change > DIRECTION_CHANGE_DELAY:
		can_change_direction = true

var loop_detection = false
var count_loop = 0
var last_x_position = 0.0

func process_stuck_detection(delta):
	var distance = position.distance_to(last_position)
	var x_distance = abs(position.x - last_x_position)

	if distance > 1:
		stuck_time += delta
		count_loop += 1
		loop_detection = true

	if stuck_time >= STUCK_TIME_THRESHOLD:
		unstuck_character()
		loop_detection = false
		count_loop = 0

	if x_distance > 1:
		unstuck_character()

	last_x_position = position.x

func unstuck_character():
	# Mantém direção preferida ao "destravar"
	#if (team == "team01") or (team == "team02"):
	#	direction = initial_direction  # Volta para a direção preferida
	#else:
	direction *= -1  # Inverte se necessário
	saber_level_1.direction = direction
	saber_level_1.attackPlay()
	reset_stuck_time()

func process_enemy_detection():
	# NOVO: Lógica para detectar e confrontar inimigos
	if detection_area: 
		var bodies = detection_area.get_overlapping_bodies()
		var enemy_detected = false
		
		for body in bodies:
			if body is Character and body.team != team:
				# Se um inimigo for detectado, mude a direção para ir em direção a ele
				var enemy_direction = sign(body.position.x - position.x)
				direction = enemy_direction
				enemy_detected = true
				break
		
		# Se nenhum inimigo for detectado, mantenha a direção preferida
		if not enemy_detected:
			direction = initial_direction

func _on_death_animation_finished():
	death_animation_finished = true
	animated_sprite.stop()
	animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("death") - 1
	collision_shape_2d.queue_free()
	drop_coins_on_death()
	queue_free()
	#game_manager.cure

func reset_stuck_time():
	stuck_time = 0

func update_character_position():
	if is_dead:
		return
	last_position = position
	velocity.x = direction * SPEED
	move_and_slide()

func update_animation():
	if is_dead:
		return
	animated_sprite.flip_h = direction != 1
	emit_signal("facing_direction_changed", !animated_sprite.flip_h)
	play_animation_based_on_state()

func play_animation_based_on_state():
	if is_hit:
		animated_sprite.play("hit")
	elif is_on_floor():
		animated_sprite.play("idle" if direction == 0 else "run")
	else:
		animated_sprite.play("jump")

func update_ray_cast():
	ray_cast.target_position = Vector2(DETECTION_RANGE * direction, 0)
	ray_cast.force_raycast_update()
