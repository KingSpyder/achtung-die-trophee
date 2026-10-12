class_name LevelBuilder
extends Resource

const SAMPLE_STEP := 2.0 # Distance in px between two samples when checking gate position
# Carved the obstacle's polyline into multiple polylines, each one being a continuous run of points outside of any gate.
static func carve_polyline(points: PackedVector2Array, gates: Array) -> Array:
	var runs: Array = []
	if points.size() < 2:
		return runs
	var current_run := PackedVector2Array()
	for sample in _resample(points):
		if _is_inside_gate(sample, gates):
			if current_run.size() >= 2:
				runs.append(_simplify(current_run))
			current_run = PackedVector2Array()
		else:
			current_run.append(sample)
	if current_run.size() >= 2:
		runs.append(_simplify(current_run))
	return runs

# Build a Node2D containing the obstacle's visual and collision representation with gates already carved out.
static func build_obstacle(obstacle: LevelObstacle, gates: Array) -> Node2D:
	var root := Node2D.new()
	root.name = "GroundTrail"

	var body := StaticBody2D.new()
	body.name = "GroundTrailBody"
	body.add_to_group("Walls")
	body.collision_layer = 1 << PhysicsLayers.WALL_BIT
	body.collision_mask = 0
	root.add_child(body)

	for run in carve_polyline(obstacle.points, gates):
		var line := Line2D.new()
		line.points = run
		line.width = obstacle.width
		line.default_color = obstacle.color
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		root.add_child(line)
		for shape in build_run_collision(run, obstacle.width):
			body.add_child(shape)
	return root

# Create the collision segments for a run of points of the polyline with given width.
static func build_run_collision(run: PackedVector2Array, width: float) -> Array:
	var shapes: Array = []
	if run.size() < 2:
		return shapes
	for index in range(run.size() - 1):
		var from_point :=run[index]
		var to_point :=run[index + 1]
		var perp_vec := _segment_normal(from_point, to_point) * width * 0.5
		shapes.append(_segment_shape(from_point + perp_vec, to_point + perp_vec))
		shapes.append(_segment_shape(from_point - perp_vec, to_point + perp_vec))
	var new_segment_perp := _segment_normal(run[0], run[1]) * width * 0.5
	shapes.append(_segment_shape(run[0] + new_segment_perp, run[0] - new_segment_perp))
	var end_segment_perp := _segment_normal(run[run.size() - 2], run[run.size() - 1]) * width * 0.5
	shapes.append(_segment_shape(run[run.size() - 1] + end_segment_perp, run[run.size() - 1] - end_segment_perp))
	return shapes

static func build_goal_zone(level: LevelData) -> LevelGoalZone:
	var zone := LevelGoalZone.new()
	zone.setup(level.goal_zone_position, level.goal_zone_radius)
	return zone

# Give normal direction of a segment
static func _segment_normal(point_a: Vector2, point_b: Vector2) -> Vector2:
	var segment := point_b - point_a
	return segment.normalized().rotated(PI / 2.0)
	
static func _segment_shape(point_a: Vector2, point_b: Vector2) -> CollisionShape2D:
	var collision_shape := CollisionShape2D.new()
	var shape := SegmentShape2D.new()
	shape.a = point_a
	shape.b = point_b
	collision_shape.shape = shape
	collision_shape.debug_color = "dark green"
	return collision_shape

# Resampling to walk the polyline with SAMPLE_STEP step
static func _resample(points: PackedVector2Array) -> PackedVector2Array:
	var samples := PackedVector2Array()
	samples.append(points[0])
	for index in range(points.size() -1):
		var from_point := points[index]
		var to_point := points[index + 1]
		var segment_length := from_point.distance_to(to_point)
		var step_count := int(floor(segment_length / SAMPLE_STEP))
		for step in range (1, step_count + 1):
			samples.append(from_point.lerp(to_point, step * SAMPLE_STEP / segment_length))
		if samples[samples.size() -1].distance_to(to_point) > 0.01:
			samples.append(to_point)
	return samples

# Simplify a polyline by removing useless points to consider
static func _simplify(points: PackedVector2Array) -> PackedVector2Array:
	var simplify_tolerance := 0.35
	if points.size() <= 2:
		return points
	var simplified := PackedVector2Array([points[0]])
	var anchor := points[0]
	for index in range(1, points.size() - 1):
		var candidate := points[index]
		var closest := Geometry2D.get_closest_point_to_segment(candidate, anchor, points[index + 1])
		if candidate.distance_to(closest) > simplify_tolerance:
			simplified.append(candidate)
			anchor=candidate
	simplified.append(points[points.size() - 1])
	return simplified
	
# Check if a point is inside any of the gates
static func _is_inside_gate(point: Vector2, gates: Array) -> bool:
	for gate in gates:
		if gate == null:
			continue
		if point.distance_to(gate.position) <= gate.radius:
			return true
	return false
