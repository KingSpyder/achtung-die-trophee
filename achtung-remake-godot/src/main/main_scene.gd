extends Node

func _ready() -> void:
	%LobbyScene.start_game.connect(_on_start_game)

func _on_start_game():
	var game_scene = preload("res://src/game/gameScene.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	%LobbyScene.hide()
	GameManager.game_status = GameManager.GAME_STATUS.IN_GAME
