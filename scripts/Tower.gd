extends "res://scripts/character.gd"

class_name Tower

const DETECTION_RANGE = 200.0  # Alcance da detecção da torre
const PROJECTILE_SPEED = 300.0
const TIMEOUT_DURATION = 1.0  # Tempo antes do timeout do projétil

@export var projectile_scene: PackedScene = preload("res://scenes/Projectile.tscn")

@onready var detection_area = $DetectionArea
@onready var fixed_position = position
@onready var timer = $ProjectileTimer
var death_animation_finished = false
var target = null
var current_projectile = null
@onready var collision = $CollisionPolygon2D
@onready var nick_name = $NickName

signal facing_direction_changed(facing_right: bool)

# var bodies_in_area = []
# var bodies = []

# Função para desenhar linhas até os personagens que entram na área de ataque
func _draw():
	#var tower_global_position = global_position
	#var tower_global_position = detection_area.position
	var tower_global_position = to_local(global_position)
	#var tower_global_position = detection_area.get_global_transform().origin
	if detection_area!=null:
		var bodies = detection_area.get_overlapping_bodies()
		if bodies:
			for body in bodies:
				if body is Character and !body is Tower and body.is_in_group("damageable"):
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
	init(500, 500)
	add_to_group("enemies")
	add_to_group("damageable")
	nick_name.text = "%s" % [team]

	if detection_area:
		detection_area.connect("body_entered", _on_body_entered)
		detection_area.connect("body_exited", _on_body_exited)
	else:
		print("Error: detection_area is not properly referenced.")
	timer.wait_time = TIMEOUT_DURATION
	timer.connect("timeout", _on_timer_timeout)
	connect("timein", _on_timer_timein)
	animated_sprite.play("default")

func _physics_process(delta):
	position = fixed_position

	if is_dead:
		handle_death()
		#is_dead=false;
		return
	
	
		
	if not current_projectile:
		if detection_area!=null:
			var bodies = detection_area.get_overlapping_bodies()
			#bodies_in_area = []
			for body in bodies:
				if body is Character and body.is_in_group("damageable") and body.team != team:
					#bodies_in_area.append(body)
					timer.start()
					_on_timer_timein()
					
	#_draw()
	queue_redraw()
	


func _on_body_entered(body):
	if body.is_in_group("damageable") and body.team != team:
		target = body

func _on_body_exited(body):
	if body == target:
		#target = null
		print("_on_body_exited")

func handle_death():
	velocity.x = 0
	if not is_on_floor():
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if not death_animation_finished:
			animated_sprite.play("death")
			#drop_coins_on_death()

func fire_projectile2(target):
	if not target:
		return
	
	current_projectile = projectile_scene.instantiate()
	current_projectile.team = team
	#current_projectile.position = global_position
	current_projectile.target = target
	add_child(current_projectile)

	current_projectile.connect("tree_exited", _on_projectile_tree_exited)
	current_projectile.connect("hit_target", _on_projectile_hit_target)

	timer.start(TIMEOUT_DURATION)

func _on_projectile_hit_target(projectile):
	projectile.queue_free()
	current_projectile = null
	#target.apply_damage(5)
	timer.stop()

func _on_projectile_tree_exited():
	#current_projectile.apply_damage(target)
	#target.apply_damage(5)
	current_projectile = null

func _on_timer_timeout():
	if current_projectile:
		current_projectile.queue_free()
	current_projectile = null
	#if target:
	#	fire_projectile2(target)

func _on_timer_timein():
	#if current_projectile:
	#	current_projectile.queue_free()
	#current_projectile = null
	if target:
		fire_projectile2(target)

func _on_death_animation_finished():
	death_animation_finished = true
	animated_sprite.stop()
	animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("death") - 1
	collision.queue_free()
	detection_area.queue_free()
	drop_coins_on_death()
	queue_free()
