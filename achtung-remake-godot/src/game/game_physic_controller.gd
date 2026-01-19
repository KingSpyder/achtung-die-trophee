extends Node2D

func _ready() -> void:
	spawn_players()
	pass


func _process(delta) -> void:
	pass
	
func spawn_players() -> void:
	for player in GameManager.players:
		player.position = get_random_position()
		add_child(player)

func get_random_position() -> Vector2i:
	var viewport_size = get_viewport().get_visible_rect().size

	# Generate a random position within the screen, with optional margin
	var x = randf_range(20, viewport_size.x - 20)
	var y = randf_range(20, viewport_size.y - 20)
	return Vector2(x, y)

# Walls building
