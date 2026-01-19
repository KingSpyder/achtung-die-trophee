extends Node

const playerSelectionScene: PackedScene = preload("res://src/lobby/PlayerSelectionScene.tscn")

signal start_game()

var players_selection_nodes: Array[PlayerSelection]
var game_mode_button_group := ButtonGroup.new()

@onready var arcade_button: Button = %ArcadeButton
@onready var classic_button: Button = %ClassicButton
@onready var players_list_first_child: Control = %Legende

var has_duplicated_keys := false

func _ready() -> void:
	init_players()
	arcade_button.button_group = game_mode_button_group
	classic_button.button_group = game_mode_button_group

func init_players() -> void:
	players_selection_nodes = [			
		playerSelectionScene.instantiate().init_data("6", PlayersConstants.GREYDON_NAME, PlayersConstants.GREYDON_COLOR),
		playerSelectionScene.instantiate().init_data("5", PlayersConstants.WILLIAM_NAME, PlayersConstants.WILLIAM_COLOR),
		playerSelectionScene.instantiate().init_data("4", PlayersConstants.BLUEBELL_NAME, PlayersConstants.BLUEBELL_COLOR),
		playerSelectionScene.instantiate().init_data("3", PlayersConstants.PINKNEY_NAME, PlayersConstants.PINKNEY_COLOR),
		playerSelectionScene.instantiate().init_data("2", PlayersConstants.GREENLEE_NAME, PlayersConstants.GREENLEE_COLOR),
		playerSelectionScene.instantiate().init_data("1", PlayersConstants.FRED_NAME, PlayersConstants.FRED_COLOR),
	]
	for player_selection_node in players_selection_nodes:
		players_list_first_child.add_sibling(player_selection_node)
		player_selection_node.check_duplicates_keys.connect(_on_check_duplicates_keys)

func _on_check_duplicates_keys() -> void:
	var keys_used: Array[String] = []
	has_duplicated_keys = false
	for player in GameManager.players:
		if(player != null):
			keys_used.push_back(player.left_control)
			keys_used.push_back(player.right_control)
		
	for player_selection_node in players_selection_nodes:
		if player_selection_node.player == null:
			continue
			
		if (is_key_duplicated(keys_used, player_selection_node.player.left_control)):
			player_selection_node.left_input.add_theme_color_override("font_color", Color.RED)
			has_duplicated_keys = true
		else:
			player_selection_node.left_input.add_theme_color_override("font_color", Color.WHITE)
	
		if (is_key_duplicated(keys_used, player_selection_node.player.right_control)):
			player_selection_node.right_input.add_theme_color_override("font_color", Color.RED)
			has_duplicated_keys = true
		else:
			player_selection_node.right_input.add_theme_color_override("font_color", Color.WHITE)

func is_key_duplicated(keys_used: Array[String], key: String) -> bool:
	return keys_used.filter(func(_key): return _key == key).size() > 1

func _on_arcade_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		GameManager.game_mode =  GameManager.GAME_MODE_ENUM.ARCADE_MODE

func _on_classic_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		GameManager.game_mode =  GameManager.GAME_MODE_ENUM.CLASSIC_MODE

func _input(event) -> void:
	if(event.as_text() == "Space"):
		_on_start_button_pressed()

func _on_start_button_pressed() -> void:
	if(has_duplicated_keys or 
			GameManager.players.size() == 0 or 
			GameManager.game_status != GameManager.GAME_STATUS.LOBBY):
		return
	start_game.emit()
	
func hide() -> void:
	%LobbyContainer.visible = false
