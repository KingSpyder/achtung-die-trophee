class_name SquareOthersPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")
const AllPresetsScript = preload("res://src/player/presets/all_presets.gd")


func _init() -> void:
	powerup_id = &"square_others"
	target = Target.OTHERS
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = 4.0
	token_color = DEFAULT_OTHERS_COLOR
	token_texture = preload("res://art/powerups/square_others.svg")


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	for target_player in targets:
		target_player.set_quarter_turn_enabled(source_id, true)
		target_player.set_head_preset_override(source_id, AllPresetsScript.SQUARE)
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	return effect


func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.set_quarter_turn_enabled(effect.source_id, false)
		target_player.set_head_preset_override(effect.source_id, null)
