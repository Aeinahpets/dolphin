class_name UserPreferences extends Resource

#Scene Data
var save_name: String = "No Name"
var save_timestamp: float = 0.0
var current_scene: StringName

	
static func load_or_create() -> UserPreferences:
	var file_path = "user://user_prefs.tres"
	var res: UserPreferences = load(file_path) as UserPreferences
	if !res:
		res = UserPreferences.new()
	return res


# Save this resource to a given path
func save_to_path(path: String) -> Error:
	return ResourceSaver.save(self, path)

# Static: Load from path or return new instance
static func load_from_path(path: String) -> UserPreferences:
	var res = load(path) as UserPreferences
	if res:
		return res
	else:
		return UserPreferences.new()
