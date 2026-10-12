## Read and write LevelData files
class_name LevelManager
extends RefCounted

const BUNDLED_DIR := "res://src/level_editor/levels"
const USER_DIR := "res://src/level_editor/levels"
const EXTENSION := ".tres"

static func get_writable_dir() -> String:
	return BUNDLED_DIR if OS.has_feature("editor") else USER_DIR
	
## Names of every level available
static func list_levels() -> PackedStringArray:
	var unique_name := {}
	for dir_path in [BUNDLED_DIR, USER_DIR]:
		for level_name in _list_dir(dir_path):
			unique_name[level_name] = true
	var names := PackedStringArray(unique_name.keys())
	names.sort()
	return names
	
static func has_level(level_name: String) -> bool:
	return ResourceLoader.exists(get_level_path(level_name))

static func get_level_path(level_name: String) -> String:
	var user_path := USER_DIR.path_join(sanitize_name(level_name) + EXTENSION)
	if ResourceLoader.exists(user_path):
		return user_path
	return BUNDLED_DIR.path_join(sanitize_name(level_name) + EXTENSION)

static func load_level(level_name: String) -> LevelData:
	if level_name.strip_edges().is_empty():
		return null
	var path := get_level_path(level_name)
	if not ResourceLoader.exists(path):
		push_warning("LevelStorage: no level named %s in %s" % [level_name, path])
		return null
	var resource := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
	var level := resource as LevelData
	if level == null:
		push_warning("Level %s is not a LevelDatar resource" % path)
	return level

static func save_level(level: LevelData) -> Error:
	if level == null:
		return ERR_INVALID_PARAMETER
	var file_name := sanitize_name(level.level_name)
	if file_name.is_empty():
		return ERR_INVALID_PARAMETER
	var dir_path := get_writable_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		var make_dir_error := DirAccess.make_dir_recursive_absolute(dir_path)
		if make_dir_error != OK:
			return make_dir_error
	return ResourceSaver.save(level, dir_path.path_join(file_name + EXTENSION))

static func delete_level(level_name: String) -> Error:
	var path := get_writable_dir().path_join(sanitize_name(level_name) + EXTENSION)
	if not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND
	return DirAccess.remove_absolute(path)

## Keep file name simplified: lower case, no space, no path separator
static func sanitize_name(level_name: String) -> String:
	const ALLOWED := "abcdefghijklmnopqrstuvwxyz0123456789_-&é'à"
	var cleaned := level_name.strip_edges().to_lower().replace(" ", "_")
	var result := ""
	for character in cleaned:
		if ALLOWED.contains(character):
			result += character
	return result
	
static func _list_dir(dir_path: String) -> PackedStringArray:
	var names := PackedStringArray()
	if not DirAccess.dir_exists_absolute(dir_path):
		return names
	for file_name in DirAccess.get_files_at(dir_path):
		# Remapping of exported resource
		var clean_name: String = file_name.trim_suffix(".remap")
		if clean_name.ends_with(EXTENSION):
			names.append(clean_name.trim_suffix(EXTENSION))
	return names
