class_name GameLogicController
extends Node

const PlayerScript = preload("res://src/player/player.gd")
const PlayerActionDisplayBoxScript = preload("res://src/game/player_action_display_box.gd")

var _round_end_scheduled := false
var score_font = load("res://assets/fonts/Verdana.ttf")
var font_size = 25

@onready var game_area_scene: Control = %GameAreaScene
@onready var game_physic_controller: GamePhysicController = game_area_scene.get_node("GameArea")
@onready var pause_overlay: PauseOverlay = game_area_scene.get_node("PauseOverlay")
@onready var countdown_display: CountdownDisplay = game_area_scene.get_node("CountdownOverlay")
@onready var max_score_label: Label = %MaxScoreLabel
@onready var winner_box_container: Control = %WinnerBoxContainer
@onready var winner_panel: PanelContainer = %WinnerPanel
@onready var winner_label: Label = %WinnerLabel


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
		var player_score_row := HBoxContainer.new()
		player_score_row.name = player.player_name + "_score_row"
		player_score_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		player_score_row.add_theme_constant_override("separation", 8)
		max_score_label.add_sibling(player_score_row)

		var player_label := Label.new()
		player_label.text = player.player_name
		player_label.add_theme_font_override("font", score_font)
		player_label.add_theme_font_size_override("font_size", font_size)
		player_label.add_theme_color_override("font_color", player.color)
		player_score_row.add_child(player_label)

		var player_score_label := Label.new()
		player_score_label.name = player.player_name + "_score"
		player_score_label.text = "0"
		player_score_label.add_theme_font_size_override("font_size", font_size)
		player_score_label.add_theme_color_override("font_color", player.color)
		player_score_row.add_child(player_score_label)

		var action_display_box = PlayerActionDisplayBoxScript.new()
		action_display_box.name = player.player_name + "_action_display_box"
		action_display_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		player_score_row.add_child(action_display_box)
		if game_physic_controller.powerup_runtime != null:
			game_physic_controller.powerup_runtime.register_player_action_display(
				player, action_display_box
			)
	next_round()


## Start a new round: start moving the players.
## Status is set to IN_GAME.
func start_round(skip_countdown: bool = false) -> void:
	if not skip_countdown:
		await countdown_display.run_countdown(3)
	print("Round started")
	GameManager.game_status = GameManager.GameStatus.IN_GAME
	GameManager.players_alive = GameManager.players.duplicate()
	game_physic_controller.start_round_powerups(GameManager.players_alive)
	for player in GameManager.players:
		game_physic_controller.start_player(player)


## End the current round, calculate scores and check if the game should end.
## Status is set to ROUND_ENDED, waiting for the player to prepare the next round.
func end_round() -> void:
	for player in GameManager.players:
		player.set_process(false)
	game_physic_controller.reset_round_powerups()
	var scores = GameManager.players.map(func(_player): return _player.score)
	scores.sort()
	scores.reverse()
	if scores.size() < 2:
		end_game()
		return
	if (
		scores[0] - scores[1] > GameManager.min_points_difference
		and scores[0] >= GameManager.max_points
	):
		end_game()
		return
	GameManager.game_status = GameManager.GameStatus.ROUND_ENDED
	print("Round ended, press space to prepare next round")


## Prepare the next round, reset players and spawn them.
## Status is set to ROUND_READY, waiting for the player to start the round.
func next_round():
	game_physic_controller.reset_round_powerups()
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
	_show_winner_box()


## Show a box in the winner's color announcing them as the winner.
func _show_winner_box() -> void:
	var winner: PlayerScript = GameManager.players[0]
	for player in GameManager.players:
		if player.score > winner.score:
			winner = player

	var style: StyleBoxFlat = winner_panel.get_theme_stylebox("panel").duplicate()
	style.bg_color = winner.color
	winner_panel.add_theme_stylebox_override("panel", style)

	var winner_text := "%s a gagné!" % winner.player_name
	if PlayersConstants.FUNNY_ENDGAME_TEXT.has(winner.player_name):
		winner_text += "\n" + PlayersConstants.FUNNY_ENDGAME_TEXT[winner.player_name]
	winner_label.text = winner_text
	winner_box_container.visible = true


func pause_game() -> void:
	print("Game paused")
	GameManager.game_status = GameManager.GameStatus.PAUSED
	pause_overlay.visible = true
	get_tree().paused = true


## Hide the pause panel right away, then play the countdown before actually resuming.
func resume_game() -> void:
	print("Game resuming")
	pause_overlay.visible = false
	await countdown_display.run_countdown(3)
	_unpause()


func exit_game() -> void:
	pause_overlay.visible = false
	_unpause()
	game_physic_controller.exit_game()


func _unpause() -> void:
	print("Game resumed")
	GameManager.game_status = GameManager.GameStatus.IN_GAME
	get_tree().paused = false


func _on_player_died(player: PlayerScript, death_cause: int, collided_player: PlayerScript) -> void:
	print("player ", player.player_name, " died by cause ", death_cause)
	GameManager.players_alive = GameManager.players_alive.filter(
		func(_player): return _player.player_name != player.player_name
	)

	for player_alive in GameManager.players_alive:
		if death_cause == PlayerScript.DeathCause.PLAYER and player_alive == collided_player:
			continue
		player_alive.score += int(round(player_alive.get_score_multiplier()))
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
