class_name ThinSelfPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")


func _init() -> void:
	powerup_id = &"thin_self"
	target = Target.SELF
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = 3.0
	token_color = DEFAULT_SELF_COLOR
	token_texture = preload("res://art/powerups/thin_self.svg")


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	for target_player in targets:
		target_player.set_size_multiplier(source_id, 0.5)
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	return effect


func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.remove_size_multiplier(effect.source_id)
