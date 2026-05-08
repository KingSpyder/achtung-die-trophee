## Context object passed to power-up definitions when applying their effects.
## Contains relevant information about the current state of the game and the player
## collecting the power-up.
class_name PowerUpExecutionContext
extends RefCounted

const PlayerScript = preload("res://src/player/player.gd")
const GamePhysicControllerScript = preload("res://src/game/game_physic_controller.gd")

var collector: PlayerScript
var alive_players: Array[PlayerScript]
var game_physic_controller: GamePhysicControllerScript
var powerup_runtime_controller: Node


func _init(
	collector_player: PlayerScript,
	current_alive_players: Array[PlayerScript],
	current_game_physic_controller: GamePhysicControllerScript,
	current_powerup_runtime_controller: Node,
) -> void:
	collector = collector_player
	alive_players = current_alive_players
	game_physic_controller = current_game_physic_controller
	powerup_runtime_controller = current_powerup_runtime_controller
