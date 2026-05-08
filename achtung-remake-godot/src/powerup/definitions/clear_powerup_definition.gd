class_name ClearPowerUpDefinition
extends PowerUpDefinition


func _init() -> void:
	powerup_id = &"clear"
	target = Target.ALL
	activation_mode = ActivationMode.IMMEDIATE
	token_color = DEFAULT_ALL_COLOR
	token_texture = preload("res://art/powerups/clear.svg")


func on_apply(
	_context,
	targets,
	_source_id: StringName,
):
	for target_player in targets:
		if not is_instance_valid(target_player):
			continue
		target_player.clean(false)
	return null
