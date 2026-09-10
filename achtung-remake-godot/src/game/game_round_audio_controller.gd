class_name GameRoundAudioController
extends Node

const COVERAGE_GRID_SIZE := 400
const COVERAGE_THRESHOLD := 0.30
const MINIMUM_ROUND_TIME := 120.0
const COVERAGE_CHECK_INTERVAL := 5.0
const FINAL_MUSIC_OFFSET := 84.1

const THEOREM_MAX_DISTANCE := 100.0
const THEOREM_MAX_LONGITUDINAL_OFFSET := 100.0
const THEOREM_MAX_LATERAL_OFFSET := 80.0
const THEOREM_DIRECTION_DOT_THRESHOLD := 0.75
const THEOREM_MAX_DISTANCE_SQUARED := THEOREM_MAX_DISTANCE * THEOREM_MAX_DISTANCE
var _theorem_situation_active := false
var _theorem_timer := 0.0
const PlayerScript = preload("res://src/player/player.gd")

@export var final_music: AudioStream = preload("res://assets/music/Chipzel - Courtesy - Super Hexagnon.mp3")
@onready var normal_music :AudioStream
const TH_SOUND = preload("res://assets/sounds/Th-th-th-theorem.mp3")
const ITS_TIME_SOUND = preload("res://assets/sounds/It's theorem time.mp3")
@export var theorem_sounds: Array[AudioStream] = [
	TH_SOUND,
	ITS_TIME_SOUND,
]
@export var theorem_debug_enabled := false
@export var theorem_debug_player_index := 0
@onready var game_physic_controller: GamePhysicController = %GameAreaScene.get_node("GameArea")

var _minimum_time_timer := Timer.new()
var _coverage_timer := Timer.new()
var _covered_cells := PackedByteArray()
var _processed_point_counts: Dictionary = {}
var _final_triggered := false
var _theorem_debug_overlay: TheoremDebugOverlay


func _ready() -> void:
	_minimum_time_timer.one_shot = true
	_minimum_time_timer.wait_time = MINIMUM_ROUND_TIME
	_minimum_time_timer.timeout.connect(_on_minimum_time_reached)
	add_child(_minimum_time_timer)

	_coverage_timer.one_shot = false
	_coverage_timer.wait_time = COVERAGE_CHECK_INTERVAL
	_coverage_timer.timeout.connect(_check_coverage)
	add_child(_coverage_timer)

	normal_music = AudioManager.music_player.stream

	if theorem_debug_enabled:
		_theorem_debug_overlay = TheoremDebugOverlay.new()
		_theorem_debug_overlay.controller = self
		_theorem_debug_overlay.visible = theorem_debug_enabled
		_theorem_debug_overlay.z_index = 100
		game_physic_controller.add_child(_theorem_debug_overlay)

	_reset_coverage()


func _process(delta: float) -> void:
	if _theorem_debug_overlay != null:
		_theorem_debug_overlay.visible = theorem_debug_enabled
		if theorem_debug_enabled:
			_theorem_debug_overlay.queue_redraw()

	if AudioManager.is_current_music(final_music):
		var current_time := AudioManager.music_player.get_playback_position()
		if current_time >= 129.4:
			AudioManager.music_player.seek(FINAL_MUSIC_OFFSET)

	if _is_theorem_situation():
		if not _theorem_situation_active:
			play_theorem_sfx(2.0)
		_theorem_situation_active = true
		_theorem_timer = 5.0
	elif _theorem_timer > 0.0:
		_theorem_timer -= delta
		_theorem_situation_active = true
	else:
		_theorem_situation_active = false


func start_round() -> void:
	_minimum_time_timer.stop()
	_coverage_timer.stop()
	_reset_coverage()
	for player in GameManager.players:
		if player != null and is_instance_valid(player) and not player.trails_cleaned.is_connected(_reset_coverage):
			player.trails_cleaned.connect(_reset_coverage)
	_minimum_time_timer.start()


func stop_round() -> void:
	_minimum_time_timer.stop()
	_coverage_timer.stop()
	AudioManager.play_music(normal_music, 1.0, 0.0)


func _reset_coverage() -> void:
	_covered_cells.resize(COVERAGE_GRID_SIZE * COVERAGE_GRID_SIZE)
	_covered_cells.fill(0)
	_processed_point_counts.clear()
	_final_triggered = false


func _on_minimum_time_reached() -> void:
	_check_coverage()
	if not _final_triggered:
		_coverage_timer.start()


func _check_coverage() -> void:
	_update_coverage_grid()
	var coverage := _get_coverage_ratio()
	#print("Trail coverage: ", snapped(coverage * 100.0, 0.1), "%")

	if not _final_triggered and coverage >= COVERAGE_THRESHOLD:
		_final_triggered = true
		#print("Final battle triggered! Coverage: ", snapped(coverage * 100.0, 0.1), "%")
		if final_music is AudioStreamMP3 or final_music is AudioStreamOggVorbis:
			final_music.loop = true
			final_music.loop_offset = FINAL_MUSIC_OFFSET
		elif final_music is AudioStreamWAV:
			final_music.loop_mode = AudioStreamWAV.LOOP_FORWARD
			final_music.loop_begin = int(7.0 * final_music.mix_rate)
		AudioManager.play_music(final_music, 1.6, FINAL_MUSIC_OFFSET)
		_coverage_timer.stop()


func _update_coverage_grid() -> void:
	for player in GameManager.players:
		if player == null or not is_instance_valid(player):
			continue
		var lines := player.get_node_or_null("TrailScene/Lines")
		if lines == null:
			continue

		for line in lines.get_children():
			if not line is Line2D or line.points.size() < 2:
				continue

			var processed_points: int = _processed_point_counts.get(line, 0)
			var points: PackedVector2Array = line.points
			var first_segment := maxi(processed_points - 1, 0)
			for index in range(first_segment, points.size() - 1):
				_mark_segment(
					line.to_global(points[index]),
					line.to_global(points[index + 1]),
					line.width
				)
			_processed_point_counts[line] = points.size()


func _mark_segment(segment_start: Vector2, segment_end: Vector2, width: float) -> void:
	var bounds := game_physic_controller.get_playfield_bounds()
	var field_min: Vector2 = bounds["min"]
	var field_max: Vector2 = bounds["max"]
	var cell_size := (field_max.x - field_min.x) / COVERAGE_GRID_SIZE
	var distance := segment_start.distance_to(segment_end)
	var step := maxf(cell_size * 0.5, width * 0.5)
	var sample_count := maxi(1, ceili(distance / step))
	var radius := ceili(width / cell_size)

	for sample_index in range(sample_count + 1):
		var point := segment_start.lerp(segment_end, float(sample_index) / sample_count)
		var cell_x := floori((point.x - field_min.x) / cell_size)
		var cell_y := floori((point.y - field_min.y) / cell_size)
		for offset_y in range(-radius, radius + 1):
			for offset_x in range(-radius, radius + 1):
				_mark_cell(cell_x + offset_x, cell_y + offset_y)


func _mark_cell(cell_x: int, cell_y: int) -> void:
	if cell_x < 0 or cell_x >= COVERAGE_GRID_SIZE or cell_y < 0 or cell_y >= COVERAGE_GRID_SIZE:
		return
	_covered_cells[cell_y * COVERAGE_GRID_SIZE + cell_x] = 1


func _get_coverage_ratio() -> float:
	var covered_cells := 0
	for cell in _covered_cells:
		covered_cells += cell
	return float(covered_cells) / _covered_cells.size()


func play_theorem_sfx(volume_factor: float = 1.0) -> void:
	if theorem_sounds.is_empty():
		return
	var chosen_sound = theorem_sounds.pick_random()
	print("chosen_sound: ", chosen_sound)
	var theorem_volume_multipliers: Dictionary = {
	TH_SOUND: 1.8,
	ITS_TIME_SOUND: 1.1,
	}
	AudioManager.play_sfx(chosen_sound, volume_factor*theorem_volume_multipliers.get(chosen_sound, 1.0))


## Detect a player framed by two nearby players moving in the same direction.
## The nearest candidate on each side of the center is enough, so this stays O(n^2).
func _is_theorem_situation() -> bool:
	var alive_players: Array[PlayerScript] = GameManager.players_alive
	if alive_players.size() < 3:
		return false

	for center in alive_players:
		var movement_direction := center.direction.normalized()
		if movement_direction.is_zero_approx():
			continue
		var normal := movement_direction.orthogonal()
		var left_player: PlayerScript = null
		var right_player: PlayerScript = null
		var nearest_left_distance_squared := THEOREM_MAX_DISTANCE_SQUARED
		var nearest_right_distance_squared := THEOREM_MAX_DISTANCE_SQUARED

		for candidate in alive_players:
			if candidate == center:
				continue
			if movement_direction.dot(candidate.direction.normalized()) < THEOREM_DIRECTION_DOT_THRESHOLD:
				continue

			var relative_position := candidate.position - center.position
			var longitudinal_offset := absf(relative_position.dot(movement_direction))
			var lateral_offset := relative_position.dot(normal)
			if longitudinal_offset > THEOREM_MAX_LONGITUDINAL_OFFSET:
				continue
			if absf(lateral_offset) > THEOREM_MAX_LATERAL_OFFSET:
				continue

			var distance_squared := relative_position.length_squared()
			if distance_squared > THEOREM_MAX_DISTANCE_SQUARED:
				continue
			if lateral_offset < 0.0 and distance_squared < nearest_left_distance_squared:
				nearest_left_distance_squared = distance_squared
				left_player = candidate
			elif lateral_offset > 0.0 and distance_squared < nearest_right_distance_squared:
				nearest_right_distance_squared = distance_squared
				right_player = candidate

		if left_player != null and right_player != null:
			return true

	return false


class TheoremDebugOverlay extends Node2D:
	var controller: GameRoundAudioController

	const DISTANCE_COLOR := Color(0.2, 0.8, 1.0, 0.65)
	const LONGITUDINAL_COLOR := Color(1.0, 0.75, 0.2, 0.9)
	const LATERAL_COLOR := Color(1.0, 0.35, 0.35, 0.9)
	const CENTER_COLOR := Color(1.0, 1.0, 1.0, 0.95)

	func _draw() -> void:
		if controller == null or not controller.theorem_debug_enabled:
			return

		var players: Array[PlayerScript] = GameManager.players_alive
		if players.is_empty():
			return
		if controller.theorem_debug_player_index < 0 or controller.theorem_debug_player_index >= players.size():
			return

		var center_player := players[controller.theorem_debug_player_index]
		if center_player == null or not is_instance_valid(center_player):
			return

		var direction := center_player.direction.normalized()
		if direction.is_zero_approx():
			return
		var normal := direction.orthogonal()
		var center := center_player.position

		draw_arc(center, controller.THEOREM_MAX_DISTANCE, 0.0, TAU, 96, DISTANCE_COLOR, 2.0)
		draw_line(
			center,
			center + direction * controller.THEOREM_MAX_LONGITUDINAL_OFFSET,
			LONGITUDINAL_COLOR,
			3.0
		)
		draw_line(
			center - normal * controller.THEOREM_MAX_LATERAL_OFFSET,
			center + normal * controller.THEOREM_MAX_LATERAL_OFFSET,
			LATERAL_COLOR,
			3.0
		)
		draw_circle(center, 5.0, CENTER_COLOR)
