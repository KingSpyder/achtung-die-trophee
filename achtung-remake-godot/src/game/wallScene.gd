class_name WallScene
extends StaticBody2D

const THICKNESS := 10.0
const PhysicsLayersScript = preload("res://src/configs/physics_layers.gd")

var point_a: Vector2
var point_b: Vector2

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var line2d: Line2D = $Line2D


func initialize(wall_name: String, init_point_a: Vector2, init_point_b: Vector2) -> void:
	name = wall_name
	point_a = init_point_a
	point_b = init_point_b

	add_to_group("Walls")
	collision_layer = 1 << PhysicsLayersScript.WALL_BIT
	collision_mask = 0
	z_index = PhysicsLayersScript.WALL_Z_INDEX
	if line2d == null or collision_shape == null:
		return

	# Set line points
	line2d.points = PackedVector2Array([point_a, point_b])

	# Calculate wall properties
	var direction = (point_b - point_a).normalized()
	var distance = point_a.distance_to(point_b)
	var mid_point = (point_a + point_b) / 2.0

	# Determine if wall is horizontal or vertical
	var is_horizontal = abs(direction.y) < abs(direction.x)

	# Create and configure collision shape
	var rect_shape = RectangleShape2D.new()
	if is_horizontal:
		rect_shape.size = Vector2(distance, THICKNESS)
	else:
		rect_shape.size = Vector2(THICKNESS, distance)

	collision_shape.shape = rect_shape
	collision_shape.position = mid_point
