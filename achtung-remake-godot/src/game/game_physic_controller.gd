class_name GamePhysicController
extends Node2D

func _ready() -> void:
	pass

## Register the player as a child of the physic controller, so that it is processed by godot engine.
func add_player(player: Player) -> void:
	add_child(player)

## Remove the players from the physic controller, so that they are not processed by godot engine.
func exit_game() -> void:
	for player in GameManager.players:
		player.set_process(true)
		player.clean()
		remove_child(player)


## Spawn the player at a random position and direction, with speed 0.
## Rotation is permitted while waiting for the start of the round.
func spawn_player(player: Player) -> void:
	player.position = get_random_position()
	player.direction = get_random_direction()
	# we don't use set_process(false), to allow to turn before starting
	player.speed = 0
	player.set_process(true)
	if(player.arrow):
		player.arrow.visible = true

## Start the player movement and trail laying.
func start_player(player: Player) -> void:
	player.arrow.visible = false
	player.speed = player.default_speed
	player.start_trail()

## Utility functions to generate random position for player spawning.
## TODO: HARDCODED BOUNDS, should be changed to use the actual screen size or a defined play area. 
func get_random_position() -> Vector2:
	var width = 800
	var height = 800
	# Generate a random position within the screen, with optional margin
	var x = randf_range(20, width - 20)
	var y = randf_range(20, height - 20)
	return Vector2(x, y)
	
## Utility function to generate a random direction for player spawning.
func get_random_direction() -> Vector2:
	var x = randf_range(0, 1)
	var y = randf_range(0, 1)
	return Vector2(x, y)
