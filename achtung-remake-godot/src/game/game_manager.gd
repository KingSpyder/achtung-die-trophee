## This Singleton is used to manage the game state, and to share it between scenes.
## It also contains some global variables that are used in the game.
extends Node

## Global variables to describe the game state.
enum GameStatus { LOBBY, START_GAME, ROUND_ENDED, ROUND_READY, IN_GAME, PAUSED, GAME_ENDED }
enum GameMode { ARCADE_MODE, CLASSIC_MODE }

const PlayerScript = preload("res://src/player/player.gd")

## Global variables to manage the game state.
var game_status = GameStatus.LOBBY

var game_mode = GameMode.ARCADE_MODE

var remote_players = {}

var max_points: int
var min_points_difference := 2

## Array to list players.
var players: Array[PlayerScript] = []

## Array of players still alive in the current round.
var players_alive: Array[PlayerScript] = []

## Subset of `players` driven by the AI. Only filled when a single human plays: in that case
## every remaining character of the roster joins the game as a computer opponent.
var ai_players: Array[PlayerScript] = []

## Difficulty applied to the AI players, see AiDifficulty.Level. Set from the lobby.
var ai_difficulty: int = AiDifficulty.Level.NORMAL


func sort_player_by_order(p1: PlayerScript, p2: PlayerScript):
	return p1.order > p2.order
