# res://scripts/saber_level1.gd
extends CharacterBody2D

@export var player: Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0



var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_dead = false;
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var collision_area = $CollisionPolygon2D
@onready var sword_area = $Area2D
@export var facing_shape: FacingCollisionShape2D

signal sword_hit(body)

func _ready():
	player.connect("facing_direction_changed", _on_player_facing_direction_changed)
	sword_area.connect("body_entered", _on_sword_area_body_entered)

func check_sword_collision():
	if sword_area:
		var bodies = sword_area.get_overlapping_bodies()
		for body in bodies:
			#if body.is_in_group("damageable"):
			if body is Character and body.is_in_group("damageable") and body.team != player.team:
				body.apply_damage(player.damage)

func _physics_process(delta):
	if is_dead:
		return

	var direction = Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if Input.is_action_just_pressed("attack"):
		animation_player.play("attack_1")
		animated_sprite.play("default")
		check_sword_collision()

func _on_player_facing_direction_changed(facing_right: bool):
	#var displacement_offset = -3
	if facing_right:
		#facing_shape.position = facing_shape.facing_right_position
		facing_shape.position = facing_shape.rigtht_point.position
		facing_shape.scale.x = 1  # Escala normal no eixo X
	else:
		#facing_shape.position = facing_shape.facing_left_position
		facing_shape.position = facing_shape.left_point.position
		facing_shape.scale.x = -1  # Espelha no eixo X
		 # Ajuste a posição para compensar o deslocamento
		#facing_shape.position.x += displacement_offset  # ajuste este valor conforme necessário

func _on_sword_area_body_entered(body):
	emit_signal("sword_hit", body)
