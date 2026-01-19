extends Node

@onready var player

func _ready() -> void:
	for player in GameManager.players:
		print(player.player_name)
	#spawn_players()
