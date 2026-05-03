## Central registry for all powerup definitions in the game.
##
## This file serves as a single source of truth for which powerups are available,
## making it easy to add new powerups without modifying the runtime controller.
class_name PowerUpRegistry
extends Resource

const SpeedBoostDefinitionScript = preload(
	"res://src/powerup/definitions/speed_boost_self_powerup_definition.gd"
)
const InvertControlsDefinitionScript = preload(
	"res://src/powerup/definitions/invert_controls_action_powerup_definition.gd"
)


## Returns an array of all available powerup definitions as new instances.
static func get_all_definitions() -> Array[Resource]:
	var definitions: Array[Resource] = []

	# Speed Boost (self target, immediate activation)
	if SpeedBoostDefinitionScript != null:
		definitions.append(SpeedBoostDefinitionScript.new())

	# Invert Controls (others target, action activation)
	if InvertControlsDefinitionScript != null:
		definitions.append(InvertControlsDefinitionScript.new())

	return definitions
