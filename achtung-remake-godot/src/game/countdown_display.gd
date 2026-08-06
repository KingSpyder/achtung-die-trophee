class_name CountdownDisplay
extends Control

const APPEAR_DURATION := 0.15
const HOLD_DURATION := 0.35
const EXIT_DURATION := 0.3

var _running := false

@onready var _label: Label = $CountdownLabel


## Play a "3, 2, 1, GO" countdown: each label pops in, holds, then shrinks and fades out
## as the next one appears. Returns as soon as "GO" is shown, without waiting for it to
## fade out, so callers can resume gameplay right when "GO" appears.
func run_countdown(seconds: int) -> void:
	if _running:
		return
	_running = true
	visible = true
	for i in range(seconds, 0, -1):
		if not await _appear(str(i)):
			_running = false
			return
		await _hold_and_fade()
		if not is_instance_valid(self):
			_running = false
			return
	_appear("GO")
	_finish_go_and_hide()
	_running = false


## Lets GO's hold and fade-out finish in the background, then hides the overlay.
func _finish_go_and_hide() -> void:
	await _hold_and_fade()
	if is_instance_valid(self):
		visible = false


## Pops the label in at the given text. Returns false if the node was freed mid-animation.
func _appear(text: String) -> bool:
	if not is_instance_valid(self):
		return false
	_label.text = text
	_label.scale = Vector2(0.4, 0.4)
	_label.modulate.a = 0.0

	var appear_tween := create_tween()
	appear_tween.set_parallel(true)
	(
		appear_tween
		. tween_property(_label, "scale", Vector2.ONE, APPEAR_DURATION)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)
	appear_tween.tween_property(_label, "modulate:a", 1.0, APPEAR_DURATION)
	await appear_tween.finished
	return is_instance_valid(self)


## Holds the label at full size, then shrinks and fades it out.
func _hold_and_fade() -> void:
	await get_tree().create_timer(HOLD_DURATION).timeout
	if not is_instance_valid(self):
		return

	var exit_tween := create_tween()
	exit_tween.set_parallel(true)
	(
		exit_tween
		. tween_property(_label, "scale", Vector2(0.6, 0.6), EXIT_DURATION)
		. set_trans(Tween.TRANS_QUAD)
		. set_ease(Tween.EASE_IN)
	)
	exit_tween.tween_property(_label, "modulate:a", 0.0, EXIT_DURATION)
	await exit_tween.finished
