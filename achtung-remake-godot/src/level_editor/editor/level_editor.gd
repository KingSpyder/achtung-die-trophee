class_name LevelEditor
extends Control

enum ControlCaptureState { IDLE, WAITING_LEFT, WAITING_RIGHT }

const TOOL := LevelEditorCanvas.Tool
const DEFAULT_PLAYER_COLORS : Array[Color] = [
		PlayersConstants.FRED_COLOR,
		PlayersConstants.GREENLEE_COLOR,
		PlayersConstants.PINKNEY_COLOR,
		PlayersConstants.BLUEBELL_COLOR,
		PlayersConstants.WILLEM_COLOR,
		PlayersConstants.GREYDON_COLOR
]
const MIN_DRAG_FOR_DIRECTION := 8.0
const PLAYER_PICK_RADIUS := 14.0
const OBSTACLE_PICK_MARGIN := 6.0

var _tool_group := ButtonGroup.new()
var _undo_stack: Array[Dictionary] = []
var _control_capture_state := ControlCaptureState.IDLE

@onready var canvas: LevelEditorCanvas = %Canvas
@onready var level_runner: LevelRunner = %LevelRunner
@onready var editor_ui: Control = %EditorUI
@onready var level_name_edit: LineEdit = %LevelNameEdit
@onready var level_list: OptionButton = %LevelList
@onready var player_name_edit: LineEdit = %PlayerNameEdit
@onready var left_key_edit: LineEdit = %LeftKeyEdit
@onready var right_key_edit: LineEdit = %RightKeyEdit
@onready var control_button: Button = %ControlButton
@onready var player_color_button: ColorPickerButton = %PlayerColorButton
@onready var obstacle_color_button: ColorPickerButton = %ObstacleColorButton
@onready var width_spin: SpinBox = %WidthSpin
@onready var gate_radius_spin: SpinBox = %GateRadiusSpin
@onready var goal_radius_spin: SpinBox = %GoalRadiusSpin
@onready var new_button: Button = %NewButton
@onready var load_button: Button = %LoadButton
@onready var save_button: Button = %SaveButton
@onready var test_button: Button = %TestButton
@onready var undo_button = %UndoButton
@onready var status_label: Label = %StatusLabel
@onready var tool_buttons := {
	TOOL.ERASE: %ToolErase,
	TOOL.PLAYER: %ToolPlayer,
	TOOL.OBSTACLE: %ToolObstacle,
	TOOL.GATE: %ToolGate,
	TOOL.GOAL: %ToolGoal}

func _ready() -> void:
	for tool_id in tool_buttons:
		var button: Button = tool_buttons[tool_id]
		button.toggle_mode = true
		button.button_group = _tool_group
		button.pressed.connect(_select_tool.bind(tool_id))

	canvas.set_level(LevelData.new())
	_sync_canvas_properties()
	_select_tool(TOOL.PLAYER)
	tool_buttons[TOOL.PLAYER].button_pressed = true
	_refresh_level_list()
	_set_status(
		"Chose a tool to place into arena. Left click to place, right click to cancel.\n"
		+ "Press ESC to cancel pending obstacle."
	)

func _unhandled_key_input(event: InputEvent) -> void:
	if not editor_ui.visible or not event.is_pressed() or event.is_echo():
		return
	var key_event := event as InputEventKey
	if key_event == null:
		return
	if _control_capture_state != ControlCaptureState.IDLE:
		_capture_control_key(key_event)
		return
	if key_event.keycode == KEY_Z and key_event.ctrl_pressed:
		_undo()
	elif key_event.keycode == KEY_ENTER or key_event.keycode == KEY_KP_ENTER:
		_close_pending_obstacle()
	elif key_event.keycode == KEY_ESCAPE and canvas.has_pending_obstacle():
		canvas.clear_pending()
		_set_status("Current obstacle canceled.")
	else:
		return
	get_viewport().set_input_as_handled()

func _start_control_capture() -> void:
	_control_capture_state = ControlCaptureState.WAITING_LEFT
	control_button.text = "Press left control..."
	control_button.release_focus()

func _capture_control_key(key_event: InputEventKey) -> void:
	if key_event.keycode == KEY_ESCAPE:
		_control_capture_state = ControlCaptureState.IDLE
		control_button.text = "Control"
	elif key_event.keycode != KEY_SPACE and key_event.keycode != KEY_NONE:
		var key_name := key_event.as_text()
		if _control_capture_state == ControlCaptureState.WAITING_LEFT:
			left_key_edit.text = key_name
			_control_capture_state = ControlCaptureState.WAITING_RIGHT
			control_button.text = "Press right control..."
		else:
			right_key_edit.text = key_name
			_control_capture_state = ControlCaptureState.IDLE
			control_button.text = "Control"
	get_viewport().set_input_as_handled()

# --- Tools --------------------------------------------------------------------

func _select_tool(tool_id: int) -> void:
	if canvas.active_tool != tool_id:
		_close_pending_obstacle(true)
	canvas.active_tool = tool_id
	canvas.queue_redraw()

func _on_canvas_pressed(canvas_position: Vector2, button_index: int) -> void:
	if button_index == MOUSE_BUTTON_RIGHT:
		_close_pending_obstacle()
		return
	if button_index != MOUSE_BUTTON_LEFT:
		return
	match canvas.active_tool:
		TOOL.PLAYER:
			canvas.drag_origin = canvas_position
			canvas.is_dragging = true
		TOOL.OBSTACLE:
			canvas.add_pending_point(canvas_position)
			_set_status("Right click or ENTER to finish obstacle. ESC to cancel.")
		TOOL.GATE:
			_add_gate(canvas_position)
		TOOL.GOAL:
			_place_goal_zone(canvas_position)
		TOOL.ERASE:
			_erase_at(canvas_position)
	canvas.queue_redraw()

func _on_canvas_released(canvas_position: Vector2, button_index: int) -> void:
	if button_index != MOUSE_BUTTON_LEFT:
		return
	if canvas.active_tool == TOOL.PLAYER and canvas.is_dragging:
		canvas.is_dragging = false
		var drag := canvas_position - canvas.drag_origin
		var direction := (
			drag.normalized() if drag.length() >= MIN_DRAG_FOR_DIRECTION else Vector2.RIGHT
		)
		_add_player(canvas.drag_origin, direction)
	canvas.queue_redraw()

func _on_canvas_moved(_canvas_position: Vector2) -> void:
	pass

# --- Object creation ----------------------------------------------------------

func _add_player(spawn_position: Vector2, direction: Vector2) -> void:
	var spawn := LevelPlayerSpawn.new()
	spawn.player_name = player_name_edit.text
	spawn.color = player_color_button.color
	spawn.position = spawn_position
	spawn.direction = direction
	spawn.left_control = left_key_edit.text.strip_edges()
	spawn.right_control = right_key_edit.text.strip_edges()
	canvas.level.players.push_back(spawn)
	_undo_stack.push_back({"kind": "player"})
	_prepare_next_player_defaults()
	_set_status(
		"Player '%s' added (%s / %s)."
		% [spawn.player_name, spawn.left_control, spawn.right_control]
	)

func _close_pending_obstacle(silent: bool = false) -> void:
	if not canvas.has_pending_obstacle():
		return
	var points := canvas.take_pending_points()
	if points.size() < 2:
		if not silent:
			_set_status("Obstacle needs at least 2 points.")
		return
	var obstacle := LevelObstacle.new()
	obstacle.color = obstacle_color_button.color
	obstacle.width = width_spin.value
	obstacle.points = points
	canvas.level.obstacles.push_back(obstacle)
	_undo_stack.push_back({"kind": "obstacle"})
	if not silent:
		_set_status("Obstacle added with %d points." %points.size())

func _add_gate(gate_position: Vector2) -> void:
	var gate := LevelGate.new()
	gate.position = gate_position
	gate.radius = gate_radius_spin.value
	canvas.level.gates.push_back(gate)
	_undo_stack.push_back({"kind": "gate"})
	_set_status("Gate added at %s." % gate_position)

func _place_goal_zone(zone_position: Vector2):
	var level := canvas.level
	_undo_stack.push_back(
		{
			"kind": "goal",
			"had_goal": level.has_goal_zone,
			"position": level.goal_zone_position,
			"radius": level.goal_zone_radius,
		}
	)
	level.has_goal_zone = true
	level.goal_zone_position = zone_position
	level.goal_zone_radius = goal_radius_spin.value
	_set_status("Goal zone placed at %s." % zone_position)

func _erase_at(point: Vector2) -> void:
	var level := canvas.level
	for index in range(level.players.size() - 1, -1, -1):
		if level.players[index].position.distance_to(point) <= PLAYER_PICK_RADIUS:
			level.players.remove_at(index)
			_set_status("Player removed.")
			return
	for index in range(level.gates.size() - 1, -1, -1):
		if level.gates[index].position.distance_to(point) <= level.gates[index].radius:
			level.gates.remove_at(index)
			_set_status("Gate removed.")
			return
	for index in range(level.obstacles.size() - 1, -1, -1):
		var obstacle := level.obstacles[index]
		var reach := obstacle.width * 0.5 + OBSTACLE_PICK_MARGIN
		if _distance_to_polyline(point, obstacle.points) <= reach:
			level.obstacles.remove_at(index)
			_set_status("Obstacle removed.")
			return
	if level.has_goal_zone:
		level.has_goal_zone = false
		_set_status("Goal zone removed.")
		return
	_set_status("Nothing to remove here.")

func _undo() -> void:
	if canvas.has_pending_obstacle():
		canvas.undo_pending_point()
		return
	if _undo_stack.is_empty():
		return
	var entry: Dictionary = _undo_stack.pop_back()
	var level := canvas.level
	match entry["kind"]:
		"player":
			if not level.players.is_empty():
				level.players.remove_at(level.players.size() - 1)
			_prepare_next_player_defaults()
		"obstacle":
			if not level.obstacles.is_empty():
				level.obstacles.remove_at(level.obstacles.size() - 1)
		"gate":
			if not level.gates.is_empty():
				level.gates.remove_at(level.gates.size() - 1)
		"goal":
			level.has_goal_zone = entry["had_goal"]
			level.goal_zone_position = entry["position"]
			level.goal_zone_radius = entry["radius"]
	canvas.queue_redraw()
	_set_status("Last action undone.")

# --- Level management ---------------------------------------------------------

func _on_new_pressed() -> void:
	canvas.set_level(LevelData.new())
	_undo_stack.clear()
	level_name_edit.text = "new_level"
	_prepare_next_player_defaults()
	_set_status("New level created.")

func _on_load_pressed() -> void:
	if level_list.item_count == 0:
		_set_status("No level available.")
		return
	var level_name := level_list.get_item_text(maxi(level_list.selected, 0))
	var level := LevelManager.load_level(level_name)
	if level == null:
		_set_status("Failed to load '%s'." % level_name)
		return
	canvas.set_level(level)
	_undo_stack.clear()
	level_name_edit.text = level.level_name
	goal_radius_spin.value = level.goal_zone_radius
	_prepare_next_player_defaults()
	_set_status("Level '%s' loaded." % level_name)

func _on_save_pressed() -> void:
	_close_pending_obstacle(true)
	var level := canvas.level
	var file_name := LevelManager.sanitize_name(level_name_edit.text)
	if file_name.is_empty():
		_set_status("Level name empty.")
		return
	level.level_name = file_name
	var save_error := LevelManager.save_level(level)
	if save_error != OK:
		_set_status("Failed to save level: %d." % save_error)
		return
	level_name_edit.text = file_name
	_refresh_level_list(file_name)
	_set_status(
		"Level '%s' saved in %s."
		% [file_name, LevelManager.get_writable_dir().path_join(file_name + LevelManager.EXTENSION)]
		)

func _refresh_level_list(selected_name: String = "") -> void:
	level_list.clear()
	var index := 0
	for level_name in LevelManager.list_levels():
		level_list.add_item(level_name)
		if level_name == selected_name:
			level_list.select(index)
		index += 1

# --- Test preview -------------------------------------------------------------

func _on_test_pressed() -> void:
	_close_pending_obstacle(true)
	if canvas.level.players.is_empty():
		_set_status("Place a player to test.")
		return
	editor_ui.visible = false
	level_runner.start(canvas.level.duplicate(true))
	_set_status("Test started. Space to start/pause. Escape to return to editor.")

func _on_test_closed() -> void:
	editor_ui.visible = true
	_set_status("Return to editor.")

# --- Property bindings --------------------------------------------------------

func _sync_canvas_properties() -> void:
	canvas.player_color = player_color_button.color
	canvas.pending_color = obstacle_color_button.color
	canvas.pending_width = width_spin.value
	canvas.gate_radius = gate_radius_spin.value
	canvas.goal_zone_radius = goal_radius_spin.value
	canvas.queue_redraw()

func _on_player_color_changed(color: Color) -> void:
	canvas.player_color = color
	canvas.queue_redraw()

func _on_obstacle_color_changed(color: Color) -> void:
	canvas.pending_color = color
	canvas.queue_redraw()

func _on_width_changed(value: float) -> void:
	canvas.pending_width = value
	canvas.queue_redraw()

func _on_gate_radius_changed(value: float) -> void:
	canvas.gate_radius = value
	canvas.queue_redraw()

func _on_goal_radius_changed(value: float) -> void:
	canvas.goal_zone_radius = value
	canvas.queue_redraw()

func _prepare_next_player_defaults() -> void:
	var next_index := canvas.level.players.size()
	player_name_edit.text = "P%d" % (next_index + 1)
	player_color_button.color = DEFAULT_PLAYER_COLORS[next_index % DEFAULT_PLAYER_COLORS.size()]
	canvas.player_color = player_color_button.color

func _distance_to_polyline(point: Vector2, points: PackedVector2Array) -> float:
	if points.is_empty():
		return INF
	if points.size() == 1:
		return point.distance_to(points[0])
	var best := INF
	for index in range(points.size() - 1):
		var closest := Geometry2D.get_closest_point_to_segment(
			point, points[index], points[index + 1]
		)
		best = minf(best, point.distance_to(closest))
	return best

func _set_status(message: String) -> void:
	status_label.text = message + "\n"
