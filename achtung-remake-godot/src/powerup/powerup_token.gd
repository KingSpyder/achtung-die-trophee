## Representation of the power-up token in the game world.
## Responsible for detecting when a player collects the token and emitting a signal.
class_name PowerUpToken
extends Area2D

signal collected(token: PowerUpToken, collector: PlayerScript)

const PowerUpDefinitionScript = preload("res://src/powerup/powerup_definition.gd")
const PlayerScript = preload("res://src/player/player.gd")

@export var definition: PowerUpDefinitionScript:
	set(value):
		definition = value
		_update_visuals()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_layer = 1 << 2  # layer 3: PowerUpTokens
	collision_mask = 1 << 1  # layer 2: PlayersPickup
	_update_visuals()


func _update_visuals() -> void:
	if not is_node_ready():
		return
	if definition == null:
		return
	$TokenPolygon.color = definition.token_color
	if definition.token_texture != null:
		$TokenPolygon.texture = definition.token_texture


func _on_body_entered(body: Node) -> void:
	if definition == null:
		return
	var player := body as PlayerScript
	if player == null:
		return
	collected.emit(self, player)
