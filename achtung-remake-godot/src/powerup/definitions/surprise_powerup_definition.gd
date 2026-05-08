class_name SurprisePowerUpDefinition
extends PowerUpDefinition


func _init() -> void:
	powerup_id = &"surprise"
	target = Target.SELF
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = 0.0
	token_color = DEFAULT_ACTION_COLOR
	token_texture = preload("res://art/powerups/surprise.svg")


func on_apply(context, _targets, _source_id: StringName) -> ActivePowerUpEffect:
	# Hijack: pick a random other powerup, duplicate it, and swap texture
	if context == null or context.powerup_runtime_controller == null:
		return null

	var all_definitions = context.powerup_runtime_controller.powerup_definitions
	var available: Array[Resource] = []

	# Filter out Surprise itself
	for def in all_definitions:
		if def.powerup_id != &"surprise":
			available.append(def)

	if available.is_empty():
		return null

	# Pick random and duplicate
	var selected = available[randi() % available.size()]
	var copy = selected.duplicate()

	# Delegate to runtime so ACTION hijacks are granted to inventory instead of instant activation.
	context.powerup_runtime_controller.grant_or_activate(copy, context.collector)
	return null
