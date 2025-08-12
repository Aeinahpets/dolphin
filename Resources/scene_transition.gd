extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var scene_target
var user_prefs: UserPreferences

func change_scene(target: String) ->void:
	print("SceneTransition: Requesting scene change to: ", target)
	scene_target = target
	if scene_target == null:
		print("ERROR: Could not load scene at path: ", target)
		return
	
	get_tree().change_scene_to_file(scene_target)
	animation_player.play("transition")
