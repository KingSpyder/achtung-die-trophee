## Occupancy grid the AI players use to "see" the arena.
##
## Port of the Field / FieldPoint pair of the ActionScript original (Field.as): a fine grid
## remembers which player painted each cell, and a coarse 16x16 grid counts how busy each
## region of the arena is. The fine grid answers "can I go there?", the coarse one answers
## "where is there still room?" (findNearestEmptySpot).
##
## Godot stores trails as physics segments, which are far too expensive to raycast against
## dozens of times per AI per frame, hence this cheap parallel representation: it is painted
## once per frame from the players' positions and only ever read by the AI.
class_name AiField
extends RefCounted

## Size (px) of a fine grid cell. The original used sub-pixel cells; 2 px is precise enough
## for a 6 px wide trail and keeps the grid small.
const CELL_SIZE := 2.0
## Side of the coarse grid. Matches the original `detRes`.
const COARSE_RESOLUTION := 16

var bounds_min: Vector2
var bounds_max: Vector2

var _columns: int
var _rows: int
var _cells: PackedByteArray
var _coarse_counts: PackedInt32Array
var _coarse_cell_size: Vector2
var _coarse_capacity: int


func _init(playfield_min: Vector2, playfield_max: Vector2) -> void:
	bounds_min = playfield_min
	bounds_max = playfield_max
	var extent := bounds_max - bounds_min
	_columns = maxi(1, int(ceil(extent.x / CELL_SIZE)))
	_rows = maxi(1, int(ceil(extent.y / CELL_SIZE)))
	_coarse_cell_size = extent / float(COARSE_RESOLUTION)
	_coarse_capacity = maxi(
		1, int(_coarse_cell_size.x / CELL_SIZE) * int(_coarse_cell_size.y / CELL_SIZE)
	)
	_cells.resize(_columns * _rows)
	_coarse_counts.resize(COARSE_RESOLUTION * COARSE_RESOLUTION)
	clear()


## Forget every trail painted so far (new round).
func clear() -> void:
	_cells.fill(0)
	_coarse_counts.fill(0)


## Forget everything painted by one player, e.g. when their trails get wiped out.
func clear_owner(owner_id: int) -> void:
	for index in _cells.size():
		if _cells[index] != owner_id:
			continue
		_cells[index] = 0
		var coarse_index := _coarse_index_of_cell(index)
		_coarse_counts[coarse_index] = maxi(0, _coarse_counts[coarse_index] - 1)


## Paint the piece of trail a player drew between two consecutive frames.
func stamp_segment(owner_id: int, from: Vector2, to: Vector2, width: float) -> void:
	var samples := maxi(1, int(from.distance_to(to) / CELL_SIZE))
	for sample in samples + 1:
		_stamp_disc(owner_id, from.lerp(to, float(sample) / float(samples)), width * 0.5)


## True when `point` falls outside the arena or on an existing trail. The trail the querying
## player is currently laying right behind its own head is ignored: the original did the same
## with a per-cell tick stamp (Field.as#checkField).
func is_blocked(
	point: Vector2, ignore_owner_id: int, ignore_center: Vector2, ignore_radius: float
) -> bool:
	var cell := cell_of(point)
	if cell.x < 0 or cell.x >= _columns or cell.y < 0 or cell.y >= _rows:
		return true
	var owner_id := _cells[cell.y * _columns + cell.x]
	if owner_id == 0:
		return false
	if owner_id == ignore_owner_id and point.distance_to(ignore_center) <= ignore_radius:
		return false
	return true


func cell_of(point: Vector2) -> Vector2i:
	var local := point - bounds_min
	return Vector2i(floori(local.x / CELL_SIZE), floori(local.y / CELL_SIZE))


func coarse_cell_of(point: Vector2) -> Vector2i:
	var local := point - bounds_min
	return Vector2i(
		clampi(floori(local.x / _coarse_cell_size.x), 0, COARSE_RESOLUTION - 1),
		clampi(floori(local.y / _coarse_cell_size.y), 0, COARSE_RESOLUTION - 1)
	)


## Number of painted fine cells inside a coarse cell, i.e. how crowded that region is.
func coarse_count(column: int, row: int) -> int:
	return _coarse_counts[row * COARSE_RESOLUTION + column]


## Same as coarse_count(), normalised to 0 (empty region) .. 1 (fully painted region), so that
## crowding can be weighed against distances and angles.
func coarse_fill_ratio(column: int, row: int) -> float:
	return float(coarse_count(column, row)) / float(_coarse_capacity)


func coarse_cell_center(column: int, row: int) -> Vector2:
	return (
		bounds_min
		+ Vector2(
			(float(column) + 0.5) * _coarse_cell_size.x,
			(float(row) + 0.5) * _coarse_cell_size.y
		)
	)


## Paint a real disc, testing every candidate cell against the radius. Stamping the bounding
## square instead is cheaper but widens the trail by up to a cell in every direction, and a
## trail painted fatter than it is also eats both ends of every gate: a 15 px gate would show
## up as a 7 px slit that no player could fit through, so the AI would never even try.
func _stamp_disc(owner_id: int, point: Vector2, radius: float) -> void:
	var center := cell_of(point)
	var radius_cells := int(ceil(radius / CELL_SIZE))
	var radius_squared := radius * radius
	for offset_y in range(-radius_cells, radius_cells + 1):
		for offset_x in range(-radius_cells, radius_cells + 1):
			var column := center.x + offset_x
			var row := center.y + offset_y
			var cell_center := (
				bounds_min
				+ Vector2((float(column) + 0.5) * CELL_SIZE, (float(row) + 0.5) * CELL_SIZE)
			)
			if cell_center.distance_squared_to(point) <= radius_squared:
				_stamp_cell(owner_id, column, row)


## Only empty cells are painted, so the first player through a spot keeps ownership of it.
## This mirrors the original, where a FieldPoint was never overwritten.
func _stamp_cell(owner_id: int, column: int, row: int) -> void:
	if column < 0 or column >= _columns or row < 0 or row >= _rows:
		return
	var index := row * _columns + column
	if _cells[index] != 0:
		return
	_cells[index] = owner_id
	_coarse_counts[_coarse_index_of_cell(index)] += 1


func _coarse_index_of_cell(index: int) -> int:
	var column := index % _columns
	@warning_ignore("integer_division")
	var row := index / _columns
	var point := (
		bounds_min + Vector2((float(column) + 0.5) * CELL_SIZE, (float(row) + 0.5) * CELL_SIZE)
	)
	var coarse := coarse_cell_of(point)
	return coarse.y * COARSE_RESOLUTION + coarse.x
