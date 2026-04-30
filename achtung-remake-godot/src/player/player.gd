class_name Player
extends CharacterBody2D

signal player_died(player: Player)

const DEFAULT_SPEED: float = 100

@export var player_name: String
@export var color: Color
@export var left_control: String
@export var right_control: String
@export var order: int

@export var speed: float = 100
@export var angular_speed: float = 2.85
@export var gate_open_time: float = 50 / speed
@export var size: float = 5

@export var score := 0

var direction := Vector2.RIGHT

var is_laying_trail := false
var last_collision: KinematicCollision2D

@onready var head: Sprite2D = %Head
@onready var arrow: Sprite2D = %Arrow
@onready var playercoll: CollisionShape2D = $PlayerCollisionShape
# We need to duplicate resources to be used by multiple instances
@onready var head_shader_material: ShaderMaterial = %Head.material.duplicate()
@onready var arrow_shader_material: ShaderMaterial = %Arrow.material.duplicate()


func _ready() -> void:
	head.z_index = 5
	update_shaders()
	setup_collision_layers()


func update_shaders() -> void:
	%Head.material = head_shader_material
	#%Head.material.set_shader_parameter("radius", size)
	%Arrow.material = arrow_shader_material
	if color:
		arrow_shader_material.set_shader_parameter("color", color)


## Set the player's collision layer and mask to collide with everything
## except its own RecentTrail layer.
func setup_collision_layers() -> void:
	collision_layer = 1  # Player is in layer 1 (everything but RecentTrail layers)
	collision_mask = 0xFFFFFFFF  # Collide with everything but...(next line)
	collision_mask &= ~(1 << order)  # Exclude this player's RecentTrail layer


## Show the arrow indicating the player's direction.
func show_arrow() -> void:
	if arrow:
		arrow.visible = true


func _process(delta) -> void:
	if _is_player_authority():
		move(delta)
		if check_collision() or check_out_of_bounds():
			death()


## Check whether this playerScene belongs to the client.
## CURRENTLY BYPASSED, as we don't have multiplayer implemented, but will be useful when we do.
func _is_player_authority() -> bool:
	return true
	# return $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()


## Player movement and rotation based on input. We use move_and_collide to detect collisions.
func move(delta) -> void:
	#Rotation & Movement
	if _is_action_pressed_safe(player_name + "_left"):
		direction = direction.rotated(-angular_speed * delta)
	if _is_action_pressed_safe(player_name + "_right"):
		direction = direction.rotated(angular_speed * delta)
	direction = direction.normalized()

	# we make sure the arrow point in the right direction
	arrow.position = Vector2(10 * direction.x, 10 * direction.y)
	arrow.rotation = direction.angle() + PI / 2

	velocity = speed * direction
	last_collision = move_and_collide(velocity * delta)


func _is_action_pressed_safe(action_name: String) -> bool:
	if not InputMap.has_action(action_name):
		return false
	return Input.is_action_pressed(action_name)


## Equivalently means: has collided ?
func check_collision() -> bool:
	if last_collision == null:
		return false
	return _identify_collider(last_collision.get_collider())


## Identify the type of collider and print a message.
## Return true if the collision should cause death, false if it should be ignored
## (e.g. touching own recent trail).
func _identify_collider(collider: Object) -> bool:
	if collider.is_in_group("Walls"):
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
		print(player_name, " hit a trail")
	elif collider.is_in_group("Players"):
		print(player_name, " hit player ", collider.player_name)
	else:
		print(player_name, " hit unknown collider ", collider.name)
	return true


## Check if the player is out of bounds (i.e. outside the 800x800 area).
## Return true if out of bounds, false otherwise.
## TODO: HARDCODED BOUNDS, should be changed to use the actual screen size or a defined play area.
func check_out_of_bounds() -> bool:
	if position.x > 0 and position.x < 800 and position.y > 0 and position.y < 800:
		return false
	print(player_name, " out of bounds")
	return true


## Activate the player's trail, and start the gate open timer.
func start_trail() -> void:
	is_laying_trail = true
	start_gate_open_timer()


## Remove players lines and trails. Stop gate timers.
func clean() -> void:
	is_laying_trail = false
	$TrailScene.clean_lines()
	$TrailScene.clean_trails()
	%GateOpenTimer.stop()
	%GateCloseTimer.stop()


## Open a gate in the player's trail. Start the gate close timer.
func open_gate() -> void:
	is_laying_trail = false
	playercoll.disabled = true
	%GateCloseTimer.wait_time = gate_open_time
	%GateCloseTimer.start()


## Close the gate in the player's trail. Start the gate open timer.
func close_gate() -> void:
	$PlayerCollisionShape.disabled = false
	is_laying_trail = true
	start_gate_open_timer()


## Randomly chose a time to open the gate, between 1 and 4 seconds for now (value to change).
func start_gate_open_timer():
	var random_delay = randf_range(1.0, 4.0)
	%GateOpenTimer.wait_time = random_delay
	%GateOpenTimer.start()


func _on_gate_open_timer_timeout():
	open_gate()


func _on_gate_close_timer_timeout() -> void:
	close_gate()


## Player death function. Stop the player's movement and
## emit the player_died signal to notify the game logic controller.
func death() -> void:
	# Stop process when player dies
	set_process(false)
	is_laying_trail = false
	player_died.emit(self)


## Reset the player to the initial state: score 0, ready for a new game.
func reset() -> void:
	set_process(true)
	is_laying_trail = false
	score = 0
