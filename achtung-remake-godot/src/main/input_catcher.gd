extends Control

signal key_captured(event)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event) -> void:	
	emit_signal("key_captured", event)
