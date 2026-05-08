## Big boi controller for managing power-ups in the game at runtime.
##
## Responsibilities include:[br]
## - Spawning power-up tokens at random intervals and positions [br]
## - Keeping track of active power-up tokens and active effects [br]
## - Resolving targets (self, others) [br]
## - Stock player actions granted by action-type power-ups [br]
## - Activating power-up effects when conditions are met (player holds both left and right) [br]
## - Cleaning up state at the end of rounds [br]
## Note: the actual logic of each power-up effect is defined in the PowerUpDefinition resources
## and the ActivePowerUpEffect instances they create, not in this controller.
class_name PowerUpRuntimeController
extends Node2D

const PlayerScript = preload("res://src/player/player.gd")
const GamePhysicControllerScript = preload("res://src/game/game_physic_controller.gd")
const PowerUpTokenScene: PackedScene = preload("res://src/powerup/powerup_token.tscn")
const PowerUpDefinitionScript = preload("res://src/powerup/powerup_definition.gd")
const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")
const PowerUpExecutionContextScript = preload("res://src/powerup/powerup_execution_context.gd")

@export var spawn_interval_min := 3.0
@export var spawn_interval_max := 7.0
@export var max_tokens := 3
@export var action_hold_seconds := 0.25
@export var powerup_definitions: Array[Resource]

var _active_tokens: Array[Area2D] = []
var _active_effects: Array[ActivePowerUpEffectScript] = []
var _registered_players: Array[PlayerScript] = []
var _current_alive_players: Array[PlayerScript] = []
var _spawn_timer := 0.0
var _player_action_definition_by_id := {}
var _player_action_uses_by_id := {}
var _player_hold_elapsed_by_id := {}
var _player_hold_consumed_by_id := {}
var _player_action_display_box_by_id := {}

@onready var _game_physic_controller: GamePhysicControllerScript = get_parent()


func _ready() -> void:
	if powerup_definitions.is_empty():
		powerup_definitions = PowerUpRegistry.get_all_definitions()
	_reset_spawn_timer()


func _process(delta: float) -> void:
	_update_effects(delta)
	if GameManager.game_status == GameManager.GameStatus.IN_GAME:
		_update_player_action_triggers(delta)
	if GameManager.game_status != GameManager.GameStatus.IN_GAME:
		return
	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	if _active_tokens.size() >= max_tokens:
		_reset_spawn_timer()
		return
	spawn_random_token()
	_reset_spawn_timer()


func register_player(player: PlayerScript) -> void:
	if _registered_players.has(player):
		return
	_registered_players.append(player)
	_clear_player_action(player)


func unregister_player(player: PlayerScript) -> void:
	var player_id := player.get_instance_id()
	_player_action_display_box_by_id.erase(player_id)
	_registered_players.erase(player)
	_clear_player_action(player)


func register_player_action_display(player: PlayerScript, display_box: Node) -> void:
	if not is_instance_valid(player):
		return
	if display_box == null:
		return
	var player_id := player.get_instance_id()
	_player_action_display_box_by_id[player_id] = display_box
	var definition = _player_action_definition_by_id.get(player_id, null)
	var uses := int(_player_action_uses_by_id.get(player_id, 0))
	_update_player_action_display(player, definition, uses)


func start_round(alive_players: Array[PlayerScript]) -> void:
	_current_alive_players = alive_players
	_reset_spawn_timer()


func clear_round_state() -> void:
	clear_tokens()
	cancel_all_effects()
	clear_all_player_actions()
	_current_alive_players.clear()


func clear_tokens() -> void:
	for token in _active_tokens:
		if is_instance_valid(token):
			token.queue_free()
	_active_tokens.clear()


func cancel_all_effects() -> void:
	for effect in _active_effects:
		effect.cancel()
	_active_effects.clear()


func spawn_random_token() -> void:
	if powerup_definitions.is_empty():
		return
	var definition = powerup_definitions[randi_range(0, powerup_definitions.size() - 1)]
	#var definition = PowerUpRegistry.get_definition_by_type(
	#	PowerUpRegistry.PowerUpType.PASS_BORDERS_SELF
	#)
	if definition == null:
		return
	var token := PowerUpTokenScene.instantiate() as Area2D
	token.definition = definition
	token.position = _random_token_position()
	token.collected.connect(_on_token_collected)
	add_child(token)
	_active_tokens.append(token)


func spawn_specific_token(definition: PowerUpDefinitionScript, position_token: Vector2) -> void:
	if definition == null:
		return
	var token := PowerUpTokenScene.instantiate() as Area2D
	token.definition = definition
	token.position = position_token
	token.collected.connect(_on_token_collected)
	add_child(token)
	_active_tokens.append(token)


func _update_effects(delta: float) -> void:
	for index in range(_active_effects.size() - 1, -1, -1):
		var effect := _active_effects[index]
		if effect.tick(delta):
			_active_effects.remove_at(index)


func _reset_spawn_timer() -> void:
	_spawn_timer = randf_range(spawn_interval_min, spawn_interval_max)


func _on_token_collected(token: Area2D, collector: PlayerScript) -> void:
	if not _active_tokens.has(token):
		return
	_active_tokens.erase(token)
	token.queue_free()
	if token.definition == null:
		return
	if token.definition.activation_mode == PowerUpDefinitionScript.ActivationMode.ACTION:
		_grant_player_action(collector, token.definition, token.definition.action_uses)
		return
	_activate_powerup_effect(collector, token.definition)


## Generates a unique source ID for an effect based on the definition and current time. [br]
## This is used to track which effects came from which power-up activations,
## keeping loose coupling between the PowerUpRuntimeController, the logic in the PowerUpDefinition,
## and the PlayerScript instances that are affected.
func _create_id_for_effect(definition: PowerUpDefinitionScript) -> StringName:
	return StringName("%s_%s" % [definition.powerup_id, Time.get_ticks_usec()])


func _activate_powerup_effect(collector: PlayerScript, definition) -> void:
	var targets := _resolve_targets(collector, definition.target)
	var context := PowerUpExecutionContextScript.new(
		collector, _current_alive_players.duplicate(), _game_physic_controller
	)
	var source_id: StringName = _create_id_for_effect(definition)
	var effect: Variant = definition.on_apply(context, targets, source_id)
	if effect != null:
		_active_effects.append(effect)


func _resolve_targets(collector: PlayerScript, target_type: int) -> Array[PlayerScript]:
	match target_type:
		PowerUpDefinitionScript.Target.SELF:
			return [collector]
		PowerUpDefinitionScript.Target.OTHERS:
			return _get_alive_players_except(collector)
		PowerUpDefinitionScript.Target.NEUTRAL:
			return []
		PowerUpDefinitionScript.Target.ALL:
			return _current_alive_players
	return []


func _get_alive_players_except(collector: PlayerScript) -> Array[PlayerScript]:
	var targets: Array[PlayerScript] = []
	for player in _current_alive_players:
		if not is_instance_valid(player):
			continue
		if player == collector:
			continue
		targets.append(player)
	return targets


func _random_token_position() -> Vector2:
	var x = randf_range(40.0, 760.0)
	var y = randf_range(40.0, 760.0)
	return Vector2(x, y)


## Does _update_single_player_action_trigger for all valid players.
func _update_player_action_triggers(delta: float) -> void:
	for player in _registered_players:
		if not is_instance_valid(player):
			continue
		_update_single_player_action_trigger(player, delta)


## Checks if the player is currently holding both left and right action buttons for their granted
## action, and the elapsed time to decide on activation. Also deals with consumption of action uses.
func _update_single_player_action_trigger(player: PlayerScript, delta: float) -> void:
	var player_id := player.get_instance_id()
	var definition = _player_action_definition_by_id.get(player_id, null)
	var uses := int(_player_action_uses_by_id.get(player_id, 0))
	if definition == null or uses <= 0:
		_player_hold_elapsed_by_id[player_id] = 0.0
		_player_hold_consumed_by_id[player_id] = false
		return

	var left_pressed := _is_player_action_pressed(player, "_left")
	var right_pressed := _is_player_action_pressed(player, "_right")
	if left_pressed and right_pressed:
		var elapsed := float(_player_hold_elapsed_by_id.get(player_id, 0.0)) + delta
		_player_hold_elapsed_by_id[player_id] = elapsed
		var already_consumed := bool(_player_hold_consumed_by_id.get(player_id, false))
		if not already_consumed and elapsed >= action_hold_seconds:
			_player_hold_consumed_by_id[player_id] = true
			uses -= 1
			_player_action_uses_by_id[player_id] = uses
			_activate_powerup_effect(player, definition)
			if uses <= 0:
				_clear_player_action(player)
			else:
				_update_player_action_display(player, definition, uses)
		return

	_player_hold_elapsed_by_id[player_id] = 0.0
	_player_hold_consumed_by_id[player_id] = false


func _is_player_action_pressed(player: PlayerScript, suffix: String) -> bool:
	var action_name := player.player_name + suffix
	if not InputMap.has_action(action_name):
		return false
	return Input.is_action_pressed(action_name)


func _grant_player_action(player: PlayerScript, definition, uses: int) -> void:
	var player_id := player.get_instance_id()
	_player_action_definition_by_id[player_id] = definition
	var granted_uses := maxi(1, uses)
	_player_action_uses_by_id[player_id] = granted_uses
	_player_hold_elapsed_by_id[player_id] = 0.0
	_player_hold_consumed_by_id[player_id] = false
	_update_player_action_display(player, definition, granted_uses)


func _clear_player_action(player: PlayerScript) -> void:
	var player_id := player.get_instance_id()
	_player_action_definition_by_id.erase(player_id)
	_player_action_uses_by_id.erase(player_id)
	_player_hold_elapsed_by_id.erase(player_id)
	_player_hold_consumed_by_id.erase(player_id)
	_update_player_action_display(player, null, 0)


func clear_all_player_actions() -> void:
	for player in _registered_players:
		if not is_instance_valid(player):
			continue
		_clear_player_action(player)


func _update_player_action_display(player: PlayerScript, definition, uses: int) -> void:
	var player_id := player.get_instance_id()
	var display_box = _player_action_display_box_by_id.get(player_id, null)
	if display_box == null or not is_instance_valid(display_box):
		return
	if not display_box.has_method("update_display"):
		return

	var token_textures: Array = []
	if definition != null and uses > 0 and definition.token_texture != null:
		for _index in range(uses):
			token_textures.append(definition.token_texture)
	display_box.call("update_display", token_textures)
