extends Line2D

const MAX_POINTS := 10000
var point = Vector2()

func _ready():
	# Clear default points
	clear_points()
	
func _process(_delta) -> void:
	point = get_parent().global_position
	add_point(point)
	
