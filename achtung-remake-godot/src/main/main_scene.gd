extends Node

var game_scene: GameLogicController
var input_detected:= false

func _ready() -> void:
	%LobbyScene.start_game.connect(_on_start_game)
	%MainInputCatcher.key_captured.connect(_on_key_captured)


func _on_start_game() -> void:
	game_scene = preload("res://src/game/gameScene.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	%LobbyScene.hide()
	GameManager.game_status = GameManager.GAME_STATUS.START

func _on_quit_game() -> void:
	if(GameManager.game_status == GameManager.GAME_STATUS.LOBBY):
		return
	if(game_scene):
		# we free only the gameScene, but we want to keep the players for the lobby
		game_scene.clean_scene()
		game_scene.queue_free()
		game_scene = null
	GameManager.game_status = GameManager.GAME_STATUS.LOBBY
	%LobbyScene.show()

func _on_pause_game() -> void:
	match GameManager.game_status:
		GameManager.GAME_STATUS.LOBBY:
			input_detected = false
			return
		GameManager.GAME_STATUS.START:
			print('game started')
			GameManager.game_status = GameManager.GAME_STATUS.IN_GAME
			game_scene.start_round()
			input_detected = false
		GameManager.GAME_STATUS.IN_GAME:
			print('game paused')
			GameManager.game_status = GameManager.GAME_STATUS.PAUSED
			game_scene.get_tree().paused = true
			input_detected = false
		GameManager.GAME_STATUS.PAUSED:
			print('game resumed')
			GameManager.game_status = GameManager.GAME_STATUS.IN_GAME
			game_scene.get_tree().paused = false
			input_detected = false

func _on_key_captured(event) -> void:
	input_detected = true
	if(event.is_action_pressed("escape")):
		_on_quit_game()
	if(event.is_action_pressed("space")):
		_on_pause_game()
