## Abstract base class for power-up definitions.
## Each power-up type should have a corresponding PowerUpDefinition resource that defines
## its behavior and properties.
# TODO: use the abstract decorator?
class_name PowerUpDefinition
extends Resource

enum Target { SELF, OTHERS, NEUTRAL, ALL }
enum ActivationMode { IMMEDIATE, ACTION }

const PlayerScript = preload("res://src/player/player.gd")
const DEFAULT_SELF_COLOR: Color = Color(0.0, 1.0, 0.0, 1.0)
const DEFAULT_OTHERS_COLOR: Color = Color(1.0, 0.0, 0.0, 1.0)
const DEFAULT_ACTION_COLOR: Color = Color("#00e1ff")  # Blue color for action-based power-ups
const DEFAULT_ALL_COLOR: Color = Color(1.0, 1.0, 0.0, 1.0)  # Yellow for ALL powerups

@export var powerup_id: StringName = &"powerup"
@export var target: Target = Target.SELF
@export var activation_mode: ActivationMode = ActivationMode.IMMEDIATE
@export var action_uses := 1
@export var duration_seconds := 0.0
@export var token_color: Color = DEFAULT_SELF_COLOR
@export var token_texture: Texture2D = null
@export var pickup_sprite_folder: String = ""
@export var pickup_sprite_frames: Array[Texture2D] = []
@export var pickup_sprite_fps: float = 24.0
@export var avg_spawn_interval := 70.0
@export var powerup_radius := 20.0
@export var pickup_sound: AudioStream = preload("res://assets/sounds/10_bleep_snd.mp3")


func on_apply(
	_context: PowerUpExecutionContext,
	_targets: Array[PlayerScript],
	_source_id: StringName,
) -> ActivePowerUpEffect:
	push_error("PowerUpDefinition.on_apply must be overridden")
	return null


func on_expire(_effect: ActivePowerUpEffect) -> void:
	pass


func on_tick(_effect: ActivePowerUpEffect, _delta: float) -> void:
	pass


func on_cancel(effect: ActivePowerUpEffect) -> void:
	on_expire(effect)

func _load_frames_from_folder(folder_path: String) -> void:
	if folder_path.is_empty():
		return

	pickup_sprite_frames.clear() # Réinitialise le tableau

	var dir := DirAccess.open(folder_path)
	if dir:
		var file_names: Array[String] = []
		dir.list_dir_begin()
		var file_name := dir.get_next()

		while file_name != "":
			if not dir.current_is_dir():
				# Nettoie l'extension .import pour ne garder qu'une référence unique par PNG
				var clean_name := file_name.replace(".import", "")
				if clean_name.ends_with(".png") and not file_names.has(clean_name):
					file_names.append(clean_name)
			file_name = dir.get_next()

		file_names.sort()

		for file in file_names:
			var full_path := folder_path.path_join(file)
			var texture := load(full_path) as Texture2D
			if texture:
				pickup_sprite_frames.append(texture)
