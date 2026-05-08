## Deals with the remaining duration and expiration of an active powerup effect.
class_name ActivePowerUpEffect
extends RefCounted

const PlayerScript = preload("res://src/player/player.gd")

var definition: PowerUpDefinition
var context: PowerUpExecutionContext
var targets: Array[PlayerScript]
var source_id: StringName
var remaining_duration: float
var metadata := {}

var _ended := false


func _init(
	powerup_definition: PowerUpDefinition,
	execution_context: PowerUpExecutionContext,
	effect_targets: Array[PlayerScript],
	effect_source_id: StringName,
	duration_seconds: float,
) -> void:
	definition = powerup_definition
	context = execution_context
	targets = effect_targets
	source_id = effect_source_id
	remaining_duration = duration_seconds


func tick(delta: float) -> bool:
	if _ended:
		return true
	if remaining_duration <= 0.0:
		expire()
		return true
	definition.on_tick(self, delta)
	remaining_duration = maxf(0.0, remaining_duration - delta)
	if remaining_duration == 0.0:
		expire()
		return true
	return false


func expire() -> void:
	if _ended:
		return
	_ended = true
	definition.on_expire(self)


func cancel() -> void:
	if _ended:
		return
	_ended = true
	definition.on_cancel(self)
