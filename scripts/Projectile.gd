extends AnimatableBody2D

class_name Projectile

@export var speed = 200.0  # Velocidade ajustada
@export var damage = 5
var target = null
@onready var collision_area = $CollisionArea
const TIMEOUT_DURATION = 1.0  # 
@onready var timer = $Timer

@onready var collision_shape = $CollisionShape2D
@onready var detection_area = $DetectionArea
@export var team: String = "team01"

signal hit_target(projectile)

func _ready():
	#connect("area_entered", _on_area_entered)
	timer.connect("timeout", _on_timer_timeout)
	timer.start(TIMEOUT_DURATION)

func _on_timer_timeout():
	queue_free()

func _physics_process(delta):
	if not target:
		#apply_damage(target)
		#queue_free()
		return
	
	var direction = (target.global_position - global_position).normalized()
	position += direction * speed * delta
	#connect("area_entered", _on_area_entered)
	#
	if collision_area:
		var bodies = collision_area.get_overlapping_bodies()
		for body in bodies:
			if timer.wait_time && body is Character and body.is_in_group("damageable") and body.team != team:
				body.apply_damage(damage)
				timer.stop()
				emit_signal("hit_target", self)
				#queue_free()

func _on_area_entered(area):
	if area == target:
		apply_damage(area)
		emit_signal("hit_target", self)
		

func apply_damage(target):
	target.apply_damage(damage)
	
