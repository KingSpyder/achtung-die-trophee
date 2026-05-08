## Central registry for all powerup definitions in the game.
##
## This file serves as a single source of truth for which powerups are available,
## making it easy to add new powerups without modifying the runtime controller.
class_name PowerUpRegistry
extends Resource

enum PowerUpType {
	SPEED_BOOST_SELF,
	SPEED_REDUCE_SELF,
	SPEED_BOOST_OTHERS,
	SPEED_REDUCE_OTHERS,
	FREEZE_OTHERS_ACTION,
	INVERT_CONTROLS_OTHERS,
	INVERT_CONTROLS_SELF,
	UNTRAIL_SELF,
	PASS_BORDERS_SELF,
	PASS_BORDERS_ALL,
	SQUARE_SELF,
	SQUARE_OTHERS,
	DROP,
	CLEAR,
	SURPRISE,
	THIN_SELF,
	FAT_OTHERS,
}

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
const FreezeOthersActionDefinitionScript = preload(
	"res://src/powerup/definitions/freeze_others_action_powerup_definition.gd"
)
const InvertControlsOthersDefinitionScript = preload(
	"res://src/powerup/definitions/invert_controls_others_powerup_definition.gd"
)
const InvertControlsSelfDefinitionScript = preload(
	"res://src/powerup/definitions/invert_controls_self_powerup_definition.gd"
)
const UntrailSelfDefinitionScript = preload(
	"res://src/powerup/definitions/untrail_self_powerup_definition.gd"
)
const PassBordersSelfDefinitionScript = preload(
	"res://src/powerup/definitions/pass_borders_self_powerup_definition.gd"
)
const PassBordersAllDefinitionScript = preload(
	"res://src/powerup/definitions/pass_borders_all_powerup_definition.gd"
)
const SquareSelfDefinitionScript = preload(
	"res://src/powerup/definitions/square_self_powerup_definition.gd"
)
const SquareOthersDefinitionScript = preload(
	"res://src/powerup/definitions/square_others_powerup_definition.gd"
)
const DropDefinitionScript = preload("res://src/powerup/definitions/drop_powerup_definition.gd")
const ClearDefinitionScript = preload("res://src/powerup/definitions/clear_powerup_definition.gd")
const SurpriseDefinitionScript = preload(
	"res://src/powerup/definitions/surprise_powerup_definition.gd"
)
const ThinSelfDefinitionScript = preload(
	"res://src/powerup/definitions/thin_self_powerup_definition.gd"
)
const FatOthersDefinitionScript = preload(
	"res://src/powerup/definitions/fat_others_powerup_definition.gd"
)


## Returns an array of all available powerup definitions as new instances.
static func get_all_definitions() -> Array[Resource]:
	var definitions: Array[Resource] = []

	# Dynamically generate from enum
	for powerup_type in PowerUpType.size():
		var definition = get_definition_by_type(powerup_type)
		if definition != null:
			definitions.append(definition)

	return definitions


## Converts a PowerUpType enum value to a new instance of the corresponding PowerUpDefinition
## resource. [br]
## Add here new powerups by mapping the enum type to a new instance of the definition.
static func get_definition_by_type(powerup_type: PowerUpType) -> Resource:
	match powerup_type:
		PowerUpType.SPEED_BOOST_SELF:
			return SpeedBoostDefinitionScript.new()
		PowerUpType.SPEED_REDUCE_SELF:
			return SpeedReduceSelfDefinitionScript.new()
		PowerUpType.SPEED_BOOST_OTHERS:
			return SpeedBoostOthersDefinitionScript.new()
		PowerUpType.SPEED_REDUCE_OTHERS:
			return SpeedReduceOthersDefinitionScript.new()
		PowerUpType.FREEZE_OTHERS_ACTION:
			return FreezeOthersActionDefinitionScript.new()
		PowerUpType.INVERT_CONTROLS_OTHERS:
			return InvertControlsOthersDefinitionScript.new()
		PowerUpType.INVERT_CONTROLS_SELF:
			return InvertControlsSelfDefinitionScript.new()
		PowerUpType.UNTRAIL_SELF:
			return UntrailSelfDefinitionScript.new()
		PowerUpType.PASS_BORDERS_SELF:
			return PassBordersSelfDefinitionScript.new()
		PowerUpType.PASS_BORDERS_ALL:
			return PassBordersAllDefinitionScript.new()
		PowerUpType.SQUARE_SELF:
			return SquareSelfDefinitionScript.new()
		PowerUpType.SQUARE_OTHERS:
			return SquareOthersDefinitionScript.new()
		PowerUpType.DROP:
			return DropDefinitionScript.new()
		PowerUpType.CLEAR:
			return ClearDefinitionScript.new()
		PowerUpType.SURPRISE:
			return SurpriseDefinitionScript.new()
		PowerUpType.THIN_SELF:
			return ThinSelfDefinitionScript.new()
		PowerUpType.FAT_OTHERS:
			return FatOthersDefinitionScript.new()
	return null
