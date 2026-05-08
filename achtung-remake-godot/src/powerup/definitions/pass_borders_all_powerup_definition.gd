class_name PassBordersAllPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")

const OSCILLATION_SPEED := 10.0


func _init() -> void:
	powerup_id = &"pass_borders_all"
	target = Target.ALL
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = 4.0
	token_color = PowerUpDefinition.DEFAULT_ALL_COLOR
	token_texture = preload("res://art/powerups/pass_borders_all.svg")


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	for target_player in targets:
		target_player.set_pass_borders_enabled(source_id, true)

	# Store original wall colors
	effect.metadata["phase"] = 0
	effect.metadata["original_colors"] = {}
	var walls = context.game_physic_controller.get_tree().get_nodes_in_group("Walls")
	for wall in walls:
		if is_instance_valid(wall):
			effect.metadata["original_colors"][wall] = wall.modulate

	return effect


func on_tick(effect, delta: float) -> void:
	if not effect.metadata.has("phase"):
		effect.metadata["phase"] = 0.0
	var phase := float(effect.metadata.get("phase", 0.0)) + (delta * OSCILLATION_SPEED)
	effect.metadata["phase"] = phase

	var t := (sin(phase) + 1.0) * 0.5  # 0 to 1

	# Oscillate all walls between their original color and black
	var walls = effect.context.game_physic_controller.get_tree().get_nodes_in_group("Walls")
	var original_colors = effect.metadata.get("original_colors", {})

	for wall in walls:
		if is_instance_valid(wall):
			var original_color = original_colors.get(wall, Color.WHITE)
			var new_color = original_color.lerp(Color.BLACK, t)
			wall.modulate = new_color


func on_expire(effect) -> void:
	# Reset all walls to their original colors
	var original_colors = effect.metadata.get("original_colors", {})
	for wall in original_colors.keys():
		if is_instance_valid(wall):
			wall.modulate = original_colors[wall]

	# Disable pass borders for all targets
	for target_player in effect.targets:
		if not is_instance_valid(target_player):
			continue
		target_player.set_pass_borders_enabled(effect.source_id, false)
