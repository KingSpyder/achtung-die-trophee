class_name PauseOverlay
extends Control

const PhysicsLayersScript = preload("res://src/configs/physics_layers.gd")


func _ready() -> void:
	z_index = PhysicsLayersScript.OVERLAY_Z_INDEX
