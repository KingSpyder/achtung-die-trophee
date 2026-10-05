## Difficulty profiles for the computer-controlled players.
##
## The ActionScript original had a single, fixed behaviour (Field.as#calculateDirection) and no
## difficulty setting at all: it probed LEFT / RIGHT / STRAIGHT over a fraction of a turning
## circle, every frame, and always committed to the safest move. The profiles below keep that
## decision loop but change how far ahead the AI looks, how early it treats an obstacle as a
## threat, how precisely it steers and how often it makes a mistake.
##
## All distances are in pixels and are meant to be read against the turning radius
## (PlayersConstants.PLAYER_TURN_RADIUS, 35 px): getting around an obstacle costs roughly one
## radius of room ahead, so a profile that reacts below that distance is bound to clip walls.
class_name AiDifficulty
extends RefCounted

enum Level { EASY, NORMAL, HARD }

const LEVEL_LABELS := {
	Level.EASY: "Easy",
	Level.NORMAL: "Normal",
	Level.HARD: "Hard",
}

## How far ahead (px) the AI simulates each move. Anything beyond that is simply "clear".
var look_ahead_distance: float
## Distance at which an obstacle ahead becomes a threat worth turning for, as a multiple of the
## turning radius. Below 1.0 the AI commits too late to get around anything.
var urgency_factor: float
## Seconds between two decisions. 0 means the AI re-decides on every frame. An imminent
## collision always overrides this delay.
var reaction_time: float
## Probability, per decision, of ignoring the analysis and steering at random.
var blunder_chance: float
## Heading error (radians) tolerated before the AI bothers steering towards open space. A wide
## dead zone gives loose, meandering trajectories.
var aim_deadzone: float
## Extra clearance (px) kept around trails while probing the field. Stays well under half of
## PlayersConstants.GATE_LENGTH, otherwise the AI would consider every gate too narrow to try.
var safety_margin: float


static func profile(level: int) -> AiDifficulty:
	var difficulty := AiDifficulty.new()
	match level:
		Level.HARD:
			difficulty.look_ahead_distance = 450.0
			difficulty.urgency_factor = 6.4
			difficulty.reaction_time = 0.0
			difficulty.blunder_chance = 0.0
			difficulty.aim_deadzone = 0.25
			difficulty.safety_margin = 2.0
		Level.NORMAL:
			difficulty.look_ahead_distance = 320.0
			difficulty.urgency_factor = 4.2
			difficulty.reaction_time = 0.04
			difficulty.blunder_chance = 0.008
			difficulty.aim_deadzone = 0.45
			difficulty.safety_margin = 1.0
		Level.EASY:
			difficulty.look_ahead_distance = 240.0
			difficulty.urgency_factor = 2.5
			difficulty.reaction_time = 0.08
			difficulty.blunder_chance = 0.04
			difficulty.aim_deadzone = 0.75
			difficulty.safety_margin = 0.0
	return difficulty


static func label(level: int) -> String:
	return LEVEL_LABELS.get(level, LEVEL_LABELS[Level.EASY])
