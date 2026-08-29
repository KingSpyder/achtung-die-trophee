class_name FreezeOthersActionPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")
#const FreezeTokenTexture: Texture2D = preload("res://art/bleu.png")


func _init() -> void:
	powerup_id = &"freeze_others_action"
	target = Target.OTHERS
	activation_mode = ActivationMode.ACTION
	action_uses = 1
	duration_seconds = PowerUpsConstants.FREEZE_OTHER_DURATION
	token_color = DEFAULT_ACTION_COLOR
	token_texture = preload("res://art/powerups/freeze.svg")
	avg_spawn_interval = PowerUpsConstants.FREEZE_OTHER_AVG_INTERVAL


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	for target_player in targets:
		target_player.set_speed_multiplier(source_id, 0.0)
	return effect


func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.remove_speed_multiplier(effect.source_id)
