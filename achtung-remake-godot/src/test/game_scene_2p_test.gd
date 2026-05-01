class_name GameScene2PTest
extends GameLogicController

enum Preset {
	CUSTOM,
	GOING_THROUGH_RECENT_TRAIL,  ## Test the collision in other player's recent trail
	HEAD_ON_COLLISION,  ## 2 players collide head-on
}

const PlayerHeadPresetScript = preload("res://src/player/player_head_preset.gd")

## Survives reload_current_scene (static) to pass the chosen preset to the new instance.
static var _forced_preset: int = -1
## Prevents the preset setter from triggering a reload loop when applied during _ready.
static var _applying_forced: bool = false

@export var preset := Preset.CUSTOM:
	get:
		return _preset_internal
	set(value):
		_preset_internal = value
		_apply_preset(value)
		if (
			not Engine.is_editor_hint()
			and is_inside_tree()
			and not GameScene2PTest._applying_forced
		):
			GameScene2PTest._forced_preset = int(value)
			call_deferred("_reload_from_runtime_preset_switch")

@export var auto_start_round := true

@export_group("Player 1")
@export var player_1_name := "TestP1"
@export var player_1_color := Color(1, 0, 0, 1)
@export var player_1_head_preset_override: PlayerHeadPresetScript
@export var player_1_position := Vector2(200, 400)
@export var player_1_direction := Vector2.RIGHT
@export var player_1_gate_open_delay := 1.8

@export_group("Player 2")
@export var player_2_name := "TestP2"
@export var player_2_color := Color(0, 1, 1, 1)
@export var player_2_head_preset_override: PlayerHeadPresetScript
@export var player_2_position := Vector2(380, 600)
@export var player_2_direction := Vector2.UP
@export var player_2_gate_open_delay := 10

@export_group("Observer (Player 3)")
@export var player_3_name := "Observer"
@export var player_3_color := Color(0.8, 0.8, 0.8, 1)
@export var player_3_head_preset_override: PlayerHeadPresetScript
@export var player_3_position := Vector2(760, 760)

var _preset_internal: Preset = Preset.CUSTOM
var _player_scene: PackedScene = preload("res://src/player/playerScene.tscn")
var _player_1: PlayerScript
var _player_2: PlayerScript
var _player_3: PlayerScript


func _ready() -> void:
	_apply_runtime_preset(_consume_runtime_preset())
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
	_setup_observer_player(_player_3)


func next_round() -> void:
	for player in GameManager.players:
		player.clean()
		player.set_process(false)

	_spawn_test_player(_player_1, player_1_position, player_1_direction)
	_spawn_test_player(_player_2, player_2_position, player_2_direction)
	_spawn_test_player(_player_3, player_3_position, Vector2.LEFT)

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

	_player_1 = _create_test_player(player_1_name, player_1_color, 1, player_1_head_preset_override)
	_player_2 = _create_test_player(player_2_name, player_2_color, 2, player_2_head_preset_override)
	_player_3 = _create_test_player(player_3_name, player_3_color, 3, player_3_head_preset_override)

	GameManager.players.push_back(_player_1)
	GameManager.players.push_back(_player_2)
	GameManager.players.push_back(_player_3)


func _create_test_player(
	test_name: String,
	test_color: Color,
	test_order: int,
	head_preset_override: PlayerHeadPresetScript,
) -> PlayerScript:
	var player: PlayerScript = _player_scene.instantiate()
	player.player_name = test_name
	player.color = test_color
	player.order = test_order
	if head_preset_override != null:
		player.head_preset = head_preset_override
	return player


func _spawn_test_player(
	player: PlayerScript, spawn_position: Vector2, spawn_direction: Vector2
) -> void:
	player.position = spawn_position
	player.direction = _sanitize_direction(spawn_direction)
	player.speed = 0
	player.set_process(true)
	if player.arrow:
		player.arrow.visible = true


func _apply_gate_open_delay(player: PlayerScript, delay_seconds: float) -> void:
	if not is_instance_valid(player):
		return
	var gate_open_timer: Timer = player.get_node("GateOpenTimer")
	if gate_open_timer == null:
		return
	gate_open_timer.stop()
	gate_open_timer.wait_time = maxf(delay_seconds, 0.01)
	gate_open_timer.start()


func _setup_observer_player(player: PlayerScript) -> void:
	if not is_instance_valid(player):
		return
	player.speed = 0
	player.is_laying_trail = false
	player.velocity = Vector2.ZERO
	player.set_process(false)
	if player.arrow:
		player.arrow.visible = false
	var player_collision_shape := (
		player.get_node_or_null("PlayerCollisionShape") as CollisionShape2D
	)
	if player_collision_shape:
		player_collision_shape.disabled = true


func _sanitize_direction(direction: Vector2) -> Vector2:
	if direction.length_squared() <= 0.0001:
		return Vector2.RIGHT
	return direction.normalized()


func _apply_preset(target_preset: Preset = _preset_internal) -> void:
	player_1_head_preset_override = null
	player_2_head_preset_override = null
	player_3_head_preset_override = null
	match target_preset:
		Preset.GOING_THROUGH_RECENT_TRAIL:
			player_1_position = Vector2(200, 400)
			player_1_direction = Vector2.RIGHT
			player_1_gate_open_delay = 1.8
			player_2_position = Vector2(380, 600)
			player_2_direction = Vector2.UP
			player_2_gate_open_delay = 10
		Preset.HEAD_ON_COLLISION:
			player_1_position = Vector2(200, 400)
			player_1_direction = Vector2.RIGHT
			player_1_gate_open_delay = 99
			player_1_head_preset_override = AllPresets.SQUARE
			player_2_position = Vector2(600, 400)
			player_2_direction = Vector2.LEFT
			player_2_gate_open_delay = 99
			player_2_head_preset_override = AllPresets.ROUND
		Preset.CUSTOM:
			pass


func _consume_runtime_preset() -> Preset:
	if GameScene2PTest._forced_preset >= 0:
		var forced := GameScene2PTest._forced_preset as Preset
		GameScene2PTest._forced_preset = -1
		return forced
	return _preset_internal


func _apply_runtime_preset(runtime_preset: Preset) -> void:
	GameScene2PTest._applying_forced = true
	_preset_internal = runtime_preset
	_apply_preset(runtime_preset)
	GameScene2PTest._applying_forced = false


func _reload_from_runtime_preset_switch() -> void:
	if is_inside_tree():
		get_tree().reload_current_scene()


func _reload_test_scene() -> void:
	GameScene2PTest._forced_preset = int(_preset_internal)
	get_tree().reload_current_scene()
