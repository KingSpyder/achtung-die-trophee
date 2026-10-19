## Hosts a running level and forwards the space / escape game state cycling, the same way
## MainScene does for the regular game. Used by the editor preview and the level test scene.
class_name LevelRunner
extends Node

signal closed
signal level_completed

const LEVEL_GAME_SCENE: PackedScene = preload("res://src/level_editor/LevelGameScene.tscn")

var controller: LevelGameController = null
var advance_after_completion := false

func _ready() -> void:
	# Keep reacting to input while the level is paused by the pause overlay.
	process_mode = Node.PROCESS_MODE_ALWAYS

func is_running() -> bool:
	return controller != null and is_instance_valid(controller)

func start(level: LevelData, auto_start_round: bool = false) -> void:
	stop()
	if level == null:
		push_warning("LevelRunner: no level to start")
		return
	controller = LEVEL_GAME_SCENE.instantiate() as LevelGameController
	controller.process_mode = Node.PROCESS_MODE_PAUSABLE
	controller.level = level
	add_child(controller)
	controller.start_game()
	if auto_start_round:
		controller.start_round()

func stop() -> void:
	if is_running():
		controller.exit_game()
		controller.queue_free()
	controller = null
	get_tree().paused = false
	GameManager.game_status = GameManager.GameStatus.LOBBY

func _input(event: InputEvent) -> void:
	if not is_running():
		return
	if event.is_action_pressed("escape"):
		stop()
		closed.emit()
		get_viewport().set_input_as_handled()
		return
	if not event.is_action_pressed("space"):
		return
	get_viewport().set_input_as_handled()
	match GameManager.game_status:
		GameManager.GameStatus.START_GAME:
			controller.start_game()
		GameManager.GameStatus.ROUND_ENDED:
			if advance_after_completion and controller.has_completed_level():
				level_completed.emit()
			else:
				controller.next_round()
		GameManager.GameStatus.GAME_ENDED:
			controller.next_round()
		GameManager.GameStatus.ROUND_READY:
			controller.start_round()
		GameManager.GameStatus.IN_GAME:
			controller.pause_game()
		GameManager.GameStatus.PAUSED:
			controller.resume_game()
