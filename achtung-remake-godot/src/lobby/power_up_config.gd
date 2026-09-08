class_name PowerUpConfig
extends ConfirmationDialog

@onready var self_pu: VBoxContainer = %SelfPowerUps
@onready var others_pu: VBoxContainer = %OthersPowerUps
@onready var all_pu: VBoxContainer = %AllPowerUps

# Mémoire tampon : on ne modifie le vrai registre que si on valide
var temp_active_powerups: Array[PowerUpRegistry.PowerUpType] = []

const POWERUP_MAPPING = {
	"SPEED_BOOST_SELF": { 
		"name": "Speed boost self", 
		"desc": "Increase player's speed." 
	},
	"SPEED_REDUCE_SELF": { 
		"name": "Speed reduction self", 
		"desc": "Decrease player's speed." 
	},
	"SPEED_BOOST_OTHERS": { 
		"name": "Speed boost others", 
		"desc": "Increase all other player's speed." 
	},
	"SPEED_REDUCE_OTHERS": { 
		"name": "Speed reduction others", 
		"desc": "Decrease all other player's speed." 
	},
	"FREEZE_OTHERS_ACTION": { 
		"name": "Freeze", 
		"desc": "Freeze all other players when activating. Press both keys to activate." 
	},
	"INVERT_CONTROLS_OTHERS": { 
		"name": "Invert controls", 
		"desc": "Inversion of right and left for all other players." 
	},
	"INVERT_CONTROLS_SELF": { 
		"name": "invert controls self", 
		"desc": "Inversion of right and left for player." 
	},
	"UNTRAIL_SELF": { 
		"name": "Invincibility", 
		"desc": "Player has no trail and is invincible." 
	},
	"PASS_BORDERS_SELF": { 
		"name": "Free borders self", 
		"desc": "Player can go through the borders to appear on the other side." 
	},
	"PASS_BORDERS_ALL": { 
		"name": "Free borders", 
		"desc": "Borders are crossable for every player." 
	},
	"SQUARE_SELF": { 
		"name": "90° turn self", 
		"desc": "Player turns by 90°." 
	},
	"SQUARE_OTHERS": { 
		"name": "90° turn others", 
		"desc": "All other players turn by 90°." 
	},
	"DROP": { 
		"name": "Spawn boost", 
		"desc": "Increase greately power-ups spawn." 
	},
	"CLEAR": { 
		"name": "Clear", 
		"desc": "Clear the map of all trails." 
	},
	"SURPRISE": { 
		"name": "Suprise!", 
		"desc": "Get a random power-up." 
	},
	"THIN_SELF": { 
		"name": "Thinness self", 
		"desc": "Player's trail is thinner." 
	},
	"FAT_OTHERS": { 
		"name": "Largeness others", 
		"desc": "All other players' trail are larger." 
	},
	"TROPHEE": { 
		"name": "Trophée", 
		"desc": "During the effect you get double points, but you have trouble to get straight." 
	}
}

func _ready() -> void:
	title = ""
	_popup_customization()
	
	if PowerUpRuntimeController.active_powerup_types.is_empty():
		PowerUpRuntimeController.reset_default_powerups()
	temp_active_powerups = PowerUpRuntimeController.active_powerup_types.duplicate()
	_populate_powerup_config_menu()
	
	# Close via validation, cancel or close window
	confirmed.connect(_on_validate_pressed)
	canceled.connect(queue_free)
	close_requested.connect(queue_free)


func _populate_powerup_config_menu() -> void:
	for powerup_type in PowerUpRegistry.PowerUpType.size():
		var definition = PowerUpRegistry.get_definition_by_type(powerup_type)
		if definition == null:
			continue
			
		var enum_key_name = PowerUpRegistry.PowerUpType.keys()[powerup_type]
		var display_name = enum_key_name
		var display_desc = "Effet inconnu."
		if POWERUP_MAPPING.has(enum_key_name):
			display_name = POWERUP_MAPPING[enum_key_name].name
			display_desc = POWERUP_MAPPING[enum_key_name].desc
		elif "name" in definition and definition.name != "":
			display_name = definition.name
			
		var item_ui = _create_powerup_ui_item(powerup_type, definition, display_name, display_desc)
		_sort_item(item_ui, enum_key_name)
		
		
func _sort_item(item, key):
	if key.ends_with("_SELF"):
		self_pu.add_child(item)
	elif key.ends_with("_OTHERS"):
		others_pu.add_child(item)
	else:
		all_pu.add_child(item)
		
		
func _create_powerup_ui_item(type: int, definition: Resource, d_name: String, d_desc: String) -> Button:
	var btn := Button.new()
	btn.toggle_mode = true
	btn.button_pressed = type in temp_active_powerups
	btn.flat = false
	btn.custom_minimum_size = Vector2(350, 80)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color(0, 0, 0, 0)
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.content_margin_left = 15
	normal_style.content_margin_right = 15
	normal_style.content_margin_top = 12
	normal_style.content_margin_bottom = 12
	var hover_style = normal_style.duplicate()
	hover_style.bg_color = Color(1.0, 1.0, 1.0, 0.12)
	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = Color(0, 0, 0, 0)
	var hover_pressed_style = normal_style.duplicate()
	hover_pressed_style.bg_color = Color(1.0, 1.0, 1.0, 0.20)
	btn.add_theme_stylebox_override("normal", normal_style)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	btn.add_theme_stylebox_override("hover_pressed", hover_pressed_style)
	
	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_theme_constant_override("separation", 15)
	btn.add_child(hbox)
	
	var icon := TextureRect.new()
	if "token_texture" in definition and definition.token_texture != null:
		icon.texture = definition.token_texture
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(40, 40)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(icon)
	
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(vbox)
	
	var name_lbl := Label.new()
	name_lbl.text = d_name
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	name_lbl.add_theme_font_size_override("font_size", 24)
	vbox.add_child(name_lbl)
	
	var desc_lbl := RichTextLabel.new() # RichText permet d'utiliser le BBCode pour l'italique facilement
	desc_lbl.bbcode_enabled = true
	desc_lbl.text = "[color=#aaaaaa][i]" + d_desc + "[/i][/color]"
	desc_lbl.fit_content = true
	desc_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_lbl.add_theme_font_size_override("italics_font_size", 12)
	vbox.add_child(desc_lbl)
	
	_update_btn_visuals(btn, btn.button_pressed)
	
	btn.toggled.connect(func(pressed: bool): 
		_on_item_toggled(type, pressed, btn)
	)
	
	return btn


func _on_item_toggled(type: int, pressed: bool, btn: Button) -> void:
	if pressed and not type in temp_active_powerups:
		temp_active_powerups.append(type)
	elif not pressed and type in temp_active_powerups:
		temp_active_powerups.erase(type)
		
	_update_btn_visuals(btn, pressed)


func _update_btn_visuals(btn: Button, active: bool) -> void:
	if active:
		btn.modulate = Color(1.0, 1.0, 1.0, 1.0) # Opacité totale
	else:
		btn.modulate = Color(0.4, 0.4, 0.4, 1.0) # Assombri/Grisé


func _on_validate_pressed() -> void:
	PowerUpRuntimeController.active_powerup_types = temp_active_powerups.duplicate()
	queue_free()


func _popup_customization() -> void:
	var custom_theme = Theme.new()
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.15, 0.15, 0.15, 1.0) # Fond gris très foncé
	panel_style.border_width_left = 4
	panel_style.border_width_top = 4
	panel_style.border_width_right = 4
	panel_style.border_width_bottom = 4
	panel_style.border_color = Color(1.0, 1.0, 0.0, 1.0) # Bordure jaune (assortie au sous-titre)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.content_margin_bottom = 25
	custom_theme.set_stylebox("panel", "Window", panel_style)
	self.theme = custom_theme
	
	var ok_btn = get_ok_button()
	ok_btn.custom_minimum_size = Vector2(180, 50)
	ok_btn.add_theme_font_size_override("font_size", 20)
	ok_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	var ok_style = StyleBoxFlat.new()
	ok_style.bg_color = Color(0.2, 0.6, 0.2) # Vert
	ok_style.corner_radius_top_left = 6
	ok_style.corner_radius_top_right = 6
	ok_style.corner_radius_bottom_left = 6
	ok_style.corner_radius_bottom_right = 6
	ok_style.content_margin_left = 40
	ok_style.content_margin_right = 40
	ok_style.content_margin_top = 15
	ok_style.content_margin_bottom = 15
	var ok_hover = ok_style.duplicate()
	ok_hover.bg_color = ok_style.bg_color.lightened(0.2)
	var ok_pressed = ok_style.duplicate()
	ok_pressed.bg_color = ok_style.bg_color.darkened(0.2)
	ok_btn.add_theme_stylebox_override("normal", ok_style)
	ok_btn.add_theme_stylebox_override("hover", ok_hover)
	ok_btn.add_theme_stylebox_override("pressed", ok_pressed)
	
	var cancel_btn = get_cancel_button()
	cancel_btn.custom_minimum_size = Vector2(180, 50)
	cancel_btn.add_theme_font_size_override("font_size", 20)
	cancel_btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	var cancel_style = StyleBoxFlat.new()
	cancel_style.bg_color = Color(0.8, 0.2, 0.2)
	cancel_style.corner_radius_top_left = 6
	cancel_style.corner_radius_top_right = 6
	cancel_style.corner_radius_bottom_left = 6
	cancel_style.corner_radius_bottom_right = 6
	cancel_style.content_margin_left = 40
	cancel_style.content_margin_right = 40
	cancel_style.content_margin_top = 15
	cancel_style.content_margin_bottom = 15
	var cancel_hover = cancel_style.duplicate()
	cancel_hover.bg_color = cancel_style.bg_color.lightened(0.2)
	var cancel_pressed = cancel_style.duplicate()
	cancel_pressed.bg_color = cancel_style.bg_color.darkened(0.2)
	cancel_btn.add_theme_stylebox_override("normal", cancel_style)
	cancel_btn.add_theme_stylebox_override("hover", cancel_hover)
	cancel_btn.add_theme_stylebox_override("pressed", cancel_pressed)
	
