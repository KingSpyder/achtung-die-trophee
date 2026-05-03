## Central registry for all powerup definitions in the game.
##
## This file serves as a single source of truth for which powerups are available,
## making it easy to add new powerups without modifying the runtime controller.
class_name PowerUpRegistry
extends Resource

const SpeedBoostDefinitionScript = preload(
	"res://src/powerup/definitions/speed_boost_self_powerup_definition.gd"
)
const SpeedReduceSelfDefinitionScript = preload(
	"res://src/powerup/definitions/speed_reduce_self_powerup_definition.gd"
)
const SpeedBoostOthersDefinitionScript = preload(
	"res://src/powerup/definitions/speed_boost_others_powerup_definition.gd"
)
const SpeedReduceOthersDefinitionScript = preload(
	"res://src/powerup/definitions/speed_reduce_others_powerup_definition.gd"
)
const InvertControlsOthersDefinitionScript = preload(
	"res://src/powerup/definitions/invert_controls_others_powerup_definition.gd"
)
const InvertControlsSelfDefinitionScript = preload(
	"res://src/powerup/definitions/invert_controls_self_powerup_definition.gd"
)


## Returns an array of all available powerup definitions as new instances.
static func get_all_definitions() -> Array[Resource]:
	var definitions: Array[Resource] = []

	# Speed Boost
	if SpeedBoostDefinitionScript != null:
		definitions.append(SpeedBoostDefinitionScript.new())
	if SpeedReduceSelfDefinitionScript != null:
		definitions.append(SpeedReduceSelfDefinitionScript.new())
	if SpeedBoostOthersDefinitionScript != null:
		definitions.append(SpeedBoostOthersDefinitionScript.new())
	if SpeedReduceOthersDefinitionScript != null:
		definitions.append(SpeedReduceOthersDefinitionScript.new())

	# Invert Controls
	if InvertControlsOthersDefinitionScript != null:
		definitions.append(InvertControlsOthersDefinitionScript.new())
	if InvertControlsSelfDefinitionScript != null:
		definitions.append(InvertControlsSelfDefinitionScript.new())

	return definitions
