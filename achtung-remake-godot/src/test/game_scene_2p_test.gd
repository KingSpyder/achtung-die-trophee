class_name GameScene2PTest
extends GameLogicController

@export var auto_start_round := true

@export var player_1_name := "TestP1"
@export var player_1_color := Color(1, 0, 0, 1)
@export var player_1_position := Vector2(200, 400)
@export var player_1_direction := Vector2.RIGHT
@export var player_1_gate_open_delay := 1.8

@export var player_2_name := "TestP2"
@export var player_2_color := Color(0, 1, 1, 1)
@export var player_2_position := Vector2(380, 600)
@export var player_2_direction := Vector2.UP
@export var player_2_gate_open_delay := 10

var _player_scene: PackedScene = preload("res://src/player/playerScene.tscn")
var _player_1: Player
var _player_2: Player


func _ready() -> void:
	_setup_test_players()
	start_game()
	if auto_start_round:
		start_round()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
		_reload_test_scene()
		var viewport := get_viewport()
		if viewport:
			viewport.set_input_as_handled()


func start_round() -> void:
	super.start_round()
	_apply_gate_open_delay(_player_1, player_1_gate_open_delay)
	_apply_gate_open_delay(_player_2, player_2_gate_open_delay)


func next_round() -> void:
	for player in GameManager.players:
		player.clean()
		player.set_process(false)

	_spawn_test_player(_player_1, player_1_position, player_1_direction)
	_spawn_test_player(_player_2, player_2_position, player_2_direction)

	GameManager.game_status = GameManager.GameStatus.ROUND_READY
	print("Next round prepared (2P test scene)")


func _setup_test_players() -> void:
	for existing_player in GameManager.players:
		if is_instance_valid(existing_player):
			if existing_player.get_parent():
				existing_player.get_parent().remove_child(existing_player)
			existing_player.queue_free()
	GameManager.players.clear()
	GameManager.players_alive.clear()

	_player_1 = _create_test_player(player_1_name, player_1_color, 1)
	_player_2 = _create_test_player(player_2_name, player_2_color, 2)

	GameManager.players.push_back(_player_1)
	GameManager.players.push_back(_player_2)


func _create_test_player(test_name: String, test_color: Color, test_order: int) -> Player:
	var player: Player = _player_scene.instantiate()
	player.player_name = test_name
	player.color = test_color
	player.order = test_order
	return player


func _spawn_test_player(player: Player, spawn_position: Vector2, spawn_direction: Vector2) -> void:
	player.position = spawn_position
	player.direction = _sanitize_direction(spawn_direction)
	player.speed = 0
	player.set_process(true)
	if player.arrow:
		player.arrow.visible = true


func _apply_gate_open_delay(player: Player, delay_seconds: float) -> void:
	if not is_instance_valid(player):
		return
	var gate_open_timer: Timer = player.get_node("GateOpenTimer")
	if gate_open_timer == null:
		return
	gate_open_timer.stop()
	gate_open_timer.wait_time = maxf(delay_seconds, 0.01)
	gate_open_timer.start()


func _sanitize_direction(direction: Vector2) -> Vector2:
	if direction.length_squared() <= 0.0001:
		return Vector2.RIGHT
	return direction.normalized()


func _reload_test_scene() -> void:
	get_tree().reload_current_scene()
