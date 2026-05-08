class_name PhysicsLayers
extends RefCounted

# Godot uses bit indices for collision layers.
const GAMEPLAY_BIT := 0
const PLAYERS_PICKUP_BIT := 1
const WALL_BIT := 2
const POWERUP_TOKEN_BIT := 3
const RECENT_TRAIL_LAYER_OFFSET := 4

const NON_TRAIL_MASK := (1 << RECENT_TRAIL_LAYER_OFFSET) - 1


static func recent_trail_bit(player_order: int) -> int:
	return player_order + RECENT_TRAIL_LAYER_OFFSET


static func recent_trail_mask(player_order: int) -> int:
	return 1 << recent_trail_bit(player_order)
