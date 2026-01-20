class_name Player
extends CharacterBody2D

signal player_died(player: Player)

const default_speed: float = 100

@export var player_name: String
@export var color: Color
@export var left_control: String
@export var right_control: String
@export var order: int

@export var speed: float = 100
@export var angular_speed : float = 2.85
@export var gate_open_time : float = 50/speed

@export var score := 0

var direction := Vector2.RIGHT
var last_point := Vector2.ZERO

var trailScene: PackedScene = preload("res://src/trail/trailScene.tscn")

@onready var trail
@onready var head: Sprite2D = %Head
@onready var arrow: Sprite2D = %Arrow
@onready var playercoll: CollisionShape2D = $CollisionShape2D
@onready var gate_open_timer: Timer = %GateOpenTimer
@onready var gate_close_timer: Timer = %GateCloseTimer
# We need to duplicate resources to be used by multiple instances
@onready var head_shader_material: ShaderMaterial = %Head.material.duplicate()
@onready var arrow_shader_material: ShaderMaterial = %Arrow.material.duplicate()

var trail_count := 0

func _ready() -> void:
	update_shaders()
	
func update_shaders() -> void:
	%Head.material = head_shader_material
	%Arrow.material = arrow_shader_material
	if(color):
		head_shader_material.set_shader_parameter("circle_color", color)
		arrow_shader_material.set_shader_parameter("color", color)


func show_arrow() -> void:
	if(arrow):
		arrow.visible = true

func _process(delta) -> void:
	if(_is_player_authority()):
		move(delta)
		if check_collision() or check_out_of_bounds():
			death()

# Check whether this playerScene belongs to the client
func _is_player_authority() -> bool:
	return true
	# return $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()
		
func move(delta) -> void:
	#Rotation & Movement
	if Input.is_action_pressed(player_name + "_left"):
		direction = direction.rotated(-angular_speed * delta)
	if Input.is_action_pressed(player_name + "_right"):
		direction = direction.rotated(angular_speed * delta)
	direction = direction.normalized()
	
	# we make sure the arrow point in the right direction
	arrow.position = Vector2(10 * direction.x, 10 * direction.y)
	arrow.rotation = direction.angle() + PI/2
	
	velocity = speed * direction
	move_and_slide()
		
func check_collision() -> bool:
	if get_slide_collision_count() <= 0:
		return false
	var collision = get_slide_collision(0)
	_identify_collider(collision.get_collider())
	return true

func _identify_collider(collider: Object) -> void:
	if collider.is_in_group("Walls"):
		print(player_name , " hit a wall")
	elif collider.is_in_group("Trails"):
		print(player_name , " hit a trail")
	elif collider.is_in_group("Players"):
		print(player_name , " hit player ", collider.player_name)
	else:
		print(player_name , " hit unknown collider ", collider.name)

func check_out_of_bounds() -> bool:
	if(position.x > 0 and position.x < 800 and position.y > 0 and position.y < 800):
		return false
	print(player_name , " out of bounds")
	return true

func add_trail() -> void:
	start_gate_open_timer()
	trail = trailScene.instantiate()
	trail.default_color = color
	head.add_child(trail)
	trail.add_to_group("Trails")
	trail_count += 1
	
func stop_trail() -> void:
	if(trail):
		trail.set_process(false)
	gate_open_timer.stop()
	gate_close_timer.stop()

func clean_trails() -> void :
	for trailNode in get_tree().get_nodes_in_group("Trails"):
		trailNode.queue_free()
	gate_open_timer.stop()
	gate_close_timer.stop()
	
func open_gate() -> void:
	stop_trail()
	playercoll.disabled = true
	gate_close_timer.wait_time = gate_open_time
	gate_close_timer.start()

func close_gate() -> void:
	add_trail()
	playercoll.disabled = false

func start_gate_open_timer():
	# Random delay between 3 and 10s (value to change)
	var random_delay = randf_range(1.0, 4.0)
	gate_open_timer.wait_time = random_delay
	gate_open_timer.start()

func _on_gate_open_timer_timeout():
	open_gate()
	
func _on_gate_close_timer_timeout() -> void:
	close_gate()
	
func death() -> void:
	# Stop process when player dies
	set_process(false)
	player_died.emit(self)
	
func reset() -> void:
	set_process(true)
	score = 0
