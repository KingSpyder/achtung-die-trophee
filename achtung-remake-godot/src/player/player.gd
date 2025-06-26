extends CharacterBody2D

@export var speed : float = 500.0
@export var angular_speed : float = 2.05

var direction : Vector2 = Vector2.RIGHT
var last_point := Vector2.ZERO

#var trailScene: PackedScene = preload("res://src/trail/trailScene2.tscn")
#@onready var trail
@onready var head := $Head
@onready var playercoll := $CollisionShape2D

func _ready() -> void:
	var screen_size = get_viewport_rect().size
	global_position = screen_size / 2 # A remplacer par le spawn aléatoire
	
	#$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _process(delta) -> void:
	if(_is_player_authority()):
		move(delta)
		check_collision()

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
		
func check_collision() -> void:
	pass
