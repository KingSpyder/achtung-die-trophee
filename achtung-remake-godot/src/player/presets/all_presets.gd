class_name AllPresets
extends RefCounted

const DEFAULT: PlayerHeadPreset = preload(
	"res://src/player/presets/default_player_head_preset.tres"
)
const ROUND: PlayerHeadPreset = preload("res://src/player/presets/round_player_head_preset.tres")
const SQUARE: PlayerHeadPreset = preload("res://src/player/presets/square_player_head_preset.tres")

const _BY_NAME := {
	"default": DEFAULT,
	"round": ROUND,
	"square": SQUARE,
}


static func names() -> PackedStringArray:
	return PackedStringArray(_BY_NAME.keys())


static func all() -> Dictionary:
	return _BY_NAME.duplicate()


static func get_by_name(preset_name: String) -> PlayerHeadPreset:
	return _BY_NAME.get(preset_name.to_lower())
