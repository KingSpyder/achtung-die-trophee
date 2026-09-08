class_name PowerUpConfig
extends AcceptDialog

@onready var v_box_container: VBoxContainer = %VBoxContainer

func _ready() -> void:
	title = "Configure Power-ups"
	exclusive = true
	ok_button_text = "Close"
	
	_populate_powerup_config_menu()
	
	confirmed.connect(queue_free)
	canceled.connect(queue_free)
	close_requested.connect(queue_free)


func _populate_powerup_config_menu() -> void:
	# Nettoyage de sécurité
	for child in v_box_container.get_children():
		child.queue_free()
	if PowerUpRuntimeController.active_powerup_types.is_empty():
		PowerUpRuntimeController.reset_default_powerups()

	for powerup_type in PowerUpRegistry.PowerUpType.size():
		var definition = PowerUpRegistry.get_definition_by_type(powerup_type)
		if definition == null:
			continue
		var checkbox := CheckBox.new()
		
		var powerup_name = PowerUpRegistry.PowerUpType.keys()[powerup_type].replace("_", " ").capitalize()
		if "name" in definition:
			powerup_name = definition.name	
		checkbox.text = powerup_name
		checkbox.button_pressed = powerup_type in PowerUpRuntimeController.active_powerup_types
		checkbox.toggled.connect(
			func(toggled_on: bool): _on_powerup_toggled(powerup_type, toggled_on)
		)
		
		v_box_container.add_child(checkbox)


func _on_powerup_toggled(powerup_type: PowerUpRegistry.PowerUpType, toggled_on: bool) -> void:
	if toggled_on:
		if powerup_type not in PowerUpRuntimeController.active_powerup_types:
			PowerUpRuntimeController.active_powerup_types.append(powerup_type)
	else:
		PowerUpRuntimeController.active_powerup_types.erase(powerup_type)
