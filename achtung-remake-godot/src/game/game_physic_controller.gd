class_name GamePhysicController
extends Node2D

func _ready() -> void:
	add_players()
	spawn_players()
	pass

func add_players() -> void:
	for player in GameManager.players:
			add_child(player)

func remove_players() -> void:
	for player in GameManager.players:
		player.remove_trails()
		remove_child(player)
			
func spawn_players() -> void:
	for player in GameManager.players:
		#player.position = get_random_position()
		player.position = Vector2(400, 400)
	

func get_random_position() -> Vector2i:
	var width = 800
	var height = 800

	# Generate a random position within the screen, with optional margin
	var x = randf_range(20, width - 20)
	var y = randf_range(20, height - 20)
	return Vector2(x, y)
