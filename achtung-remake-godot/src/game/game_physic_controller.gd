class_name GamePhysicController
extends Node2D

const PlayerScript = preload("res://src/player/player.gd")

@onready var powerup_runtime: PowerUpRuntimeController = get_node_or_null("PowerUpRuntime")


func _ready() -> void:
	pass


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
