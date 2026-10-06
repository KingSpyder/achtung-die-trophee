## Runs every AI brain and keeps the occupancy grid they read in sync with the arena.
##
## Processed before the players (negative process priority) so that the decision taken this
## frame is the one Player.move() applies during the very same frame.
class_name AiManager
extends Node

## A jump bigger than this (px) in a single frame means the player respawned or went through
## a border, so no trail is painted between the two positions.
const TELEPORT_THRESHOLD := 100.0

var field: AiField
var difficulty: AiDifficulty

var _controllers: Array[AiController] = []
var _tracked_players: Array[Player] = []
var _last_positions := {}
var _was_laying_trail := {}
var _running := false


func _init() -> void:
	process_priority = -10


## `all_players` is every player of the game (the AI must see the human trails too),
## `ai_players` only the ones it drives.
func configure(
	playfield_bounds: Dictionary, all_players: Array, ai_players: Array, difficulty_level: int
) -> void:
	field = AiField.new(playfield_bounds["min"], playfield_bounds["max"])
	difficulty = AiDifficulty.profile(difficulty_level)

	_tracked_players.clear()
	for player in all_players:
		_tracked_players.append(player)
		var handler := _on_trails_cleaned.bind(player)
		if not player.trails_cleaned.is_connected(handler):
			player.trails_cleaned.connect(handler)

	_controllers.clear()
	for ai_player in ai_players:
		_controllers.append(AiController.new(ai_player, field, difficulty))

	reset()


## Stop steering and forget the arena, between two rounds.
func reset() -> void:
	_running = false
	_last_positions.clear()
	_was_laying_trail.clear()
	if field != null:
		field.clear()
	for controller in _controllers:
		controller.reset()


func start_round() -> void:
	_last_positions.clear()
	_was_laying_trail.clear()
	for player in _tracked_players:
		if is_instance_valid(player):
			_last_positions[player.get_instance_id()] = player.position
	_running = true


func _process(delta: float) -> void:
	if not _running or field == null:
		return
	_paint_trails()
	for controller in _controllers:
		# Dead players have their processing disabled by Player.death().
		if is_instance_valid(controller.player) and controller.player.is_processing():
			controller.update(delta)


## Paint into the grid everything the players drew since the previous frame. Positions are
## read in playfield space (Player.position), the same space as get_playfield_bounds(): the
## game area is laid out inside a MarginContainer, so global coordinates are shifted.
func _paint_trails() -> void:
	for player in _tracked_players:
		if not is_instance_valid(player):
			continue
		var key := player.get_instance_id()
		var current := player.position
		var previous: Vector2 = _last_positions.get(key, current)
		var was_laying: bool = _was_laying_trail.get(key, false)
		_last_positions[key] = current
		_was_laying_trail[key] = player.is_laying_trail
		if not player.is_laying_trail:
			continue
		# First frame of a new trail: `previous` is still inside the gate that just closed, so
		# painting that segment would eat into the gap and make the gate look narrower than it
		# really is. The disc stamped from `current` on the next frame covers the start anyway.
		if not was_laying:
			continue
		if previous.distance_to(current) > TELEPORT_THRESHOLD:
			continue
		field.stamp_segment(player.order, previous, current, player.size)


func _on_trails_cleaned(player: Player) -> void:
	if field != null and is_instance_valid(player):
		field.clear_owner(player.order)
