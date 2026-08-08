class_name ThinSelfPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")


func _init() -> void:
	powerup_id = &"thin_self"
	target = Target.SELF
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = PowerUpsConstants.THIN_SELF_DURATION
	token_color = DEFAULT_SELF_COLOR
	token_texture = preload("res://art/powerups/thin_self.svg")
	avg_spawn_interval = PowerUpsConstants.THIN_SELF_AVG_INTERVAL


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	for target_player in targets:
		target_player.set_size_multiplier(source_id, PowerUpsConstants.THIN_SELF_SIZECOEF)
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	return effect


func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.remove_size_multiplier(effect.source_id)
