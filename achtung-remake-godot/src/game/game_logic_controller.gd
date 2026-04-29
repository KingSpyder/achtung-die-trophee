class_name GameLogicController
extends Node

var _round_end_scheduled := false

@onready var game_area_scene: SubViewportContainer = %GameAreaScene
@onready var game_area_viewport: SubViewport = game_area_scene.get_child(0)
@onready var game_physic_controller: GamePhysicController = game_area_viewport.get_node("GameArea")
@onready var max_score_label: Label = %MaxScoreLabel


## Initialize the game, set up players scores.
## Finish by calling next_round to prepare the first round.
func start_game() -> void:
	print("game started")
	GameManager.max_points = (GameManager.players.size() - 1) * 10
	GameManager.players.sort_custom(GameManager.sort_player_by_order)
	max_score_label.text = str(GameManager.max_points)
	for player in GameManager.players:
		game_physic_controller.add_player(player)
		player.player_died.connect(_on_player_died)
		var player_score_label := Label.new()
		max_score_label.add_sibling(player_score_label)
		var player_label := Label.new()
		max_score_label.add_sibling(player_label)
		player_label.text = player.player_name
		player_score_label.name = player.player_name + "_score"
		player_score_label.text = "0"
	next_round()


## Start a new round: start moving the players.
## Status is set to IN_GAME.
func start_round() -> void:
	print("Round started")
	GameManager.game_status = GameManager.GameStatus.IN_GAME
	GameManager.players_alive = GameManager.players.duplicate()
	for player in GameManager.players:
		game_physic_controller.start_player(player)


## End the current round, calculate scores and check if the game should end.
## Status is set to ROUND_ENDED, waiting for the player to prepare the next round.
func end_round() -> void:
	var scores = GameManager.players.map(func(_player): return _player.score)
	scores.sort()
	scores.reverse()
	if (
		scores[0] - scores[1] > GameManager.min_points_difference
		and scores[0] >= GameManager.max_points
	):
		end_game()
		return

	for player in GameManager.players:
		player.set_process(false)
	GameManager.game_status = GameManager.GameStatus.ROUND_ENDED
	print("Round ended, press space to prepare next round")


## Prepare the next round, reset players and spawn them.
## Status is set to ROUND_READY, waiting for the player to start the round.
func next_round():
	for player in GameManager.players:
		player.clean()
		player.set_process(false)
	# Defer spawning to the next frame to allow queue_free() to process trail segments
	for player in GameManager.players:
		game_physic_controller.spawn_player(player)

	GameManager.game_status = GameManager.GameStatus.ROUND_READY
	print("Next round prepared, press space to start")


func end_game():
	print("Game ended")
	GameManager.game_status = GameManager.GameStatus.GAME_ENDED
	# Here we could show a victory screen or something like that, but for now we do nothing


func pause_game() -> void:
	print("Game paused")
	GameManager.game_status = GameManager.GameStatus.PAUSED
	get_tree().paused = true


func resume_game() -> void:
	print("Game resumed")
	GameManager.game_status = GameManager.GameStatus.IN_GAME
	get_tree().paused = false


func exit_game() -> void:
	resume_game()
	game_physic_controller.exit_game()


func reset_players() -> void:
	for player in GameManager.players:
		player.reset()


func _on_player_died(player: Player):
	GameManager.players_alive = GameManager.players_alive.filter(
		func(_player): return _player.player_name != player.player_name
	)

	for player_alive in GameManager.players_alive:
		player_alive.score += 1
		var player_score = find_child(player_alive.player_name + "_score", true, false)
		if player_score:
			player_score.text = str(player_alive.score)

	if GameManager.players_alive.size() <= 1 and not _round_end_scheduled:
		_round_end_scheduled = true
		call_deferred("_end_round_deferred")
		# we defer the call to avoid calling end_round in the middle of the player death
		# signal processing, which can cause issues if multiple players die at the same time.


func _end_round_deferred() -> void:
	_round_end_scheduled = false
	end_round()
