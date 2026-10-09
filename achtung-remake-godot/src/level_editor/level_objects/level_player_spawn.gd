# Character spawn for level editor. 

class_name LevelPlayerSpawn
extends Resource

@export var player_name := "Newbie"
@export var color := Color(1, 0, 0, 1)
@export var position := Vector2.ZERO
@export var direction := Vector2.RIGHT
@export var left_control := "A"
@export var right_control := "Z"