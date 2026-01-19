extends Node

enum GAME_STATUS {LOBBY, IN_GAME}
enum GAME_MODE_ENUM {ARCADE_MODE, CLASSIC_MODE}

var game_status = GAME_STATUS.LOBBY
var game_mode = GAME_MODE_ENUM.ARCADE_MODE

var players: Array[Player] = []

var remote_players = {}
