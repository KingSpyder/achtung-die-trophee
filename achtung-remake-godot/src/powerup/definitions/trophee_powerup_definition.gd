class_name TropheePowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")


func _init() -> void:
	powerup_id = &"trophee"
	target = Target.SELF
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = PowerUpsConstants.TROPHEE_DURATION
	token_color = DEFAULT_SELF_COLOR


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	for target_player in targets:
		target_player.set_score_multiplier(source_id, PowerUpsConstants.TROPHEE_SCORECOEF)
		target_player.set_speed_multiplier(source_id, PowerUpsConstants.TROPHEE_SPEEDCOEF)
		target_player.set_radius_multiplier(source_id, PowerUpsConstants.TROPHEE_RADIUSCOEF)
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	return effect


func on_tick(effect, delta: float) -> void:
	for target_player in effect.targets:
		var random_angle := (
			randf_range(
				-PowerUpsConstants.TROPHEE_MAXTURNSPEED, PowerUpsConstants.TROPHEE_MAXTURNSPEED
			)
			* delta
		)
		target_player.rotate_direction(random_angle)


func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.remove_score_multiplier(effect.source_id)
		target_player.remove_speed_multiplier(effect.source_id)
		target_player.remove_radius_multiplier(effect.source_id)
