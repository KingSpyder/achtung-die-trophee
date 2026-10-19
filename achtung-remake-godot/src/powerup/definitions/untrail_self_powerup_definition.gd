class_name UntrailSelfDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")

const OSCILLATION_SPEED := 10.0


func _init() -> void:
	powerup_id = &"untrail_self"
	target = Target.SELF
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = PowerUpsConstants.UNTRAIL_SELF_DURATION
	token_color = DEFAULT_SELF_COLOR
	token_texture = preload("res://art/powerups/untrail_self.svg")
	avg_spawn_interval = PowerUpsConstants.UNTRAIL_SELF_AVG_INTERVAL


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
	var runtime_controller = effect.context.powerup_runtime_controller
	for target_player in effect.targets:
		if not is_instance_valid(target_player):
			continue
		# On vérifie qu'il n'y a pas d'autres untrail effectifs sur target_player
		var has_other_untrail_active := false
		for active_effect in runtime_controller._active_effects:
			if (active_effect != effect
			and active_effect.definition.powerup_id == powerup_id
			and active_effect.targets.has(target_player)):
				has_other_untrail_active = true
				break
		if not has_other_untrail_active:
			target_player.start_trail()
