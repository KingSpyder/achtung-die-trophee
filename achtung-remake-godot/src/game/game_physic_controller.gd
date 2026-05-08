class_name GamePhysicController
extends Node2D

const PlayerScript = preload("res://src/player/player.gd")
const WallScenePacked = preload("res://src/game/wallScene.tscn")

const PLAYFIELD_SIZE := 790.0

@onready var powerup_runtime: PowerUpRuntimeController = get_node_or_null("PowerUpRuntime")


func _ready() -> void:
	_create_walls()


func _create_walls() -> void:
	var walls_node = get_node_or_null("Walls")
	if walls_node != null:
		# Clean up existing walls
		for child in walls_node.get_children():
			walls_node.remove_child(child)
			child.queue_free()
	else:
		walls_node = Node2D.new()
		walls_node.name = "Walls"
		add_child(walls_node)

	# Create top wall
	_spawn_wall_at_position(
		walls_node,
		"TopWall",
		Vector2(-WallScene.THICKNESS, -WallScene.THICKNESS / 2.0),
		Vector2(PLAYFIELD_SIZE + WallScene.THICKNESS, -WallScene.THICKNESS / 2.0)
	)
	# Create bottom wall
	_spawn_wall_at_position(
		walls_node,
		"BottomWall",
		Vector2(-WallScene.THICKNESS, PLAYFIELD_SIZE + WallScene.THICKNESS / 2.0),
		Vector2(PLAYFIELD_SIZE + WallScene.THICKNESS, PLAYFIELD_SIZE + WallScene.THICKNESS / 2.0)
	)
	# Create left wall
	_spawn_wall_at_position(
		walls_node,
		"LeftWall",
		Vector2(-WallScene.THICKNESS / 2.0, 0.0),
		Vector2(-WallScene.THICKNESS / 2.0, PLAYFIELD_SIZE)
	)
	# Create right wall
	_spawn_wall_at_position(
		walls_node,
		"RightWall",
		Vector2(PLAYFIELD_SIZE + WallScene.THICKNESS / 2.0, 0.0),
		Vector2(PLAYFIELD_SIZE + WallScene.THICKNESS / 2.0, PLAYFIELD_SIZE)
	)


func _spawn_wall_at_position(
	parent: Node,
	wall_name: String,
	point_a: Vector2,
	point_b: Vector2,
) -> void:
	var wall := WallScenePacked.instantiate() as Node2D
	parent.add_child(wall)
	if wall.has_method("initialize"):
		wall.call("initialize", wall_name, point_a, point_b)


func get_playfield_bounds() -> Dictionary:
	return {"min": Vector2.ZERO, "max": Vector2(PLAYFIELD_SIZE, PLAYFIELD_SIZE)}


## Register the player as a child of the physic controller, so that it is processed by godot engine.
func add_player(player: PlayerScript) -> void:
	add_child(player)
	if powerup_runtime:
		powerup_runtime.register_player(player)


## Remove the players from the physic controller, so that they are not processed by godot engine.
func exit_game() -> void:
	if powerup_runtime:
		powerup_runtime.clear_round_state()
	for player in GameManager.players:
		player.set_process(true)
		player.reset()
		player.clean()
		if powerup_runtime:
			powerup_runtime.unregister_player(player)
		remove_child(player)


## Spawn the player at a random position and direction, with speed 0.
## Rotation is permitted while waiting for the start of the round.
func spawn_player(player: PlayerScript) -> void:
	player.position = get_random_position()
	player.direction = get_random_direction()
	# we don't use set_process(false), to allow to turn before starting
	player.speed = 0
	player.set_process(true)
	if player.arrow:
		player.arrow.visible = true


## Start the player movement and trail laying.
func start_player(player: PlayerScript) -> void:
	player.arrow.visible = false
	player.speed = player.DEFAULT_SPEED
	player.start_trail()


func start_round_powerups(alive_players: Array[PlayerScript]) -> void:
	if powerup_runtime:
		powerup_runtime.start_round(alive_players)


func reset_round_powerups() -> void:
	if powerup_runtime:
		powerup_runtime.clear_round_state()


## Utility functions to generate random position for player spawning.
## TODO: HARDCODED BOUNDS, should be changed to use the actual screen size or a defined play area.
func get_random_position() -> Vector2:
	var width = PLAYFIELD_SIZE
	var height = PLAYFIELD_SIZE
	# Generate a random position within the screen, with optional margin
	var x = randf_range(20, width - 20)
	var y = randf_range(20, height - 20)
	return Vector2(x, y)


## Utility function to generate a random direction for player spawning.
func get_random_direction() -> Vector2:
	var x = randf_range(0, 1)
	var y = randf_range(0, 1)
	return Vector2(x, y)
