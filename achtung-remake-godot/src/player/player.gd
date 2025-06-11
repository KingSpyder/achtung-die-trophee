extends Node2D


@export var speed : float = 40.0
@export var rotate_speed : float = 2.5

var direction : Vector2 = Vector2.UP

var screen_size

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	pass

func _process(delta):
	if(_is_player_authority()):
		move(delta)

# Check whether this playerScene belongs to the client
func _is_player_authority():
	return true
	# return $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id()

func move(delta):
	#Rotation & Movement
	if Input.is_action_pressed("move_left"):
		direction = direction.rotated(-rotate_speed * delta)
	if Input.is_action_pressed("move_right"):
		direction = direction.rotated(rotate_speed * delta)
	position += direction * speed * delta
	
