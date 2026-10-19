class_name LevelGoalZone
extends Area2D

signal player_reached(player: Node2D)

const PhysicsLayerScript = preload("res://src/configs/physics_layers.gd")
const ZONE_COLOR = Color(0.1, 0.1, 1, 0.8)
const PING_DURATION := 1.0
const PING_MAX_RADIUS_MULTIPLIER := 2.0
const ARC_POINTS := 64

var goal_zone_radius: float = LevelData.DEFAULT_GOAL_ZONE_RADIUS
var _ping_elapsed := 0.0

func setup(zone_position: Vector2, radius: float) -> void:
	name = "GoalZone"
	position = zone_position
	goal_zone_radius = radius
	collision_layer = 0
	collision_mask = 1 << PhysicsLayerScript.POWERUP_TOKEN_BIT
	monitoring = true
	monitorable = false
	z_index = 1

	var circle_shape := CircleShape2D.new()
	circle_shape.radius = radius
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle_shape
	collision_shape.debug_color = Color(0.0, 0.0, 0.0, 0.0)
	add_child(collision_shape)

	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_ping_elapsed = fposmod(_ping_elapsed + delta, PING_DURATION)
	queue_redraw()

func _draw() -> void:
	var progress := _ping_elapsed / PING_DURATION
	var ping_radius := goal_zone_radius * PING_MAX_RADIUS_MULTIPLIER * progress
	var ping_color := Color(
		ZONE_COLOR.r,
		ZONE_COLOR.g,
		ZONE_COLOR.b,
		ZONE_COLOR.a * (1.0 - progress)
	)
	draw_arc(Vector2.ZERO, ping_radius, 0.0, TAU, ARC_POINTS, ping_color, 3.0)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		player_reached.emit(body)
