## One brain, steering one AI player.
##
## Built on the decision loop of the ActionScript original (Field.as): simulate the three
## possible moves, keep the one that survives longest, and drift towards the emptiest part of
## the arena. Three things differ, because the original was written for a 30 fps Flash movie
## and showed it:
##
##  * distances, not fractions of a circle. The original looked ahead over a percentage of a
##    full turning circle, which is far too short: by the time an obstacle sits half a radius
##    away it is already impossible to avoid. Here the look-ahead is a distance in pixels and
##    an obstacle becomes a threat while there is still enough room to get around it.
##  * a turn probe turns for a quarter of a circle and then goes straight, instead of curling
##    into a full circle. It therefore measures where a dodge actually leads.
##  * decisions are sticky. A dodge is held until the way ahead is properly clear, and the AI
##    only steers towards open space once its heading is off by more than a dead zone. Without
##    this the AI flips between two near-equivalent moves on every single frame and wobbles on
##    the spot instead of going anywhere.
class_name AiController
extends RefCounted

const TURN_LEFT := -1
const GO_STRAIGHT := 0
const TURN_RIGHT := 1

## Distance (px) advanced by one simulated step. The turn applied per step is step / radius
## radians, so the simulated arc matches the real one whatever the player's speed is. Must
## stay below the trail width, otherwise a probe could step over a trail without seeing it.
const SIMULATION_STEP := 4.0
## Arc swept by a turn probe before it straightens up, as a fraction of a full circle. A
## quarter circle is a 90 degree dodge: enough to get around anything, short enough that the
## probe does not curl back onto the trail the player is about to lay.
const PROBE_ARC_RATIO := 0.25
## Arcs tried when looking for a way out, as fractions of a full circle. The short ones are
## what lets the AI aim at a gate: a 15 px hole is only reachable by barely bending the
## trajectory, never by the 90 degree swerve the original always simulated.
const ESCAPE_ARC_RATIOS: Array[float] = [0.03, 0.07, 0.13, 0.19, 0.25]
## Free distance (px) given up per pixel of arc when comparing escapes. Among trajectories
## that all survive, the straightest therefore wins: that is what makes the AI go *through* an
## opening rather than turn away from the wall it sits in.
const STRAIGHTNESS_PENALTY := 0.3
## A move has to beat the one already being applied by this much (px) to be worth switching
## to. This is what stops the AI from oscillating between two equivalent moves.
const SWITCH_MARGIN := 16.0
## Once a dodge is engaged, the way ahead has to be this much clearer than the threat distance
## before the AI straightens up again. Plain hysteresis on the "am I in danger" test.
const DANGER_HYSTERESIS := 1.4
## Fraction of the threat distance at which a collision is imminent enough to re-decide
## immediately, whatever the profile's reaction delay says.
const EMERGENCY_RATIO := 0.6
## Coarse cells scanned by _find_open_target(), in the original's order: the four direct
## neighbours first, then the ring around them.
const EMPTY_SPOT_OFFSETS: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 0),
	Vector2i(-2, 0),
	Vector2i(-1, 1),
	Vector2i(0, 2),
	Vector2i(1, 1),
	Vector2i(2, 0),
	Vector2i(1, -1),
	Vector2i(0, -2),
	Vector2i(-1, -1),
]
## Weights of the open-space score: how busy a region is, how far it is, and how far off the
## current heading it sits. The original only used the first two, with a random tie-break; on
## an empty arena every region scores zero, so that tie-break alone decided where to go and
## the AI simply drifted at random.
const CROWDING_WEIGHT := 1.0
const DISTANCE_WEIGHT := 0.35
const HEADING_WEIGHT := 0.45
## How far behind its own head (in trail widths) a player ignores its own fresh trail.
const SELF_TRAIL_GRACE_FACTOR := 2.5

var player: Player
var difficulty: AiDifficulty

var _field: AiField
var _decision := GO_STRAIGHT
var _time_since_decision := 0.0


func _init(ai_player: Player, ai_field: AiField, ai_difficulty: AiDifficulty) -> void:
	player = ai_player
	_field = ai_field
	difficulty = ai_difficulty


func reset() -> void:
	_decision = GO_STRAIGHT
	_time_since_decision = INF
	if is_instance_valid(player):
		player.ai_turn = GO_STRAIGHT


func update(delta: float) -> void:
	if not is_instance_valid(player):
		return
	_time_since_decision += delta
	if _time_since_decision >= difficulty.reaction_time or _is_decision_urgent():
		_time_since_decision = 0.0
		_decision = _choose_turn()
	player.ai_turn = _decision


## True when the move currently being applied is about to run into something. Re-deciding then
## overrides the reaction delay, so that a slow profile is sloppy rather than blind.
func _is_decision_urgent() -> bool:
	var radius := _turn_radius()
	var emergency := radius * difficulty.urgency_factor * EMERGENCY_RATIO
	return _probe(_decision, radius * TAU * PROBE_ARC_RATIO, emergency) < emergency


func _choose_turn() -> int:
	if difficulty.blunder_chance > 0.0 and randf() < difficulty.blunder_chance:
		return [TURN_LEFT, GO_STRAIGHT, TURN_RIGHT].pick_random()

	var radius := _turn_radius()
	var arc := radius * TAU * PROBE_ARC_RATIO
	var reach := maxf(difficulty.look_ahead_distance, arc)
	var urgency := radius * difficulty.urgency_factor

	var straight_free := _probe(GO_STRAIGHT, 0.0, reach)

	# A dodge in progress needs more room ahead than it took to engage it before it is dropped,
	# otherwise the AI straightens up and panics again on the very next frame.
	var threshold := urgency * (DANGER_HYSTERESIS if _decision != GO_STRAIGHT else 1.0)
	if straight_free < threshold:
		return _escape(straight_free, reach)
	return _cruise(_probe(TURN_LEFT, arc, reach), _probe(TURN_RIGHT, arc, reach), urgency)


## Something is in the way: take whichever move buys the most room, but hold the dodge already
## engaged as long as it stays among the best ones.
func _escape(straight_free: float, reach: float) -> int:
	var scores := {
		GO_STRAIGHT: straight_free,
		TURN_LEFT: _best_escape_score(TURN_LEFT, reach),
		TURN_RIGHT: _best_escape_score(TURN_RIGHT, reach),
	}
	var best_turn := GO_STRAIGHT
	for turn in scores:
		if scores[turn] > scores[best_turn]:
			best_turn = turn
	# Keep the dodge already engaged while it stays within a hair of the best option, so that
	# two near-equivalent ways out do not make the AI flip-flop between them.
	if (
		_decision != GO_STRAIGHT
		and _decision != best_turn
		and scores[_decision] >= scores[best_turn] - SWITCH_MARGIN
	):
		return _decision
	return best_turn


## Best any trajectory bending `turn` can achieve: try several arc lengths and keep the one
## that gets furthest, discounting long arcs. A short bend that threads an opening therefore
## beats a wide swerve that merely runs alongside the wall.
func _best_escape_score(turn: int, reach: float) -> float:
	var radius := _turn_radius()
	var best := -INF
	for ratio in ESCAPE_ARC_RATIOS:
		var arc := radius * TAU * ratio
		best = maxf(best, _probe(turn, arc, reach) - arc * STRAIGHTNESS_PENALTY)
	return best


## The way ahead is clear: glide towards the emptiest region, and only once the heading is off
## by more than the profile's dead zone. Steering on every tiny error is what makes an AI
## wobble permanently.
func _cruise(left_free: float, right_free: float, urgency: float) -> int:
	var error := _heading_error_to_open_space()
	if absf(error) <= difficulty.aim_deadzone:
		return GO_STRAIGHT
	if error < 0.0 and left_free >= urgency:
		return TURN_LEFT
	if error > 0.0 and right_free >= urgency:
		return TURN_RIGHT
	return GO_STRAIGHT


## Simulate the player committing to `turn` for `arc_length` px and then going straight, and
## return how far it gets before hitting something, capped at `total_length`. Measuring where
## a dodge leads, instead of just how long the turn itself survives, is what gives the AI
## actual anticipation.
func _probe(turn: int, arc_length: float, total_length: float) -> float:
	var angle_step := SIMULATION_STEP / _turn_radius()
	var half_width: float = player.size * 0.5 + difficulty.safety_margin
	# Playfield space, like AiField and Player._check_out_of_bounds(): the game area sits in a
	# MarginContainer, so global coordinates are shifted by the layout.
	var head := player.position
	var probe_position := head
	var angle := player.direction.angle()
	var travelled := 0.0
	while travelled < total_length:
		if turn != GO_STRAIGHT and travelled < arc_length:
			angle += turn * angle_step
		probe_position += Vector2.from_angle(angle) * SIMULATION_STEP
		travelled += SIMULATION_STEP
		# The original checked both edges of the trail, not just its centre line, so that the
		# AI does not try to squeeze through a gap narrower than itself.
		var side := Vector2.from_angle(angle + PI * 0.5) * half_width
		if (
			_is_blocked(probe_position, head)
			or _is_blocked(probe_position + side, head)
			or _is_blocked(probe_position - side, head)
		):
			return travelled - SIMULATION_STEP
	return total_length


func _is_blocked(point: Vector2, head: Vector2) -> bool:
	var probe := _wrap(point) if player.can_pass_borders() else point
	return _field.is_blocked(probe, player.order, head, player.size * SELF_TRAIL_GRACE_FACTOR)


## Signed angle between the current heading and the emptiest region around the player.
## Positive means the region sits on the right-hand side.
func _heading_error_to_open_space() -> float:
	var target := _find_open_target()
	var to_target := _field.coarse_cell_center(target.x, target.y) - player.position
	if to_target.length_squared() < 1.0:
		return 0.0
	return player.direction.angle_to(to_target)


## Emptiest coarse cell around the player, preferring close ones and ones already roughly
## ahead. Unlike the original this is fully deterministic: a target redrawn at random on every
## frame gives a heading that changes faster than the player can follow it.
func _find_open_target() -> Vector2i:
	var origin := _field.coarse_cell_of(player.position)
	var wraps := player.can_pass_borders()
	var best_cell := origin
	var best_score := INF
	for offset in EMPTY_SPOT_OFFSETS:
		var cell := origin + offset
		if wraps:
			cell = Vector2i(
				posmod(cell.x, AiField.COARSE_RESOLUTION),
				posmod(cell.y, AiField.COARSE_RESOLUTION)
			)
		elif (
			cell.x < 0
			or cell.x >= AiField.COARSE_RESOLUTION
			or cell.y < 0
			or cell.y >= AiField.COARSE_RESOLUTION
		):
			continue
		var offset_vector := Vector2(offset)
		var score := (
			_field.coarse_fill_ratio(cell.x, cell.y) * CROWDING_WEIGHT
			+ offset_vector.length() * DISTANCE_WEIGHT
			+ absf(player.direction.angle_to(offset_vector)) * HEADING_WEIGHT
		)
		if score < best_score:
			best_score = score
			best_cell = cell
	return best_cell


func _turn_radius() -> float:
	var turn_radius := player.get_effective_radius()
	if turn_radius <= 0.0:
		return PlayersConstants.PLAYER_TURN_RADIUS
	return turn_radius


func _wrap(point: Vector2) -> Vector2:
	var extent := _field.bounds_max - _field.bounds_min
	return (
		_field.bounds_min
		+ Vector2(
			fposmod(point.x - _field.bounds_min.x, extent.x),
			fposmod(point.y - _field.bounds_min.y, extent.y)
		)
	)
