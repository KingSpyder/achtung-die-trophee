class_name Player
extends CharacterBody2D

signal player_died(player: Player, death_cause: int, collided_player: Player)

enum DeathCause { UNKNOWN, WALL, TRAIL, PLAYER, OUT_OF_BOUNDS }

const DEFAULT_SPEED: float = 100
const BASE_SIZE: float = 5.0

@export var player_name: String
@export var color: Color
@export var left_control: String
@export var right_control: String
@export var order: int

@export var speed: float = 100
@export var angular_speed: float = 2.85
@export var gate_open_time: float = 50 / speed
@export var head_preset: PlayerHeadPreset
@export var size: float = BASE_SIZE:
	set(value):
		size = value
		_refresh_head_and_collision_shape()

@export var score := 0

var direction := Vector2.RIGHT
var last_death_cause := DeathCause.UNKNOWN
var last_collided_player: Player = null

var is_laying_trail := false
var last_collision: KinematicCollision2D
var _speed_multipliers := {}
var _size_multipliers := {}
var _inverted_control_sources := {}

@onready var head: Sprite2D = %Head
@onready var arrow: Sprite2D = %Arrow
@onready var playercoll: CollisionShape2D = $PlayerCollisionShape
@onready var arrow_shader_material: ShaderMaterial = %Arrow.material.duplicate()


func _ready() -> void:
	head.z_index = 5
	_apply_head_preset(head_preset)
	_update_shaders()
	_setup_collision_layers()


func _update_shaders() -> void:
	%Arrow.material = arrow_shader_material
	arrow_shader_material.set_shader_parameter("color", color)


func _apply_head_preset(preset: PlayerHeadPreset) -> void:
	if preset == null:
		return
	if preset.head_texture != null:
		head.texture = preset.head_texture
	head.modulate = PlayerHeadPreset.HEAD_COLOR
	_refresh_head_and_collision_shape()


func _refresh_head_and_collision_shape() -> void:
	if not is_node_ready():
		return
	if head_preset == null:
		return
	head.scale = head_preset.get_head_scale_for_size(size)
	var scaled_collision_shape := head_preset.build_collision_shape_for_size(size)
	if scaled_collision_shape != null:
		playercoll.shape = null  # Clean up old shape reference before assigning new one
		playercoll.shape = scaled_collision_shape


## Set the player's collision layer and mask to collide with everything
## except its own RecentTrail layer.
func _setup_collision_layers() -> void:
	collision_layer = 1 | (1 << 1)  # Layer 1 for gameplay, layer 2 for powerup pickup
	_enable_trail_collision()


## Show the arrow indicating the player's direction.
func show_arrow() -> void:
	if arrow:
		arrow.visible = true


func _process(delta) -> void:
	if _is_player_authority():
		move(delta)
		if _check_collision() or _check_out_of_bounds():
			death()


## Check whether this playerScene belongs to the client.
## CURRENTLY BYPASSED, as we don't have multiplayer implemented, but will be useful when we do.
func _is_player_authority() -> bool:
	return true
	# return $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()


## Player movement and rotation based on input. We use move_and_collide to detect collisions.
func move(delta) -> void:
	#Rotation & Movement
	var left_pressed := _is_action_pressed_safe(player_name + "_left")
	var right_pressed := _is_action_pressed_safe(player_name + "_right")
	var current_alpha := head.self_modulate.a
	if _are_turn_controls_inverted():
		var inverted_color := PlayerHeadPreset.HEAD_COLOR_INVERTED
		inverted_color.a = current_alpha
		head.self_modulate = inverted_color
		var tmp := left_pressed
		left_pressed = right_pressed
		right_pressed = tmp
	else:
		var normal_color := PlayerHeadPreset.HEAD_COLOR
		normal_color.a = current_alpha
		head.self_modulate = normal_color

	# Only block rotation when multipliers freeze the player (factor == 0).
	# This keeps round-prep turning working even when base speed is 0.
	if _get_speed_multiplier_factor() > 0.0:
		if left_pressed:
			direction = direction.rotated(-angular_speed * delta)
		if right_pressed:
			direction = direction.rotated(angular_speed * delta)
	direction = direction.normalized()

	# we make sure the arrow point in the right direction
	arrow.position = Vector2(10 * direction.x, 10 * direction.y)
	arrow.rotation = direction.angle() + PI / 2

	velocity = _get_effective_speed() * direction
	last_collision = move_and_collide(velocity * delta)


func _is_action_pressed_safe(action_name: String) -> bool:
	if not InputMap.has_action(action_name):
		return false
	return Input.is_action_pressed(action_name)


## Equivalently means: has collided ?
func _check_collision() -> bool:
	if last_collision == null:
		return false
	return _identify_collider(last_collision.get_collider())


## Identify the type of collider and print a message.
## Return true if the collision should cause death, false if it should be ignored
## (e.g. touching own recent trail).
func _identify_collider(collider: Object) -> bool:
	if collider.is_in_group("Walls"):
		last_death_cause = DeathCause.WALL
		last_collided_player = null
		print(player_name, " hit a wall")
	elif collider.is_in_group("Trails"):
		# Check if this trail belongs to another player
		var trail_owner = collider.get_parent().player
		var trail_container = collider.get_name()
		print("Trail container: ", trail_container)
		if trail_owner == self and trail_container == "RecentTrail":
			# Ignore own recent trails
			print(player_name, " touched own trail (ignored)")
			return false
		last_death_cause = DeathCause.TRAIL
		last_collided_player = null
		print(player_name, " hit a trail")
	elif collider.is_in_group("Players"):
		last_death_cause = DeathCause.PLAYER
		last_collided_player = collider as Player
		print(player_name, " hit player ", collider.player_name)
	else:
		last_death_cause = DeathCause.UNKNOWN
		last_collided_player = null
		print(player_name, " hit unknown collider ", collider.name)
	return true


## Check if the player is out of bounds (i.e. outside the 800x800 area).
## Return true if out of bounds, false otherwise.
## TODO: HARDCODED BOUNDS, should be changed to use the actual screen size or a defined play area.
func _check_out_of_bounds() -> bool:
	if position.x > 0 and position.x < 800 and position.y > 0 and position.y < 800:
		return false
	last_death_cause = DeathCause.OUT_OF_BOUNDS
	last_collided_player = null
	print(player_name, " out of bounds")
	return true


## Remove players lines and trails. Stop gate timers.
func clean() -> void:
	is_laying_trail = false
	$TrailScene.clean_lines()
	$TrailScene.clean_trails()
	%GateOpenTimer.stop()
	%GateCloseTimer.stop()


## Activate the player's trail, and start the gate open timer.
func start_trail() -> void:
	_enable_trail_collision()
	is_laying_trail = true
	_start_gate_open_timer()


## Open a gate in the player's trail. Start the gate close timer.
func open_gate(indefinite_timer: bool = false) -> void:
	is_laying_trail = false
	_disable_trail_collision()
	if indefinite_timer:
		_stop_timers()
		return
	_start_gate_close_timer()


## Close the gate in the player's trail. Start the gate open timer.
func _close_gate() -> void:
	_enable_trail_collision()
	is_laying_trail = true
	_start_gate_open_timer()


## Disable collision with all trail layers (4 and above) but keep powerup collision.
func _disable_trail_collision() -> void:
	collision_mask &= 0x0F  # Keep only layers 0-3 (gameplay and powerups)


## Re-enable collision with all trail layers except this player's own.
func _enable_trail_collision() -> void:
	collision_mask = 0xFFFFFFFF
	collision_mask &= ~(1 << (order + 3))  # Exclude this player's RecentTrail layer


## Randomly chose a time to open the gate, between 1 and 4 seconds for now (value to change).
func _start_gate_open_timer():
	var random_delay = randf_range(1.0, 4.0)
	%GateOpenTimer.wait_time = random_delay
	%GateOpenTimer.start()


func _start_gate_close_timer():
	%GateCloseTimer.wait_time = gate_open_time
	%GateCloseTimer.start()


func _stop_timers() -> void:
	%GateOpenTimer.stop()
	%GateCloseTimer.stop()


func _on_gate_open_timer_timeout():
	open_gate()


func _on_gate_close_timer_timeout() -> void:
	_close_gate()


## Player death function. Stop the player's movement and
## emit the player_died signal to notify the game logic controller.
func death() -> void:
	# Stop process when player dies
	set_process(false)
	is_laying_trail = false
	if last_death_cause == DeathCause.PLAYER:
		player_died.emit(self, last_death_cause, last_collided_player)
	else:
		player_died.emit(self, last_death_cause, null)


## Reset the player to the initial state: score 0, ready for a new game.
func reset() -> void:
	set_process(true)
	is_laying_trail = false
	score = 0


func set_speed_multiplier(source_id: StringName, multiplier: float) -> void:
	_speed_multipliers[source_id] = maxf(multiplier, 0.0)


func remove_speed_multiplier(source_id: StringName) -> void:
	_speed_multipliers.erase(source_id)


func _get_effective_speed() -> float:
	return speed * _get_speed_multiplier_factor()


func _get_speed_multiplier_factor() -> float:
	var factor := 1.0
	for value in _speed_multipliers.values():
		factor *= float(value)
	return factor


func set_size_multiplier(source_id: StringName, multiplier: float) -> void:
	_size_multipliers[source_id] = maxf(multiplier, 0.0)
	_update_size_from_multipliers()


func remove_size_multiplier(source_id: StringName) -> void:
	_size_multipliers.erase(source_id)
	_update_size_from_multipliers()


func _get_effective_size() -> float:
	return BASE_SIZE * _get_size_multiplier_factor()


func _get_size_multiplier_factor() -> float:
	var factor := 1.0
	for value in _size_multipliers.values():
		factor *= float(value)
	return factor


func _update_size_from_multipliers() -> void:
	var effective_size := _get_effective_size()
	size = effective_size


func set_turn_controls_inverted(source_id: StringName, enabled: bool) -> void:
	if enabled:
		_inverted_control_sources[source_id] = true
		return
	_inverted_control_sources.erase(source_id)


func _are_turn_controls_inverted() -> bool:
	return not _inverted_control_sources.is_empty()
