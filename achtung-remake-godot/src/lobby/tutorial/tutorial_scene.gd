class_name TutorialScene
extends Node2D

signal back_to_lobby

const POWERUP_ICON_SIZE := Vector2(60, 60)
const POWERUP_ICON_SEPARATION := 8

@onready var self_powerup_row: HBoxContainer = %SelfPowerUpRow
@onready var others_powerup_row: HBoxContainer = %OthersPowerUpRow
@onready var all_powerup_row: HBoxContainer = %AllPowerUpRow
@onready var self_powerup_label: Label = %SelfPowerUpLabel
@onready var others_powerup_label: Label = %OthersPowerUpLabel
@onready var all_powerup_label: Label = %AllPowerUpLabel


func _ready() -> void:
	_align_powerup_labels()
	_populate_powerup_icons()


func _align_powerup_labels() -> void:
	var labels: Array[Label] = [
		self_powerup_label,
		others_powerup_label,
		all_powerup_label,
	]
	var label_width := 0.0
	for label in labels:
		label_width = maxf(label_width, label.get_combined_minimum_size().x)

	for label in labels:
		label.custom_minimum_size = Vector2(label_width, label.custom_minimum_size.y)


func _populate_powerup_icons() -> void:
	for row in [self_powerup_row, others_powerup_row, all_powerup_row]:
		row.add_theme_constant_override("separation", POWERUP_ICON_SEPARATION)

	for powerup_type in PowerUpRegistry.PowerUpType.size():
		var definition := (
			PowerUpRegistry.get_definition_by_type(powerup_type) as PowerUpDefinition
		)
		if definition == null:
			continue

		var texture := definition.token_texture
		if texture == null:
			continue

		var enum_key_name: String = PowerUpRegistry.PowerUpType.keys()[powerup_type]
		var row: HBoxContainer
		if enum_key_name.ends_with("_SELF"):
			row = self_powerup_row
		elif enum_key_name.ends_with("_OTHERS"):
			row = others_powerup_row
		else:
			row = all_powerup_row

		var icon := TextureRect.new()
		icon.texture = texture
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = POWERUP_ICON_SIZE
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(icon)


func _on_back_to_menu_button_pressed() -> void:
	back_to_lobby.emit()
	queue_free()
