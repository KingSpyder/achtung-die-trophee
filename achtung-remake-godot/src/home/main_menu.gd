extends Control

func _ready() -> void:
	var host_button = $Host
	var join_button = $Join
	var start_online_button = $"Start Online"
	
	host_button.button_down.connect(NetworkController._on_host_button_down)
	join_button.button_down.connect(NetworkController._on_join_button_down)
	start_online_button.button_down.connect(NetworkController._on_start_online_button_down)

func _on_add_player_button_down() -> void:
	var playerSize = GameManager.players.size()
	var id = playerSize + 2
	GameManager.players[id] = {
			"id": id,
			"name": "guest" + str(id),
			"score": 0
		}


func _on_start_button_down() -> void:
	var scene = load("res://src/game/gameScene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()
