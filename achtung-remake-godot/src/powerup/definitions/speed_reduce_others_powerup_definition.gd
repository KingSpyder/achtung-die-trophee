class_name SpeedReduceOthersPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")


func _init() -> void:
	powerup_id = &"speed_reduce_others"
	target = Target.OTHERS
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = 3.0
	token_color = DEFAULT_OTHERS_COLOR


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	for target_player in targets:
		target_player.set_speed_multiplier(source_id, 0.5)
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	return effect


func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.remove_speed_multiplier(effect.source_id)
