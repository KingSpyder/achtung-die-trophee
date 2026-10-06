extends ConfirmationDialog

signal max_score_coef_selected(value: int)

const SCORE_COEFFICIENTS := {
	"Short": 5,
	"Normal": 10,
	"Long": 20,
}

@onready var short_button: Button = %ShortButton
@onready var normal_button: Button = %NormalButton
@onready var long_button: Button = %LongButton

var selected_max_score_coef := SCORE_COEFFICIENTS["Normal"]


func _ready() -> void:
	title = ""
	_popup_customization()

	var score_button_group := ButtonGroup.new()
	score_button_group.allow_unpress = false
	for option_button in [short_button, normal_button, long_button]:
		option_button.button_group = score_button_group
		_style_option_button(option_button)
		option_button.toggled.connect(_on_option_toggled.bind(option_button))

	short_button.button_pressed = selected_max_score_coef == SCORE_COEFFICIENTS["Short"]
	normal_button.button_pressed = selected_max_score_coef == SCORE_COEFFICIENTS["Normal"]
	long_button.button_pressed = selected_max_score_coef == SCORE_COEFFICIENTS["Long"]

	confirmed.connect(_on_validate_pressed)
	canceled.connect(queue_free)
	close_requested.connect(queue_free)


func _on_option_toggled(toggled_on: bool, option_button: Button) -> void:
	if toggled_on:
		selected_max_score_coef = SCORE_COEFFICIENTS[option_button.text]


func _on_validate_pressed() -> void:
	max_score_coef_selected.emit(selected_max_score_coef)
	queue_free()


func _style_option_button(option_button: Button) -> void:
	option_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.border_color = Color(1.0, 1.0, 0.0, 1.0)
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.content_margin_left = 20
	normal_style.content_margin_right = 20
	normal_style.content_margin_top = 12
	normal_style.content_margin_bottom = 12

	var hover_style: StyleBoxFlat = normal_style.duplicate()
	hover_style.bg_color = Color(0.35, 0.35, 0.15, 1.0)
	var pressed_style: StyleBoxFlat = normal_style.duplicate()
	pressed_style.bg_color = Color(0.55, 0.5, 0.05, 1.0)
	var hover_pressed_style: StyleBoxFlat = normal_style.duplicate()
	hover_pressed_style.bg_color = Color(0.7, 0.65, 0.1, 1.0)

	option_button.add_theme_stylebox_override("normal", normal_style)
	option_button.add_theme_stylebox_override("hover", hover_style)
	option_button.add_theme_stylebox_override("pressed", pressed_style)
	option_button.add_theme_stylebox_override("hover_pressed", hover_pressed_style)
	option_button.add_theme_color_override("font_pressed_color", Color(1.0, 1.0, 0.0))
	option_button.add_theme_color_override("font_hover_pressed_color", Color(1.0, 1.0, 0.0))


func _popup_customization() -> void:
	var custom_theme := Theme.new()
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
	panel_style.border_width_left = 4
	panel_style.border_width_top = 4
	panel_style.border_width_right = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color(1.0, 1.0, 0.0, 1.0)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.content_margin_bottom = 25
	custom_theme.set_stylebox("panel", "Window", panel_style)
	theme = custom_theme

	var ok_button := get_ok_button()
	ok_button.custom_minimum_size = Vector2(180, 50)
	ok_button.add_theme_font_size_override("font_size", 20)
	ok_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_style_dialog_button(ok_button, Color(0.2, 0.6, 0.2))

	var cancel_button := get_cancel_button()
	cancel_button.custom_minimum_size = Vector2(180, 50)
	cancel_button.add_theme_font_size_override("font_size", 20)
	cancel_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	_style_dialog_button(cancel_button, Color(0.8, 0.2, 0.2))


func _style_dialog_button(button: Button, background_color: Color) -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = background_color
	normal_style.corner_radius_top_left = 6
	normal_style.corner_radius_top_right = 6
	normal_style.corner_radius_bottom_left = 6
	normal_style.corner_radius_bottom_right = 6
	normal_style.content_margin_left = 40
	normal_style.content_margin_right = 40
	normal_style.content_margin_top = 15
	normal_style.content_margin_bottom = 15

	var hover_style: StyleBoxFlat = normal_style.duplicate()
	hover_style.bg_color = background_color.lightened(0.2)
	var pressed_style: StyleBoxFlat = normal_style.duplicate()
	pressed_style.bg_color = background_color.darkened(0.2)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
