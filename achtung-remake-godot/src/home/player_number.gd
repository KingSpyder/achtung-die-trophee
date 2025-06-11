extends Label

func _ready():
	text = "0"
	
func _process(delta: float):
	text = str(GameManager.players.size())
