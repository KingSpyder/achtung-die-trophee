class_name TropheePowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")

@export var max_random_turn_speed := 8.0
@export var score_multiplier := 2.0
@export var speed_multiplier := 1.25


func _init() -> void:
	powerup_id = &"trophee"
	target = Target.SELF
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = 45.0
	token_color = DEFAULT_SELF_COLOR


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	for target_player in targets:
		target_player.set_score_multiplier(source_id, score_multiplier)
		target_player.set_speed_multiplier(source_id, speed_multiplier)
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	return effect


func on_tick(effect, delta: float) -> void:
	for target_player in effect.targets:
		var random_angle := randf_range(-max_random_turn_speed, max_random_turn_speed) * delta
		target_player.rotate_direction(random_angle)


func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.remove_score_multiplier(effect.source_id)
