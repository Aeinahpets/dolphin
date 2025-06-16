class_name UserPreferences extends Resource

@export_range(0, 1, 0.05) var music_audio_level: float = 1.0
@export_range(0, 1, 0.05) var sfx_audio_level: float = 1.0
@export_range(0, 1, 0.05) var master_audio_level: float = 1.0
@export_range(0, 1, 0.05) var ui_audio_level: float = 1.0
@export var language: int = 0
@export var cheats_on := false

func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")
	
static func load_or_create() -> UserPreferences:
	var file_path = "user://user_prefs.tres"
	var res: UserPreferences = load(file_path) as UserPreferences
	if !res:
		res = UserPreferences.new()
	return res
