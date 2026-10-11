class_name LevelGoalZone
extends Area2D

signal player_reached(player: Node2D)

const PhysicsLayerScript = preload("res://src/configs/physics_layers.gd")
const ZONE_COLOR = Color(0.1, 0.1, 1, 0.8)

var goal_zone_radius = LevelData.DEFAULT_GOAL_ZONE_RADIUS

func setup(zone_position: Vector2, radius: float) -> void:
	name = "GoalZone"
	position = zone_position
	collision_layer = 0
	collision_mask = 1 << PhysicsLayerScript.POWERUP_TOKEN_BIT
	monitoring = true
	monitorable = false
	z_index = -1
	
	var circle_shape := CircleShape2D.new()
	circle_shape.radius = radius
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle_shape
	add_child(collision_shape)
	
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		player_reached.emit(body)
