class_name InvertControlsActionPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")


func _init() -> void:
	powerup_id = &"invert_controls_others"
	target = Target.OTHERS
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = PowerUpsConstants.INVERTER_OTHER_DURATION
	token_color = DEFAULT_OTHERS_COLOR
	token_texture = preload("res://art/powerups/invert_others.svg")
	spawn_chance = PowerUpsConstants.INVERTER_OTHER_CHANCE


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	for target_player in targets:
		target_player.set_turn_controls_inverted(source_id, true)
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	return effect


func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.set_turn_controls_inverted(effect.source_id, false)
