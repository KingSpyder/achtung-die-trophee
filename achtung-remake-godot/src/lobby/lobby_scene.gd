extends Node

var game_mode_button_group = ButtonGroup.new()
var arcade_button: Button
var classic_button: Button


func _ready():
	arcade_button = %ArcadeButton
	arcade_button.button_group = game_mode_button_group
	classic_button = %ClassicButton
	classic_button.button_group = game_mode_button_group
	pass


func _on_arcade_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		GameManager.game_mode =  GameManager.GAME_MODE_ENUM.ARCADE_MODE


func _on_classic_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		GameManager.game_mode =  GameManager.GAME_MODE_ENUM.CLASSIC_MODE
