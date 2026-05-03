## Abstract base class for power-up definitions.
## Each power-up type should have a corresponding PowerUpDefinition resource that defines
## its behavior and properties.
# TODO: use the abstract decorator?
class_name PowerUpDefinition
extends Resource

enum Target { SELF, OTHERS, NEUTRAL }
enum ActivationMode { IMMEDIATE, ACTION }

const PlayerScript = preload("res://src/player/player.gd")

@export var powerup_id: StringName = &"powerup"
@export var target: Target = Target.SELF
@export var activation_mode: ActivationMode = ActivationMode.IMMEDIATE
@export var action_uses := 1
@export var duration_seconds := 0.0
@export var token_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var token_texture: Texture2D = null


func on_apply(
	_context: PowerUpExecutionContext,
	_targets: Array[PlayerScript],
	_source_id: StringName,
) -> ActivePowerUpEffect:
	push_error("PowerUpDefinition.on_apply must be overridden")
	return null


func on_expire(_effect: ActivePowerUpEffect) -> void:
	pass


func on_cancel(effect: ActivePowerUpEffect) -> void:
	on_expire(effect)
