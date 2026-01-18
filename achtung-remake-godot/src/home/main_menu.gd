extends Control

func _ready() -> void:
	pass
	
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
