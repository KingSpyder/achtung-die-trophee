class_name TropheePowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")
@export var is_present_music: AudioStream = preload("res://assets/music/kraddy part 1.mp3")
@export var is_active_music: AudioStream = preload("res://assets/music/kraddy part 2.mp3")
@export var presence_min_distance: float = 40.0
@export var presence_max_distance: float = 400.0


func _init() -> void:
	powerup_id = &"trophee"
	target = Target.SELF
	activation_mode = ActivationMode.IMMEDIATE
	duration_seconds = PowerUpsConstants.TROPHEE_DURATION
	token_color = DEFAULT_SELF_COLOR
	token_texture = preload("res://art/powerups/trophee_text.svg")
	avg_spawn_interval = PowerUpsConstants.TROPHEE_AVG_INTERVAL
	pickup_sound = null
	

func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	for target_player in targets:
		target_player.set_score_multiplier(source_id, PowerUpsConstants.TROPHEE_SCORECOEF)
		target_player.set_speed_multiplier(source_id, PowerUpsConstants.TROPHEE_SPEEDCOEF)
		target_player.set_radius_multiplier(source_id, PowerUpsConstants.TROPHEE_RADIUSCOEF)
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	
	AudioManager.pause_music()
	var trophee_player = AudioManager.play_trophee(is_active_music, 0.9)
	if trophee_player != null:
		effect.metadata["trophee_player"] = trophee_player
	return effect


func on_tick(effect, delta: float) -> void:
	for target_player in effect.targets:
		if not is_instance_valid(target_player) or (target_player.has_method("is_alive") and not target_player.is_alive()):
			effect.cancel()
			return
		var random_angle := (
			randf_range(
				-PowerUpsConstants.TROPHEE_MAXTURNSPEED, PowerUpsConstants.TROPHEE_MAXTURNSPEED
			)
			* delta
		)
		target_player.rotate_direction(random_angle)
		

func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.remove_score_multiplier(effect.source_id)
		target_player.remove_speed_multiplier(effect.source_id)
		target_player.remove_radius_multiplier(effect.source_id)
		
	if effect.metadata.has("trophee_player"):
		var trophee_player = effect.metadata["trophee_player"]
		if is_instance_valid(trophee_player):
			trophee_player.stop()
			trophee_player.queue_free()
	AudioManager.resume_music()
	
func on_cancel(effect: ActivePowerUpEffect) -> void:
	on_expire(effect)
