class_name Player
extends CharacterBody2D

@export var player_name: String
@export var color: Color
@export var left_control: String
@export var right_control: String

@export var speed : float = 0
@export var angular_speed : float = 2.85
@export var t_gate : float = 60/speed

var direction : Vector2 = Vector2.RIGHT
var last_point := Vector2.ZERO

var trailScene: PackedScene = preload("res://src/trail/trailScene.tscn")
@onready var trail
@onready var head := $Head
@onready var playercoll := $CollisionShape2D
@onready var timer: Timer = $Timer
@onready var gate_timer: Timer = $GateTimer
@onready var shader_material: ShaderMaterial = %Head.material.duplicate()


func _ready() -> void:
	update_shader()
	pass
	
func update_shader() -> void:
	%Head.material = shader_material
	if(color):
		print("update shader", color.r, color.g, color.b)
		shader_material.set_shader_parameter("circle_color", color)

func spawn() -> void:
	var screen_size = get_viewport_rect().size
	global_position = screen_size / 2 # A remplacer par le spawn aléatoire
	
	trail = trailScene.instantiate()
	head.add_child(trail)
	
	# Launch first random timer for gates
	start_timer()
	
	#$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _process(delta) -> void:
	if(_is_player_authority()):
		move(delta)
		if check_collision():
			death()

# Check whether this playerScene belongs to the client
func _is_player_authority() -> bool:
	return true
	# return $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()
		
func move(delta) -> void:
	#Rotation & Movement
	if Input.is_action_pressed("move_left"):
		direction = direction.rotated(-angular_speed * delta)
	if Input.is_action_pressed("move_right"):
		direction = direction.rotated(angular_speed * delta)
	direction = direction.normalized()
	
	velocity = speed * direction
	move_and_slide()
		
func check_collision() -> bool:
	if get_slide_collision_count() > 0:
		#print('Collision')
		#var collision = get_slide_collision(0)
		#print("Collided with: ", collision.get_collider().name)
		return true
	else:
		return false

func death() -> void:
	# Stop process when player dies
	set_process(false)
	
func gate(t: float) -> void:
	# Stop Trail drawing
	if trail:
		#print('Gate')
		trail.set_process(false) 
	# Gate during t seconds
	gate_timer.wait_time = t
	gate_timer.start()

func start_timer():
	# Random delay between 3 and 10s (value to change)
	var random_delay = randf_range(3.0, 10.0)
	#print(random_delay, 's')
	timer.wait_time = random_delay
	timer.start()

func _on_Timer_timeout():
	# Launch gate
	gate(t_gate)
	# Start Timer again with new delay
	start_timer()
	
func _on_GateTimer_timeout():
	# Recommencer un nouveau tracé de la queue
	#print('New trail')
	trail = trailScene.instantiate()
	head.add_child(trail)
