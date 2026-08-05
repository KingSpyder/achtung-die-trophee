class_name SpeedBoostSelfPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")


func _init() -> void:
	powerup_id = &"speed_boost_self"
	target = Target.SELF
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = PowerUpsConstants.SPEED_BOOST_SELF_DURATION
	token_color = DEFAULT_SELF_COLOR
	token_texture = preload("res://art/powerups/boost_self.svg")


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	for target_player in targets:
		target_player.set_speed_multiplier(source_id, PowerUpsConstants.SPEED_BOOST_SELF_SPEEDCOEF)
		target_player.set_angular_speed_multiplier(source_id, PowerUpsConstants.SPEED_BOOST_SELF_ROTSPEEDCOEF)
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	return effect


func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.remove_speed_multiplier(effect.source_id)
		target_player.remove_angular_speed_multiplier(effect.source_id)
