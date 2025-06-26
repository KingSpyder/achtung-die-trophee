extends Node2D

const playerScene: PackedScene = preload("res://src/player/playerScene.tscn")
@onready var player

func _ready() -> void:
	#spawn_players()
	player = playerScene.instantiate()
	player.position = get_random_position()
	add_child(player)

func _process(delta) -> void:
	pass
	
func spawn_players() -> void:
	for i in GameManager.players:
		var player = playerScene.instantiate()
		player.name = str(GameManager.players[i].id)
		player.position = get_random_position()
		add_child(player)

func get_random_position() -> Vector2i:
	var viewport_size = get_viewport().get_visible_rect().size

	# Generate a random position within the screen, with optional margin
	var x = randf_range(20, viewport_size.x - 20)
	var y = randf_range(20, viewport_size.y - 20)
	return Vector2(x, y)

# Walls building
