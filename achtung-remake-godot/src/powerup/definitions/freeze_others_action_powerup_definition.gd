class_name FreezeOthersActionPowerUpDefinition
extends PowerUpDefinition

const ActivePowerUpEffectScript = preload("res://src/powerup/active_powerup_effect.gd")
#const FreezeTokenTexture: Texture2D = preload("res://art/bleu.png")


func _init() -> void:
	powerup_id = &"freeze_others_action"
	target = Target.OTHERS
	activation_mode = ActivationMode.ACTION
	action_uses = 1
	duration_seconds = 3.0
	token_color = DEFAULT_ACTION_COLOR


func on_apply(
	context,
	targets,
	source_id: StringName,
) -> ActivePowerUpEffectScript:
	var effect = ActivePowerUpEffectScript.new(self, context, targets, source_id, duration_seconds)
	for target_player in targets:
		var player_key = target_player
		effect.metadata[player_key] = {
			#"is_laying_trail": target_player.is_laying_trail,
			"gate_open_timer_was_running": false,
			"gate_open_timer_paused_time": 0.0,
			"gate_close_timer_was_running": false,
			"gate_close_timer_paused_time": 0.0
		}

		# Pause gate timers and save their state
		var gate_open_timer = target_player.get_node_or_null("%GateOpenTimer")
		var gate_close_timer = target_player.get_node_or_null("%GateCloseTimer")
		if gate_open_timer != null and gate_open_timer.is_stopped() == false:
			effect.metadata[player_key]["gate_open_timer_was_running"] = true
			effect.metadata[player_key]["gate_open_timer_paused_time"] = gate_open_timer.time_left
			gate_open_timer.stop()
		if gate_close_timer != null and gate_close_timer.is_stopped() == false:
			effect.metadata[player_key]["gate_close_timer_was_running"] = true
			effect.metadata[player_key]["gate_close_timer_paused_time"] = gate_close_timer.time_left
			gate_close_timer.stop()

		target_player.set_speed_multiplier(source_id, 0.0)
		#target_player.is_laying_trail = false
	return effect


func on_expire(effect) -> void:
	for target_player in effect.targets:
		target_player.remove_speed_multiplier(effect.source_id)
		if effect.metadata.has(target_player):
			var saved_data = effect.metadata[target_player]
			#target_player.is_laying_trail = saved_data["is_laying_trail"]

			# Resume gate timers only if they were running before
			var gate_open_timer = target_player.get_node_or_null("%GateOpenTimer")
			var gate_close_timer = target_player.get_node_or_null("%GateCloseTimer")

			if gate_open_timer != null and saved_data["gate_open_timer_was_running"]:
				gate_open_timer.wait_time = saved_data["gate_open_timer_paused_time"]
				gate_open_timer.start()
			if gate_close_timer != null and saved_data["gate_close_timer_was_running"]:
				gate_close_timer.wait_time = saved_data["gate_close_timer_paused_time"]
				gate_close_timer.start()
