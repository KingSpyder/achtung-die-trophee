## Representation of the power-up token in the game world.
## Responsible for detecting when a player collects the token and emitting a signal.
class_name PowerUpToken
extends Area2D

signal collected(token: PowerUpToken, collector: PlayerScript)

const PowerUpDefinitionScript = preload("res://src/powerup/powerup_definition.gd")
const PlayerScript = preload("res://src/player/player.gd")
const PhysicsLayersScript = preload("res://src/configs/physics_layers.gd")

@export var definition: PowerUpDefinitionScript:
	set(value):
		definition = value
		_update_visuals()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	collision_layer = 1 << PhysicsLayersScript.POWERUP_TOKEN_BIT
	collision_layer = 0
	collision_mask = 1 << PhysicsLayersScript.POWERUP_TOKEN_BIT
	_update_visuals()


func _update_visuals() -> void:
	if not is_node_ready():
		return
	if definition == null:
		return
	if definition.token_texture != null:
		$TokenSprite.texture = definition.token_texture
		if $CollisionShape2D.shape is CircleShape2D:
			var radius = ($CollisionShape2D.shape as CircleShape2D).radius
			$TokenSprite.scale = Vector2.ONE * (radius * 2) / definition.token_texture.get_size().x
	else:
		$TokenSprite.self_modulate = definition.token_color


func _on_body_entered(body: Node) -> void:
	if definition == null:
		return
	var player := body as PlayerScript
	if player == null:
		return
	collected.emit(self, player)
