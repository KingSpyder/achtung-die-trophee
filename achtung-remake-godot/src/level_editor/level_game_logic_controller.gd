# Inherit GameLogicController to create, prepare control and play a level
class_name LevelGameController
extends GameLogicController

const PlayerScene: PackedScene = preload("res://src/player/playerScene.tscn")
const LEVEL_ROOT_NAME := "Level Geometry"

@export var level: LevelData

var _lobby_players: Array[PlayerScript] = []
var _level_players: Array[PlayerScript] = []
var _level_spawns: Array[LevelPlayerSpawn] = []
var _created_actions: PackedStringArray = []
var _added_action_events: Array[Dictionary] = []
var _level_root: Node2D
var _level_completed := false

func start_game() -> void:
	if level == null:
		push_error("LevelGameController: no level assigned.")
		return
	_install_level_players()
	_build_level_geometry()
	super.start_game()
	if not level.enable_powerups and game_physic_controller.powerup_runtime != null:
		game_physic_controller.powerup_runtime.process_mode = Node.PROCESS_MODE_DISABLED
		
#func _setup_ai_players() -> void:
	#GameManager.ai_players.clear()

func next_round() -> void:
	game_physic_controller.reset_round_powerups()
	#game_physic_controller.reset_ai()
	_level_completed = false
	winner_box_container.visible = false
	for player in GameManager.players:
		player.clean()
		player.set_process(false)
	
	for index in range (_level_players.size()):
		var player := _level_players[index]
		var spawn := _level_spawns[index]
		player.position = spawn.position
		player.direction = spawn.direction
		player.speed = 0
		player.set_process(true)
		if player.arrow:
			player.arrow.visible = true
			
	GameManager.game_status = GameManager.GameStatus.ROUND_READY
	AudioManager.play_music(GAME_MUSIC)
	print("Level ready, press space to start")
	
# Replayable, end_round cannot end_game()
func end_round() -> void:
	_countdown_request_id += 1
	if round_audio_controller:
		round_audio_controller.stop_round()
	countdown_display.cancel_countdown()
	for player in GameManager.players:
		player.set_process(false)
	game_physic_controller.reset_round_powerups()
	GameManager.game_status = GameManager.GameStatus.ROUND_ENDED
	print("Level round ended, press space to retry.")

func exit_game() -> void:
	super.exit_game()
	_clear_level_geometry()
	_unregister_controls()
	for player in _level_players:
		if not is_instance_valid(player):
			continue
		if player.get_parent() != null:
			player.get_parent().remove_child(player)
		player.queue_free()
	_level_players.clear()
	_level_spawns.clear()
	GameManager.players.clear()
	GameManager.players_alive.clear()
	for player in _lobby_players:
		if is_instance_valid(player):
			GameManager.players.push_back(player)
	_lobby_players.clear()

func _install_level_players() -> void:
	_lobby_players = GameManager.players.duplicate()
	GameManager.players.clear()
	GameManager.players_alive.clear()
	#GameManager.ai_players.clear()
	_level_players.clear()
	_level_spawns.clear()
	
	var order := 1
	for spawn in level.players:
		if spawn == null:
			continue
		var player: PlayerScript = PlayerScene.instantiate()
		player.player_name = spawn.player_name
		player.color  = spawn.color
		player.order = order
		#player.is_ai = spawn.is_ai
		player.left_control = spawn.left_control
		player.right_control = spawn.right_control
		_register_controls(spawn)
		_level_players.push_back(player)
		_level_spawns.push_back(spawn)
		GameManager.players.push_back(player)
		order += 1
	if _level_players.is_empty():
		push_warning("Level '%s' has no player" % level.level_name)
		
func _build_level_geometry() -> void:
	_clear_level_geometry()
	_level_root = Node2D.new()
	_level_root.name = LEVEL_ROOT_NAME
	game_physic_controller.add_child(_level_root)
	
	for obstacle in level.obstacles:
		if obstacle == null:
			continue
		_level_root.add_child(LevelBuilder.build_obstacle(obstacle, level.gates))

func _clear_level_geometry() -> void:
	if is_instance_valid(_level_root):
		_level_root.get_parent().remove_child((_level_root))
		_level_root.queue_free()
	_level_root = null
	
func _register_controls(spawn: LevelPlayerSpawn) -> void:
	_register_action(spawn.player_name + "_left", spawn.left_control)
	_register_action(spawn.player_name + "_right", spawn.right_control)

func _register_action(action_name: String, key_text: String) -> void:
	var trimmed := key_text.strip_edges()
	if trimmed.is_empty():
		return
	var keycode := OS.find_keycode_from_string(trimmed)
	if keycode == KEY_NONE:
		push_warning("Unknown key '%s' for '%s'" % [trimmed, action_name])
		return
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
		_created_actions.append(action_name)
	var event := InputEventKey.new()
	event.keycode = keycode
	InputMap.action_add_event(action_name, event)
	_added_action_events.push_back({"action": action_name, "event": event})
	
func _unregister_controls() -> void:
	for entry in _added_action_events:
		var action_name: String = entry["action"]
		if InputMap.has_action(action_name):
			InputMap.action_erase_event(action_name, entry["event"])
	_added_action_events.clear()
	for action_name in _created_actions:
		if InputMap.has_action(action_name):
			InputMap.erase_action(action_name)
	_created_actions.clear()
