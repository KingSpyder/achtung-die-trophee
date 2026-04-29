extends Node

var game_scene: GameLogicController
var input_detected := false


func _ready() -> void:
	%LobbyScene.start_game.connect(_on_start_game)
	%MainInputCatcher.key_captured.connect(_on_key_captured)


## To leave LobbyScene and start the game.
func _on_start_game() -> void:
	game_scene = preload("res://src/game/gameScene.tscn").instantiate()
	get_tree().root.add_child(game_scene)
	%LobbyScene.hide()
	GameManager.game_status = GameManager.GameStatus.START_GAME


## To leave the game and go back to the lobby. Free the game scene, but keep the players
## for the lobby.
func _on_quit_game() -> void:
	if GameManager.game_status == GameManager.GameStatus.LOBBY:
		return
	if game_scene:
		game_scene.exit_game()
		game_scene.queue_free()
		game_scene = null
	GameManager.game_status = GameManager.GameStatus.LOBBY
	%LobbyScene.show()


## Cycle between game states.
func _on_cycle_game() -> void:
	match GameManager.game_status:
		GameManager.GameStatus.LOBBY:
			input_detected = false
			return
		GameManager.GameStatus.START_GAME:
			game_scene.start_game()
			input_detected = false
		GameManager.GameStatus.ROUND_ENDED:
			game_scene.next_round()
			input_detected = false
		GameManager.GameStatus.ROUND_READY:
			game_scene.start_round()
			input_detected = false
		GameManager.GameStatus.IN_GAME:
			game_scene.pause_game()
			input_detected = false
		GameManager.GameStatus.PAUSED:
			game_scene.resume_game()
			input_detected = false


## Handle key input events for game states changes.
func _on_key_captured(event) -> void:
	input_detected = true
	if event.is_action_pressed("escape"):
		_on_quit_game()
	if event.is_action_pressed("space"):
		_on_cycle_game()
