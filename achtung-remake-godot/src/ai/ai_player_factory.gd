## Builds the computer-controlled opponents that fill the empty slots of a solo game.
##
## Mirrors what the ActionScript original did in Game.as#gameReady(): with a single human
## player, every remaining character of the roster joins the game as an AI.
class_name AiPlayerFactory
extends RefCounted

const PLAYER_SCENE: PackedScene = preload("res://src/player/playerScene.tscn")
## Preloaded rather than reached through the autoload, so that the static helpers below can
## read the constants.
const PlayersConstantsScript = preload("res://src/res/constants/players_constants.gd")


## The six characters, with the same order / name / colour as the lobby.
static func roster() -> Array[Dictionary]:
	return [
		{
			"order": 1,
			"name": PlayersConstantsScript.FRED_NAME,
			"color": PlayersConstantsScript.FRED_COLOR
		},
		{
			"order": 2,
			"name": PlayersConstantsScript.GREENLEE_NAME,
			"color": PlayersConstantsScript.GREENLEE_COLOR
		},
		{
			"order": 3,
			"name": PlayersConstantsScript.PINKNEY_NAME,
			"color": PlayersConstantsScript.PINKNEY_COLOR
		},
		{
			"order": 4,
			"name": PlayersConstantsScript.BLUEBELL_NAME,
			"color": PlayersConstantsScript.BLUEBELL_COLOR
		},
		{
			"order": 5,
			"name": PlayersConstantsScript.WILLEM_NAME,
			"color": PlayersConstantsScript.WILLEM_COLOR
		},
		{
			"order": 6,
			"name": PlayersConstantsScript.GREYDON_NAME,
			"color": PlayersConstantsScript.GREYDON_COLOR
		},
	]


## Instantiate one AI player for every character not already taken by a human.
static func create_opponents(human_players: Array) -> Array[Player]:
	var taken_orders := {}
	for human in human_players:
		taken_orders[human.order] = true

	var opponents: Array[Player] = []
	for entry in roster():
		if taken_orders.has(entry["order"]):
			continue
		var ai_player: Player = PLAYER_SCENE.instantiate()
		ai_player.player_name = entry["name"]
		ai_player.color = entry["color"]
		ai_player.order = entry["order"]
		ai_player.is_ai = true
		opponents.append(ai_player)
	return opponents
