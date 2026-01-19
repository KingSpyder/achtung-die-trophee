extends Node

@onready var player
@onready var game_area_viewport: SubViewportContainer = %GameAreaScene

func _ready() -> void:
	for player in GameManager.players:
		print(player.player_name)

func remove_players() -> void:
	var game_area_scene := game_area_viewport.get_child(0)
	game_area_scene.get_node("GameArea").remove_players()
