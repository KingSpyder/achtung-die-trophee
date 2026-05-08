class_name UntrailSelfDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")

const OSCILLATION_SPEED := 10.0


func _init() -> void:
	powerup_id = &"untrail_self"
	target = Target.SELF
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = 4.0
	token_color = DEFAULT_SELF_COLOR
	token_texture = preload("res://art/powerups/untrail_self.svg")


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	for target_player in targets:
		target_player.open_gate(true)
	return effect


func on_expire(effect) -> void:
	for target_player in effect.targets:
		if not is_instance_valid(target_player):
			continue
		target_player.start_trail()
