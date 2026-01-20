class_name GameLogicController
extends Node

@onready var game_area_scene: SubViewportContainer = %GameAreaScene
@onready var game_area_viewport: SubViewport = game_area_scene.get_child(0)
@onready var game_physic_controller: GamePhysicController = game_area_viewport.get_node("GameArea")

@onready var max_score_label: Label = %MaxScoreLabel

func _ready() -> void:
	pass

func start_game() -> void:
	print('game started')
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

func start_round() -> void:
	print('round started')
	GameManager.game_status = GameManager.GAME_STATUS.IN_GAME
	GameManager.players_alive = GameManager.players.duplicate()
	for player in GameManager.players:
		game_physic_controller.start_player(player)


func end_round() -> void:
	print('round ended')
	var scores = GameManager.players.map(func(_player): return _player.score)
	scores.sort()
	scores.reverse()
	
	if (scores[0] - scores[1] > GameManager.min_points_difference
			and scores[0] >= GameManager.max_points):
		end_game()
		return
	next_round()

func next_round():
	GameManager.game_status = GameManager.GAME_STATUS.START_ROUND
	for player in GameManager.players:
		player.clean_trails()
		game_physic_controller.spawn_player(player)
	
func end_game():
	print("game ended")
	pass

func pause_game() -> void:
	print('game paused')
	GameManager.game_status = GameManager.GAME_STATUS.PAUSED
	get_tree().paused = true
	
func resume_game() -> void:
	print('game resumed')
	GameManager.game_status = GameManager.GAME_STATUS.IN_GAME
	get_tree().paused = false

func exit_game() -> void:
	resume_game()
	game_physic_controller.exit_game()

func reset_players() -> void:
	for player in GameManager.players:
		player.reset()
		
func _on_player_died(player: Player):
	GameManager.players_alive =	GameManager.players_alive.filter(func(_player): 
		return _player.player_name != player.player_name)
	
	for player_alive in GameManager.players_alive:
		player_alive.score += 1
		var player_score = find_child(player_alive.player_name + "_score", true, false)
		if(player_score):
			player_score.text = str(player_alive.score)
	
	if(GameManager.players_alive.size() == 1):
		end_round()
	
