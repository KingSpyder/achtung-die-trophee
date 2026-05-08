## This script manages the trail left by the player in the game. It handles the creation
## of new trail segments, the movement of old segments to a separate layer, and the cleanup of
## trails when necessary. The trail is represented as a series of Line2D nodes for visual
## representation and CollisionShape2D nodes for collision detection. The trail is divided
## into two layers: RecentTrail for the most recent segments that the owning player will not
## collide with, and OldTrail for all older segments that can be collided with by any player.
extends Node2D

## How many segments should be kept in RecentTrail before moving them to OldTrail.
const AGE_SEGMENT_FOR_OLD := 10

const PlayerScript = preload("res://src/player/player.gd")
const PhysicsLayersScript = preload("res://src/configs/physics_layers.gd")

## Current line being drawn (between gates), used to set the color and width of new segments.
var current_line: Line2D

var latest_point := Vector2()
var previous_point := Vector2()

## To keep track of if the trail just started or just ended,
## in combination with player.is_laying_trail.
var player_was_laying_trail := false

@onready var player: PlayerScript = get_parent()
@onready var previous_size: float = get_size()


func _ready():
	setup_collision_layers()


## Put the trail shapes in the correct collision layers, to be properly detected by players.
## The RecentTrail layer is set to the player's order,
## so that only the owning player will not collide with it.
func setup_collision_layers() -> void:
	# Set collision layer names for this player's trails
	$RecentTrail.collision_layer = PhysicsLayersScript.recent_trail_mask(player.order)
	$RecentTrail.collision_mask = 0
	$OldTrail.collision_layer = 1 << PhysicsLayersScript.GAMEPLAY_BIT
	$OldTrail.collision_mask = 0


## Trail management logic: add line or not, and corresponding collision segments.
func _process(_delta) -> void:
	previous_point = latest_point
	latest_point = player.global_position
	# Size change logic
	var new_size := get_size()
	if new_size != previous_size:
		current_line = add_new_line()  # start a new line to change the width of the trail
		current_line.add_point(previous_point)  # add the current point to avoid a gap in the trail
		if player.is_laying_trail:
			# to make sure we can't go through the gap of size change
			$RecentTrail.add_child(new_end_segment())
			$RecentTrail.add_child(new_start_segment())
	previous_size = new_size
	# Trail logic
	# heuristic to detect teleportation, to prevent drawing a long trail segment
	var player_teleported := previous_point.distance_to(latest_point) > player.playfield_max.x / 2
	if player_teleported:
		current_line = add_new_line()
		if player.is_laying_trail:
			current_line.add_point(latest_point)
	# prevent killing the player when standing still
	var player_still := previous_point == latest_point
	if not player_still and not player_teleported:
		if player.is_laying_trail:
			if not player_was_laying_trail:
				#player just started new trail
				player_was_laying_trail = true
				current_line = add_new_line()
				$RecentTrail.add_child(new_start_segment())
			else:
				#middle of the trail
				for collision_segment in new_border_segments():
					$RecentTrail.add_child(collision_segment)
			current_line.add_point(latest_point)
		elif player_was_laying_trail:
			#player just ended tail : cap the collision shape
			$RecentTrail.add_child(new_end_segment())
			player_was_laying_trail = false
		# Move the oldest segment to $OldTrail if too many in RecentTrail
		while $RecentTrail.get_child_count() > AGE_SEGMENT_FOR_OLD:
			move_recent_to_old()


## Utility to calculate the perpendicular vector to the trail,
## to find the borders of the trail (not the center line).
func perpendicular_vector() -> Vector2:
	return get_parent().direction.rotated(PI / 2).normalized() * get_size()


## Create a new generic collision segment.
func new_collision_segment() -> CollisionShape2D:
	var collision_segment = CollisionShape2D.new()
	collision_segment.shape = SegmentShape2D.new()
	collision_segment.debug_color = "dark green"
	return collision_segment


## Create the two collision segments on the sides of the trail.
func new_border_segments() -> Array[CollisionShape2D]:
	var segments: Array[CollisionShape2D] = []
	var perp_vec := perpendicular_vector()
	for order in [-1, +1]:
		var collision_segment = new_collision_segment()
		collision_segment.shape.a = previous_point + order * perp_vec / 2
		collision_segment.shape.b = latest_point + order * perp_vec / 2
		segments.append(collision_segment)
	return segments


## Create the collision segment at the start of the trail, to cap it.
func new_start_segment() -> CollisionShape2D:
	var perp_vec := perpendicular_vector()
	var collision_segment = new_collision_segment()
	collision_segment.shape.a = previous_point + perp_vec / 2
	collision_segment.shape.b = previous_point - perp_vec / 2
	return collision_segment


## Create the collision segment at the end of the trail, to cap it.
func new_end_segment() -> CollisionShape2D:
	var perp_vec := perpendicular_vector()
	var collision_segment = new_collision_segment()
	collision_segment.shape.a = latest_point + perp_vec / 2
	collision_segment.shape.b = latest_point - perp_vec / 2
	return collision_segment


## Move the oldest segment from RecentTrail to OldTrail,
## to keep the RecentTrail with a limited number of segments.
func move_recent_to_old() -> void:
	var oldest: CollisionShape2D = $RecentTrail.get_child(0)
	$RecentTrail.remove_child(oldest)
	$OldTrail.add_child(oldest)
	oldest.debug_color = "green"


## Get parent color.
func get_color() -> Color:
	var parent: PlayerScript = get_parent()
	if parent != null:
		return parent.color
	return Color(0.992, 0.0, 1.0, 1.0)


## Get parent size.
func get_size() -> float:
	var parent: PlayerScript = get_parent()
	if parent != null:
		return parent.size
	return 1.0


## Create a new Line2D for the visual representation of the trail,
## with the correct color and width. Store it in the Lines node.
func add_new_line() -> Line2D:
	var new_line = Line2D.new()
	new_line.set_default_color(get_color())
	new_line.set_width(get_size())
	$Lines.add_child(new_line)
	return new_line


## Cleanup function to free trail segments.
func clean_trails() -> void:
	for segment in $RecentTrail.get_children():
		$RecentTrail.remove_child(segment)
		segment.queue_free()
	for segment in $OldTrail.get_children():
		$OldTrail.remove_child(segment)
		segment.queue_free()


## Cleanup function to free lines.
func clean_lines() -> void:
	for line in $Lines.get_children():
		$Lines.remove_child(line)
		line.queue_free()
	player_was_laying_trail = false
	latest_point = Vector2()
	previous_point = Vector2()
