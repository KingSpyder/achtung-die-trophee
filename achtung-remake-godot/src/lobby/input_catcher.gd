extends Control

signal key_captured(event)

const FORBIDDEN_KEYS = ["Escape", "Space"]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event) -> void:
	if not (event is InputEventKey and event.is_pressed()):
		return
	if event.as_text() in FORBIDDEN_KEYS:
		return

	emit_signal("key_captured", event)
