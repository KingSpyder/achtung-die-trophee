class_name GameRoundAudioController
extends Node

const COVERAGE_GRID_SIZE := 400
const COVERAGE_THRESHOLD := 0.30
const MINIMUM_ROUND_TIME := 120.0
const COVERAGE_CHECK_INTERVAL := 5.0
const FINAL_MUSIC_OFFSET := 84.1

@onready var final_music: AudioStream = preload("res://assets/music/Chipzel - Courtesy - Super Hexagnon.mp3")
@onready var normal_music :AudioStream
@onready var game_physic_controller: GamePhysicController = %GameAreaScene.get_node("GameArea")

var _minimum_time_timer := Timer.new()
var _coverage_timer := Timer.new()
var _covered_cells := PackedByteArray()
var _processed_point_counts: Dictionary = {}
var _final_triggered := false


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

	_reset_coverage()


func _process(delta: float) -> void:
	if AudioManager.is_current_music(final_music):
		var current_time := AudioManager.music_player.get_playback_position()
		if current_time >= 129.4:
			AudioManager.music_player.seek(FINAL_MUSIC_OFFSET)


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
