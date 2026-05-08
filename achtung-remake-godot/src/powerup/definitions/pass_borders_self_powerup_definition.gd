class_name PassBordersSelfPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")

const OSCILLATION_SPEED := 10.0


func _init() -> void:
	powerup_id = &"pass_borders_self"
	target = Target.SELF
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = 4.0
	token_color = DEFAULT_SELF_COLOR
	token_texture = preload("res://art/powerups/pass_borders_self.svg")


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	for target_player in targets:
		target_player.set_pass_borders_enabled(source_id, true)
		effect.metadata[target_player] = {"phase": randf() * TAU}
	return effect


func on_tick(effect, delta: float) -> void:
	for target_player in effect.targets:
		if not is_instance_valid(target_player):
			continue
		if target_player.head == null:
			continue
		if not effect.metadata.has(target_player):
			effect.metadata[target_player] = {"phase": 0.0}
		var state: Dictionary = effect.metadata[target_player]
		var phase := float(state.get("phase", 0.0)) + (delta * OSCILLATION_SPEED)
		state["phase"] = phase
		effect.metadata[target_player] = state

		var alpha := (sin(phase) + 1.0) * 0.5
		var current_color: Color = target_player.head.self_modulate
		current_color.a = alpha
		target_player.head.self_modulate = current_color


func on_expire(effect) -> void:
	for target_player in effect.targets:
		if not is_instance_valid(target_player):
			continue
		if target_player.head != null:
			var reset_color: Color = target_player.head.self_modulate
			reset_color.a = 1.0
			target_player.head.self_modulate = reset_color
		target_player.set_pass_borders_enabled(effect.source_id, false)
