class_name SpeedBoostOthersPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")


func _init() -> void:
	powerup_id = &"speed_boost_others"
	target = Target.OTHERS
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = PowerUpsConstants.SPEED_BOOST_OTHER_DURATION
	token_color = DEFAULT_OTHERS_COLOR
	token_texture = preload("res://art/powerups/boost_others.svg")
	spawn_chance = PowerUpsConstants.SPEED_BOOST_OTHER_CHANCE


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	for target_player in targets:
		target_player.set_speed_multiplier(source_id, PowerUpsConstants.SPEED_BOOST_OTHER_SPEEDCOEF)
		target_player.set_angular_speed_multiplier(source_id, PowerUpsConstants.SPEED_BOOST_OTHER_ROTSPEEDCOEF)
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	return effect


func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.remove_speed_multiplier(effect.source_id)
		target_player.remove_angular_speed_multiplier(effect.source_id)
