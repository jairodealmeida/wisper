extends CollisionPolygon2D
class_name FacingCollisionShape2D

@export var facing_left_position: Vector2
@export var facing_right_position: Vector2


@export var left_position: Node2D
@export var right_position: Node2D

 
@onready var left_point = $"../LeftPoint"
@onready var rigtht_point = $"../RigthtPoint"
