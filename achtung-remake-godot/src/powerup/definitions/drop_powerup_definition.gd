class_name DropPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")
const SPAWN_INTERVAL_MULTIPLIER := PowerUpsConstants.POWERUP_FACTOR_DROP_BOOST


func _init() -> void:
	powerup_id = &"drop"
	target = Target.NEUTRAL
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = PowerUpsConstants.DROP_DURATION
	token_color = DEFAULT_ACTION_COLOR
	token_texture = preload("res://art/powerups/drop.svg")
	avg_spawn_interval = PowerUpsConstants.DROP_AVG_INTERVAL


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	if context.powerup_runtime_controller != null:
		context.powerup_runtime_controller.set_powerup_spawn_factor_multiplier(
			source_id, SPAWN_INTERVAL_MULTIPLIER
		)
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	return effect


func on_expire(effect) -> void:
	if effect.context.powerup_runtime_controller != null:
		effect.context.powerup_runtime_controller.remove_powerup_spawn_factor_multiplier(
			effect.source_id
		)
