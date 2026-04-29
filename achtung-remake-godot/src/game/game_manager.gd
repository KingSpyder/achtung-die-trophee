## This Singleton is used to manage the game state, and to share it between scenes. It also contains some global variables that are used in the game.
extends Node

## Global variables to describe the game state.
enum GAME_STATUS {
	LOBBY, 
	START_GAME, 
	ROUND_ENDED,
	ROUND_READY,
	IN_GAME, 
	PAUSED, 
	GAME_ENDED
}
enum GAME_MODE_ENUM { ARCADE_MODE, CLASSIC_MODE }

## Global variables to manage the game state.
var game_status = GAME_STATUS.LOBBY

var game_mode = GAME_MODE_ENUM.ARCADE_MODE

var remote_players = {}

var max_points: int
var min_points_difference := 2

## Array to list players.
var players: Array[Player] = []

## Array of players still alive in the current round.
var players_alive: Array[Player] = []

func sort_player_by_order(pA: Player, pB: Player):
	return pA.order > pB.order
