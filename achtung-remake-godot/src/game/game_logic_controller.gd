class_name GameLogicController
extends Node

@onready var player
@onready var game_area_scene: SubViewportContainer = %GameAreaScene
@onready var game_area_viewport: SubViewport = game_area_scene.get_child(0)
@onready var game_physic_controller: GamePhysicController = game_area_viewport.get_node("GameArea")

func _ready() -> void:
	for player in GameManager.players:
		print(player.player_name)

func start_round() -> void:
	game_physic_controller.start_players()

func clean_scene() -> void:
	game_physic_controller.remove_players()
