# Hand drawn tail in level editor.
class_name LevelObstacle
extends Resource

@export var color := Color(0.8, 0.8, 0.8, 1)
@export var width := PlayersConstants.TRAIL_WIDTH
@export var points := PackedVector2Array()
