# Complete description of an edited level in the level editor.

class_name LevelData
extends Resource

@export var level_name := "New level"
@export var players: Array[LevelPlayerSpawn] = []
@export var obstacles: Array[LevelObstacle] = []
@export var gates: Array[LevelGate] = []
@export var enable_powerups := false