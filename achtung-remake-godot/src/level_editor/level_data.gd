# Complete description of an edited level in the level editor.

class_name LevelData
extends Resource

const DEFAULT_GOAL_ZONE_RADIUS := 50.0

@export var level_name := "New level"
@export_multiline var objective_message := ""
@export var players: Array[LevelPlayerSpawn] = []
@export var obstacles: Array[LevelObstacle] = []
@export var gates: Array[LevelGate] = []
@export var has_goal_zone := false
@export var goal_zone_position := Vector2.ZERO
@export var goal_zone_radius := DEFAULT_GOAL_ZONE_RADIUS
@export var enable_powerups := false
