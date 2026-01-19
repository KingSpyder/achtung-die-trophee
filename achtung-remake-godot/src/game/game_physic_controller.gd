class_name GamePhysicController
extends Node2D

func _ready() -> void:
	spawn_players()
	pass

func add_players() -> void:
	for player in GameManager.players:
		add_child(player)

func remove_players() -> void:
	for player in GameManager.players:
		player.set_process(true)
		player.clean_trails()
		remove_child(player)

func spawn_players() -> void:
	for player in GameManager.players:
		player.position = get_random_position()
		player.direction = get_random_direction()
		player.speed = 0
		if(player.arrow):
			player.arrow.visible = true
		#player.position = Vector2(400, 400)

func start_players() -> void:
	for player in GameManager.players:
		player.arrow.visible = false
		player.speed = 100
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
