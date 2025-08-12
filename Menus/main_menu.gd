extends CanvasLayer
@onready var panel_slots: Panel = $CenterContainer/PanelSlots

var user_prefs: UserPreferences

const SAVE_SLOTS = [
	"user://save1.tres",
	"user://save2.tres",
	"user://save3.tres"
]


func _on_new_game_pressed() -> void:
	#panel_slots.visible = true
	#user_prefs = UserPreferences.new()
	#user_prefs.current_scene = "res://Levels/1stage/Tank.tscn"
	#SceneTransition.change_scene(user_prefs.current_scene)
	SceneTransition.change_scene("res://Levels/1stage/Stage.tscn")

func _on_continue_pressed() -> void:
	#panel_slots.visible = true
	if user_prefs:
		user_prefs = UserPreferences.load_or_create()
	
	
func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_ocean_pressed() -> void:
	SceneTransition.change_scene("res://Levels/Main.tscn")
