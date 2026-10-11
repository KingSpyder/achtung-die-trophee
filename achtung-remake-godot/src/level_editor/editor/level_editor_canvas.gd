## Interactive canvas node for the level editor.
## Renders the playfield, grid, obstacles, gates, players, and real-time tool previews.
## Handles mouse inputs (clicks, motion) and emits signals for level editing operations.
class_name LevelEditorCanvas
extends Control

signal pointer_pressed(canvas_position: Vector2, button_index: int)
signal pointer_moved(canvas_position: Vector2)
signal pointer_released(canvas_position: Vector2, button_index: int)

enum Tool {ERASE, PLAYER, OBSTACLE, GATE, GOAL}

const PLAYFIELD_SIZE: float = GamePhysicController.PLAYFIELD_SIZE
const WALL_COLOR := Color(1, 1, 0, 1)
const GRID_COLOR := Color(1, 1, 1, 0.06)
const GHOST_COLOR := Color(1, 1, 1, 0.35)
const GRID_STEP := PLAYFIELD_SIZE / 20.0
const PLAYER_MARKER_RADIUS := PlayersConstants.TRAIL_WIDTH
const PLAYER_ARROW_LEN := 20.0

var level: LevelData = LevelData.new()

# Obsatcle drawn point by point
var pending_points := PackedVector2Array()
var pending_color := Color(0.8, 0.8, 0.8, 1)
var pending_width := PlayersConstants.TRAIL_WIDTH

var active_tool : Tool = Tool.PLAYER
var gate_radius := PlayersConstants.GATE_LENGTH / 2.0
var goal_zone_radius := LevelData.DEFAULT_GOAL_ZONE_RADIUS

var player_color := Color(1, 0, 0, 1)
var pointer_position := Vector2.ZERO
var pointer_inside := false
# Press and drag to give player its starting direction
var drag_origin := Vector2.ZERO
var is_dragging := false
var _goal_zone_ping_elapsed := 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(PLAYFIELD_SIZE, PLAYFIELD_SIZE)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(func(): pointer_inside = true)
	mouse_exited.connect(
		func():
			pointer_inside = false
			queue_redraw()
	)

func _process(delta: float) -> void:
	if level.has_goal_zone:
		_goal_zone_ping_elapsed = fposmod(
			_goal_zone_ping_elapsed + delta, LevelGoalZone.PING_DURATION
		)
		queue_redraw()

func set_level(new_level: LevelData) -> void:
	level = new_level if new_level != null else LevelData.new()
	pending_points = PackedVector2Array()
	is_dragging = false
	queue_redraw()

func clamp_to_playfield(point: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, 0.0, PLAYFIELD_SIZE),
		clampf(point.y, 0.0, PLAYFIELD_SIZE)
	)

func has_pending_obstacle() -> bool:
	return not pending_points.is_empty()

func add_pending_point(point: Vector2) -> void:
	pending_points.append(point)
	queue_redraw()

func undo_pending_point() -> void:
	if pending_points.is_empty():
		return
	pending_points.remove_at(pending_points.size() - 1)
	queue_redraw()

func take_pending_points() -> PackedVector2Array:
	var points := pending_points
	pending_points = PackedVector2Array()
	queue_redraw()
	return points

func clear_pending() -> void:
	pending_points = PackedVector2Array()
	queue_redraw()

# Manage mouse actions
func _gui_input(event: InputEvent) -> void:
	var button_event := event as InputEventMouseButton
	if button_event != null:
		var button_position := clamp_to_playfield(button_event.position)
		if button_event.pressed:
			pointer_pressed.emit(button_position, button_event.button_index)
		else:
			pointer_released.emit(button_position, button_event.button_index)
		accept_event()
		return
	var motion_event := event as InputEventMouseMotion
	if motion_event != null:
		pointer_position = clamp_to_playfield(motion_event.position)
		pointer_inside = true
		pointer_moved.emit(pointer_position)
		queue_redraw()

func _draw() -> void:
	var playfield := Rect2(Vector2.ZERO, Vector2(PLAYFIELD_SIZE, PLAYFIELD_SIZE))
	draw_rect(playfield, Color.BLACK, true)
	var nb_step: int = int(PLAYFIELD_SIZE / GRID_STEP)
	for index in range(1, nb_step):
		var offset := index * GRID_STEP
		draw_line(Vector2(offset, 0), Vector2(offset, PLAYFIELD_SIZE), GRID_COLOR, 1.0)
		draw_line(Vector2(0, offset), Vector2(PLAYFIELD_SIZE, offset), GRID_COLOR, 1.0)
	draw_rect(playfield, WALL_COLOR, false, WallScene.THICKNESS)

	_draw_obstacles()
	_draw_pending_obstacle()
	_draw_gates()
	_draw_players()
	_draw_goal_zone()
	_draw_tool_ghost()

func _draw_obstacles() -> void:
	for obstacle in level.obstacles:
		if obstacle == null:
			continue
		for run in LevelBuilder.carve_polyline(obstacle.points, level.gates):
			_draw_run(run, obstacle.color, obstacle.width)

func _draw_pending_obstacle() -> void:
	if pending_points.is_empty():
		return
	var preview := pending_points.duplicate()
	if pointer_inside and active_tool == Tool.OBSTACLE:
		preview.append(pointer_position)
	for run in LevelBuilder.carve_polyline(preview, level.gates):
		_draw_run(run, Color(pending_color, 0.65), pending_width)
	for point in pending_points:
		draw_circle(point, 3.0, Color.WHITE)

func _draw_run(run: PackedVector2Array, color: Color, width: float) -> void:
	if run.size() < 2:
		return
	draw_polyline(run, color, maxf(width, 1.0))

func _draw_gates() -> void:
	for gate in level.gates:
		if gate == null:
			continue
		draw_circle(gate.position, gate.radius, Color(0.2, 0.7, 1.0, 0.12))
		draw_arc(gate.position, gate.radius, 0.0, TAU, 48, Color(0.4, 0.8, 1.0, 0.9), 1.5)

func _draw_players() -> void:
	for spawn in level.players:
		if spawn == null:
			continue
		var heading := spawn.direction
		heading = heading.normalized()
		draw_circle(spawn.position, PLAYER_MARKER_RADIUS, spawn.color)
		_draw_arrow(spawn.position, heading, PLAYER_ARROW_LEN, spawn.color)

func _draw_arrow(origin: Vector2, heading: Vector2, length: float, color: Color) -> void:
	var tip := origin + heading * length
	draw_line(origin, tip, color, 2.0)
	var side := heading.rotated(PI / 2.0) * 5.0
	var base := tip - heading * 9.0
	draw_colored_polygon(PackedVector2Array([tip, base + side, base - side]), color)

func _draw_goal_zone() -> void:
	if not level.has_goal_zone:
		return
	var center := level.goal_zone_position
	var radius := level.goal_zone_radius
	draw_arc(
		center,
		radius,
		0.0,
		TAU,
		LevelGoalZone.ARC_POINTS,
		Color(LevelGoalZone.ZONE_COLOR, 0.3),
		1.5
	)

	var progress := _goal_zone_ping_elapsed / LevelGoalZone.PING_DURATION
	var ping_radius := radius * LevelGoalZone.PING_MAX_RADIUS_MULTIPLIER * progress
	var ping_color := Color(
		LevelGoalZone.ZONE_COLOR.r,
		LevelGoalZone.ZONE_COLOR.g,
		LevelGoalZone.ZONE_COLOR.b,
		LevelGoalZone.ZONE_COLOR.a * (1.0 - progress)
	)
	draw_arc(
		center, ping_radius, 0.0, TAU, LevelGoalZone.ARC_POINTS, ping_color, 2.0
	)

func _draw_tool_ghost() -> void:
	if not pointer_inside:
		return
	match active_tool:
		Tool.GATE:
			draw_arc(pointer_position, gate_radius, 0.0, TAU, 48, GHOST_COLOR, 1.5)
		Tool.PLAYER:
			var origin := drag_origin if is_dragging else pointer_position
			var heading := pointer_position - origin
			if heading.length_squared() <= 1.0:
				heading = Vector2.RIGHT
			draw_circle(origin, PLAYER_MARKER_RADIUS, Color(player_color, 0.5))
			_draw_arrow(
				origin, heading.normalized(), PLAYER_ARROW_LEN, Color(player_color, 0.6)
			)
		Tool.ERASE:
			draw_arc(pointer_position, 10.0, 0.0, TAU, 24, Color(1, 0.3, 0.3, 0.8), 1.5)
		Tool.OBSTACLE:
			draw_circle(pointer_position, 10, GHOST_COLOR)
		Tool.GOAL:
			draw_circle(pointer_position, goal_zone_radius, GHOST_COLOR, false, 1.5)
