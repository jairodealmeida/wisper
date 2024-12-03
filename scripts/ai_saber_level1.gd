# res://scripts/ai_saber_level1.gd
extends CharacterBody2D
class_name AiSaberLevel1
@export var troll: Troll

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var collision_area = $CollisionPolygon2D
@onready var sword_area = $Area2D
@export var facing_shape: FacingCollisionShape2D

signal sword_hit(body)

func _ready():
	if troll:
		troll.connect("facing_direction_changed", _on_troll_facing_direction_changed)
		sword_area.connect("body_entered", _on_sword_area_body_entered)

func _on_sword_area_body_entered(body):
	emit_signal("sword_hit", body)

var direction = 0

func attackPlay():
	#animation_player.play("attack_1")
	#animated_sprite.play("attack")
	check_sword_collision()

func check_sword_collision():
	if sword_area && troll:
		var bodies = sword_area.get_overlapping_bodies()
		for body in bodies:
			#if body.is_in_group("damageable"):
			if body is Character and body.is_in_group("damageable") and body.team != troll.team:
				animation_player.play("attack_1")
				animated_sprite.play("attack")
				body.apply_damage(10)

func _physics_process(delta):
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

func _on_troll_facing_direction_changed(facing_right: bool):
	if facing_right:
		facing_shape.position = facing_shape.facing_right_position
	else:
		facing_shape.position = facing_shape.facing_left_position
