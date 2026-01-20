extends Node

enum GAME_STATUS {
	LOBBY, 
	START_GAME, 
	START_ROUND, 
	IN_GAME, 
	PAUSED, 
	GAME_ENDED
}
enum GAME_MODE_ENUM { ARCADE_MODE, CLASSIC_MODE }

var game_status = GAME_STATUS.LOBBY
var game_mode = GAME_MODE_ENUM.ARCADE_MODE

var remote_players = {}

var max_points: int
var min_points_difference := 2

var players: Array[Player] = []
var players_alive: Array[Player] = []

func sort_player_by_order(pA: Player, pB: Player):
	return pA.order > pB.order
