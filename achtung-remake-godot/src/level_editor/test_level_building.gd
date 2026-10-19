extends Node

func _ready():
	var level = LevelData.new()
	level.level_name = "test_level"
	level.enable_powerups = false
	
	var p = LevelPlayerSpawn.new()
	p.player_name = "TestPlayer"
	p.color = Color.RED
	p.position = Vector2(1000, 1000)
	p.direction = Vector2.LEFT
	p.left_control = "Q"
	p.right_control = "S"
	level.players.append(p)
	
	var obs1 = LevelObstacle.new()
	obs1.color = Color.GRAY
	obs1.width = 10.0
	obs1.points = PackedVector2Array([Vector2(100, 300), Vector2(200, 300), Vector2(500, 300), Vector2(1000, 300), Vector2(1000, 600), Vector2(1100,800)])
	level.obstacles.append(obs1)
	
	var obs2 = LevelObstacle.new()
	obs2.color = Color.RED
	obs2.width = 5.0
	obs2.points = PackedVector2Array([Vector2(200, 500), Vector2(300, 500), Vector2(300, 600), Vector2(200, 600), Vector2(200, 500)])
	level.obstacles.append(obs2)
	
	var gate1 = LevelGate.new()
	gate1.position = Vector2(150, 300)
	gate1.radius = 6.0
	level.gates.append(gate1)
	
	var gate2 = LevelGate.new()
	gate2.position = Vector2(700, 300)
	gate2.radius = 6.0
	level.gates.append(gate2)
	
	var gate3 = LevelGate.new()
	gate3.position = Vector2(900, 305)
	gate3.radius = 6.0
	level.gates.append(gate3)
	
	
	for obstacle_data in level.obstacles:
		var obstacle_node = LevelBuilder.build_obstacle(obstacle_data, level.gates)
		add_child(obstacle_node)
	
