extends Node

var game_scene: Node

func _ready() -> void:
	%LobbyScene.start_game.connect(_on_start_game)

func _on_start_game() -> void:
	game_scene = preload("res://src/game/gameScene.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	%LobbyScene.hide()
	GameManager.game_status = GameManager.GAME_STATUS.IN_GAME

func _on_quit_game() -> void:
	if(GameManager.game_status == GameManager.GAME_STATUS.LOBBY):
		return
	if(game_scene):
		# we free only the gameScene, but we want to keep the players for the lobby
		game_scene.remove_players()
		game_scene.queue_free()
		game_scene = null
	GameManager.game_status = GameManager.GAME_STATUS.LOBBY
	%LobbyScene.show()


func _input(event) -> void:
	if(event.as_text() == "Escape"):
		_on_quit_game()
