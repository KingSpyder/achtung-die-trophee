extends Line2D

const MAX_POINTS := 10000
var point = Vector2()

func _ready():
	# Initialiser la position de départ
	clear_points()
	
func _process(_delta) -> void:
	point = get_parent().global_position
	add_point(point)
	
