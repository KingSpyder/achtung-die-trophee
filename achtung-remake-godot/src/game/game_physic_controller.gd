class_name GamePhysicController
extends Node2D

func _ready() -> void:
	pass

func add_player(player: Player) -> void:
	add_child(player)

func exit_game() -> void:
	for player in GameManager.players:
		player.set_process(true)
		player.clean_trails()
		remove_child(player)

func spawn_player(player: Player) -> void:
	player.position = get_random_position()
	player.direction = get_random_direction()
	# we don't use set_process(false), to allow to turn before starting
	player.speed = 0
	player.set_process(true)
	if(player.arrow):
		player.arrow.visible = true

func start_player(player: Player) -> void:
	player.arrow.visible = false
	player.speed = player.default_speed
	player.add_trail()

func get_random_position() -> Vector2:
	var width = 800
	var height = 800
	# Generate a random position within the screen, with optional margin
	var x = randf_range(20, width - 20)
	var y = randf_range(20, height - 20)
	return Vector2(x, y)
	
func get_random_direction() -> Vector2:
	var x = randf_range(0, 1)
	var y = randf_range(0, 1)
	return Vector2(x, y)
