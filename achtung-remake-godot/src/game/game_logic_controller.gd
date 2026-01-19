class_name GameLogicController
extends Node

@onready var player
@onready var game_area_scene: SubViewportContainer = %GameAreaScene
@onready var game_area_viewport: SubViewport = game_area_scene.get_child(0)
@onready var game_physic_controller: GamePhysicController = game_area_viewport.get_node("GameArea")

func _ready() -> void:
	pass

func start_game() -> void:
	GameManager.max_points = (GameManager.players.size() - 1) * 10
	game_physic_controller.add_players()
	game_physic_controller.spawn_players()

func reset_players() -> void:
	for player in GameManager.players:
		player.reset()

func start_round() -> void:
	game_physic_controller.start_players()

func clean_scene() -> void:
	game_physic_controller.remove_players()
