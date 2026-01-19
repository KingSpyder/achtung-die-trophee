class_name PlayerSelection
extends Control

enum MAP_STATE {WAITING_LEFT, WAITING_RIGHT, DONE}

signal check_duplicates_keys()

@export var order: String;
@export var player_name: String;
@export var color: Color;

var player_scene: PackedScene = preload("res://src/player/playerScene.tscn")
@export var player: Player = null

var order_label: Label
var name_button: Button

@onready var left_input: Label= %LeftInput
@onready var left_wait_input_label: Label = %LeftWaitInputLabel
@onready var right_input: Label = %RightInput
@onready var right_wait_input_label: Label = %RightWaitInputLabel

var map_state := MAP_STATE.DONE

func _ready() -> void:
	#process_mode = Node.PROCESS_MODE_ALWAYS
	$InputCatcher.key_captured.connect(_on_key_captured)
	
# We need to init data when instantiating, so the node may not be "onready" yet
# So we assign the node value here and not with the @onready decorator
func init_data(_order: String, _player_name: String, _color: Color) -> Node:
	order_label = %OrderLabel
	name_button = %NameButton
	
	order = _order
	player_name = _player_name
	color = _color

	order_label.text = order
	order_label.add_theme_color_override("font_color", color)
	
	name_button.text = player_name
	name_button.add_theme_color_override("font_color", Color.from_hsv(color.h, color.s, 0.5))
	name_button.add_theme_color_override("font_pressed_color", color)
	name_button.add_theme_color_override("font_hover_color", Color.from_hsv(color.h, color.s, 0.7))
	name_button.add_theme_color_override("font_hover_pressed_color", color)
	
	return self

func assign_to_remote_player():
	pass

func _on_name_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		_add_player()
	else:
		_remove_player()

func _add_player() -> void:
	if(map_state == MAP_STATE.DONE):
		_unset_inputs()
		player = player_scene.instantiate()
		GameManager.players.push_back(player)
		player.player_name = player_name
		player.color = color
		#player.update_shader()
		map_state = MAP_STATE.WAITING_LEFT
		left_wait_input_label.visible = true
		get_tree().paused = true

func _remove_player() -> void:
	if player != null:
		GameManager.players.erase(player)
		player.free()
		player = null
	_unset_inputs()
	left_input.add_theme_color_override("font_color", Color.WHITE)
	right_input.add_theme_color_override("font_color", Color.WHITE)
	emit_signal("check_duplicates_keys")

func _unset_inputs() -> void:
	left_input.text = ""
	InputMap.action_erase_events(player_name + "_left")
	InputMap.erase_action(player_name + "_left")
	left_wait_input_label.visible = false
	right_input.text = ""
	InputMap.action_erase_events(player_name + "_right")
	InputMap.erase_action(player_name + "_right")
	right_wait_input_label.visible = false

func _on_key_captured(event) -> void:
	match map_state:
		MAP_STATE.WAITING_LEFT:
			var action_name := player_name + "_left"
			if not InputMap.has_action(action_name):
				InputMap.add_action(action_name)
			InputMap.action_add_event(action_name, event)
			left_wait_input_label.visible = false
			right_wait_input_label.visible = true
			left_input.text = event.as_text()
			player.left_control = event.as_text()
			map_state = MAP_STATE.WAITING_RIGHT
		MAP_STATE.WAITING_RIGHT:
			var action_name := player_name + "_right"
			if not InputMap.has_action(action_name):
				InputMap.add_action(action_name)
			InputMap.action_add_event(action_name, event)
			right_wait_input_label.visible = false
			right_input.text = event.as_text()
			player.right_control = event.as_text()
			get_tree().paused = false
			map_state = MAP_STATE.DONE
			emit_signal("check_duplicates_keys")
